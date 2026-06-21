#!/usr/bin/env python3
"""Generate Spearhead army detail overlays from Wahapedia (stats, weapons, abilities, battle traits)."""

from __future__ import annotations

import html as htmlmod
import json
import re
from pathlib import Path

from import_spearhead_from_wahapedia import (
    FACTION_SOURCES,
    SKIP_ANCHORS,
    fetch,
    has_roster_table,
    normalize_roster,
    parse_roster,
    slugify_anchor,
    slugify_text,
    spearhead_section,
    strip_tags,
)

ROOT = Path(__file__).resolve().parents[1]
CATALOG_PATH = ROOT / "Resources/Rules/spearhead-catalog-v1.json"
DETAIL_DIR = ROOT / "Resources/Rules/Spearhead/armies"

# Keep hand-authored overlays with curated copy.
PRESERVE_DETAIL_ARMY_IDS = {
    "vigilant-brotherhood",
    "gnawfeast-clawpack",
}

SKIP_ABILITY_NAMES = {
    "normal move",
    "run",
    "charge",
    "retreat",
    "stand up",
    "move",
    "declare",
    "effect",
    "keywords",
}


def strip_html(value: str) -> str:
    return htmlmod.unescape(re.sub(r"\s+", " ", re.sub(r"<[^>]+>", " ", value))).strip()


def title_case_name(raw: str) -> str:
    cleaned = raw.strip().rstrip(":")
    if cleaned.isupper():
        return cleaned.title().replace("'S", "'s")
    return cleaned


def parse_unit_name(header_html: str) -> str:
    main = re.search(
        r'class="wsHeaderIn"[^>]*>(.*?)(?:</div>|<div class="wsAddName")',
        header_html,
        re.S,
    )
    add = re.search(
        r'class="wsAddName"[^>]*>(.*?)(?:<a |</div>)',
        header_html,
        re.S,
    )
    parts: list[str] = []
    if main:
        parts.append(strip_html(main.group(1)))
    if add:
        parts.append(strip_html(add.group(1)))
    return " ".join(part for part in parts if part).replace("\n", " ").strip()


def slugify_unit(name: str) -> str:
    key = name.lower().replace("'", "").replace("‑", "-").replace("–", "-")
    return re.sub(r"[^a-z0-9]+", "-", key).strip("-")


def normalize_name(value: str) -> str:
    value = value.lower().replace("‑", "-").replace("–", "-")
    value = re.sub(r"\([^)]*\)", "", value)
    return re.sub(r"[^a-z0-9]+", " ", value).strip()


def parse_model_count(entry: str) -> tuple[int, str]:
    match = re.match(r"^(\d+)\s+(.+)$", entry.strip())
    if match:
        return int(match.group(1)), match.group(2).strip()
    return 1, entry.strip()


def parse_stat(value: str) -> int | None:
    value = value.strip()
    if not value or value in {"-", "–"}:
        return 0
    match = re.search(r"(\d+)", value)
    return int(match.group(1)) if match else None


def parse_phases(timing: str) -> list[str]:
    lowered = timing.lower()
    phases: list[str] = []
    if "hero" in lowered:
        phases.append("hero")
    if "movement" in lowered:
        phases.append("movement")
    if "shooting" in lowered:
        phases.append("shooting")
    if "charge" in lowered:
        phases.append("charge")
    if "any combat" in lowered:
        phases.append("anyCombat")
    elif "combat" in lowered:
        phases.append("combat")
    if "end of" in lowered and "turn" in lowered:
        phases.append("endOfTurn")
    return phases


def parse_usage_limit(timing: str, body_text: str) -> str:
    lowered = f"{timing} {body_text}".lower()
    if "passive" in lowered:
        return "passive"
    if "reaction" in lowered:
        return "reaction"
    if "once per battle" in lowered:
        return "oncePerBattle"
    if "once per phase" in lowered:
        return "oncePerPhase"
    if "once per turn" in lowered or "each turn" in lowered:
        return "eachTurn"
    return "eachTurn"


def parse_ability_kind(timing: str, body_html: str) -> str:
    lowered = f"{timing} {body_html}".lower()
    if "prayer" in lowered:
        return "prayer"
    if "spell" in lowered:
        return "spell"
    if "passive" in lowered:
        return "passive"
    return "ability"


def parse_keywords(block_html: str) -> list[str]:
    keywords: list[str] = []
    seen: set[str] = set()

    def add_keyword(raw: str) -> None:
        cleaned = raw.strip().rstrip(",").strip()
        if not cleaned or cleaned.upper() == "KEYWORDS":
            return
        normalized = cleaned.title() if cleaned.isupper() else cleaned
        key = normalized.lower()
        if key not in seen:
            seen.add(key)
            keywords.append(normalized)

    for match in re.finditer(r'class="abKeywordsBodyText[^"]*"[^>]*>(.*?)</td>', block_html, re.S):
        for token in re.findall(r'<span class="kwb">([^<]+)</span>', match.group(1)):
            add_keyword(token)
    for match in re.finditer(r'class="wsKeywordLine1[^"]*"[^>]*>(.*?)</td>', block_html, re.S):
        for token in re.findall(r'<span class="kwb">([^<]+)</span>', match.group(1)):
            add_keyword(token)
    return keywords


def parse_ability_blocks(section_html: str, source: str) -> list[dict]:
    abilities: list[dict] = []
    headers = list(re.finditer(r'class="abHeader"[^>]*>(.*?)</td>', section_html, re.S))
    for index, header in enumerate(headers):
        timing = strip_html(header.group(1))
        if timing.upper() == "KEYWORDS":
            continue
        start = header.end()
        end = headers[index + 1].start() if index + 1 < len(headers) else len(section_html)
        body_match = re.search(
            r'class="abBody[^"]*"[^>]*>(.*?)</div>\s*(?:</div>\s*</div>\s*</div>|</div>\s*<div class="BreakInsideAvoid")',
            section_html[start:end],
            re.S,
        )
        if not body_match:
            continue
        body_html = body_match.group(1)
        name_match = re.search(r"<b>(.*?)</b>", body_html, re.I)
        if not name_match:
            continue
        name = title_case_name(strip_html(name_match.group(1))).strip()
        if name.lower() in SKIP_ABILITY_NAMES:
            continue
        body_text = strip_html(body_html)
        declare_match = re.search(r"Declare:\s*(.*?)(?:Effect:|Keywords:|$)", body_text, re.I | re.S)
        effect_match = re.search(r"Effect:\s*(.+)", body_text, re.I | re.S)
        declare = declare_match.group(1).strip() if declare_match else None
        if effect_match:
            effect = effect_match.group(1).strip()
        else:
            effect = re.sub(r"^.*?:\s*", "", body_text, count=1).strip() or name
        flavor_match = re.search(r'class="ShowFluff legend4">(.*?)</span>', body_html, re.S)
        flavor = strip_html(flavor_match.group(1)) if flavor_match else None
        usage = parse_usage_limit(timing, body_text)
        phases = parse_phases(timing)
        if usage == "passive" and not phases:
            phases = []
        elif not phases:
            phases = ["hero"]
        summary = effect.split(".")[0][:240] if effect else name
        abilities.append(
            {
                "id": slugify_text(name),
                "name": name,
                "source": source,
                "flavor": flavor,
                "phases": phases,
                "usageLimit": usage,
                "declare": declare,
                "effect": effect,
                "kind": parse_ability_kind(timing, body_html),
                "summary": summary,
            }
        )
    return abilities


def parse_weapons(unit_html: str) -> list[dict]:
    weapons: list[dict] = []
    id_counts: dict[str, int] = {}
    for table in re.findall(r'<table class="wTable"(.*?)</table>', unit_html, re.S):
        is_ranged = "RANGED WEAPONS" in table
        is_melee = "MELEE WEAPONS" in table
        if not is_ranged and not is_melee:
            continue

        short_names = [
            strip_html(name)
            for name in re.findall(
                r'<tr class="wsDataRow wsDataRow_short"[^>]*><td colspan="[^"]*"[^>]*>([^<]+)</td>',
                table,
            )
        ]
        data_rows = re.findall(
            r'<tr class="wsDataRow dsColorFr[^"]*"[^>]*>(.*?)</tr>',
            table,
            re.S,
        )
        for index, row in enumerate(data_rows):
            stat_cells = [
                strip_html(cell)
                for cell in re.findall(
                    r'class="wsBorder[^"]* wsCell[^"]*"[^>]*>([^<]*)',
                    row,
                )
            ]
            name_cells = [
                strip_html(cell)
                for cell in re.findall(
                    r'class="wsDataCell_long[^"]*"[^>]*>(.*?)</td>',
                    row,
                    re.S,
                )
            ]
            name = next((cell for cell in reversed(name_cells) if cell), None)
            if name:
                name = re.sub(r"\s*Companion$", "", name, flags=re.I).strip()
                name = re.sub(r"\s+Shoot in Combat$", "", name, flags=re.I).strip()
                name = re.sub(r"Mounrfang", "Mournfang", name, flags=re.I)
            if not name and index < len(short_names):
                name = re.sub(r"\s*\[.*\]$", "", short_names[index]).strip()
            if not name:
                continue

            if is_ranged and len(stat_cells) >= 6:
                rng, attacks, hit, wound, rend, damage = stat_cells[:6]
                range_inches = parse_stat(rng)
            elif len(stat_cells) >= 5:
                attacks, hit, wound, rend, damage = stat_cells[-5:]
                range_inches = None
            else:
                continue

            hit_val = parse_stat(hit)
            wound_val = parse_stat(wound)
            rend_val = parse_stat(rend)
            if hit_val is None or wound_val is None or rend_val is None:
                continue

            weapon_id = slugify_text(name)
            id_counts[weapon_id] = id_counts.get(weapon_id, 0) + 1
            if id_counts[weapon_id] > 1:
                weapon_id = f"{weapon_id}-{id_counts[weapon_id]}"
            ability_match = re.search(
                rf"{re.escape(name)}.*?class=\"wsWeaponAbility\"[^>]*>([^<]+)",
                unit_html,
                re.S | re.I,
            )
            weapons.append(
                {
                    "id": weapon_id,
                    "name": name,
                    "rangeInches": range_inches,
                    "attacks": attacks,
                    "hit": hit_val,
                    "wound": wound_val,
                    "rend": rend_val,
                    "damage": damage,
                    **({"ability": strip_html(ability_match.group(1))} if ability_match else {}),
                }
            )
    return weapons


def split_unit_blocks(wblock: str) -> list[tuple[str, str]]:
    pattern = re.compile(
        r'<div class="wsMove[^"]*"[^>]*>([^<]+)</div>\s*<div class="wsWounds"[^>]*>([^<]+)</div>\s*'
        r'<div class="wsSave"[^>]*>([^<]+)</div>\s*<div class="wsBravery"[^>]*>([^<]+)</div>',
        re.S,
    )
    matches = list(pattern.finditer(wblock))
    blocks: list[tuple[str, str]] = []
    for index, match in enumerate(matches):
        segment_start = matches[index - 1].start() if index > 0 else 0
        segment_end = matches[index + 1].start() if index + 1 < len(matches) else len(wblock)
        segment = wblock[segment_start:segment_end]
        relative = match.start() - segment_start
        prefix = segment[:relative]
        headers = list(re.finditer(r'wsHeaderIn">([^<]+)', prefix))
        name = strip_html(headers[-1].group(1)) if headers else ""
        blocks.append((name, segment))
    return blocks


def parse_warscroll_profiles(wblock: str) -> list[dict]:
    profiles: list[dict] = []
    for name, unit_html in split_unit_blocks(wblock):
        if not name:
            continue
        stat_match = re.search(
            r'<div class="wsMove[^"]*"[^>]*>([^<]+)</div>\s*'
            r'<div class="wsWounds"[^>]*>([^<]+)</div>\s*'
            r'<div class="wsSave"[^>]*>([^<]+)</div>\s*'
            r'<div class="wsBravery"[^>]*>([^<]+)</div>',
            unit_html,
            re.S,
        )
        if not stat_match:
            continue
        profiles.append(
            {
                "name": name,
                "move": stat_match.group(1).strip(),
                "health": int(re.sub(r"\D", "", stat_match.group(2))),
                "save": int(re.sub(r"\D", "", stat_match.group(3))),
                "control": int(re.sub(r"\D", "", stat_match.group(4))),
                "keywords": parse_keywords(unit_html),
                "weapons": parse_weapons(unit_html),
                "abilities": parse_ability_blocks(unit_html, source=name),
            }
        )
    return profiles


def parse_battle_traits(block: str) -> list[dict]:
    match = re.search(
        r'<h3[^>]*>\s*Battle Traits\s*</h3>(.*?)(?=<h3[^>]*>\s*(?:Regiment Abilities|Enhancements|Warscrolls)\s*</h3>|<a name="Warscrolls)',
        block,
        re.S | re.I,
    )
    if not match:
        return []
    section = match.group(1)
    traits: list[dict] = []
    for ability in parse_ability_blocks(section, source="Battle Trait"):
        traits.append(
            {
                "id": ability["id"],
                "name": ability["name"],
                "summary": ability.get("summary") or ability["effect"][:240],
                "timing": None,
                "declare": ability.get("declare"),
                "effect": ability["effect"],
                "phases": ability["phases"],
                "usageLimit": ability["usageLimit"],
                "kind": ability["kind"],
            }
        )
    if traits:
        return traits
    intro = strip_tags(section.split("<div class=\"BreakInsideAvoid\">")[0])
    if intro:
        traits.append(
            {
                "id": slugify_text(intro[:48]),
                "name": "Battle Trait",
                "summary": intro[:320],
                "effect": intro[:480],
                "phases": ["movement"],
                "usageLimit": "oncePerBattle",
                "kind": "ability",
            }
        )
    return traits


def match_score(roster_name: str, warscroll_name: str) -> int:
    roster_key = normalize_name(roster_name)
    warscroll_key = normalize_name(warscroll_name)
    roster_head = roster_key.split(" incl ")[0].split(" with ")[0].strip()
    warscroll_head = warscroll_key.split(" incl ")[0].split(" with ")[0].strip()

    if roster_key == warscroll_key or roster_head == warscroll_head:
        return 100
    if roster_head and warscroll_head and (
        roster_head.startswith(warscroll_head) or warscroll_head.startswith(roster_head)
    ):
        return 90
    if roster_key in warscroll_key or warscroll_key in roster_key:
        return 80 - min(abs(len(warscroll_key) - len(roster_key)), 20)
    roster_tokens = set(roster_key.split())
    warscroll_tokens = set(warscroll_key.split())
    overlap = roster_tokens & warscroll_tokens
    if len(overlap) >= 2:
        return 50 + len(overlap)
    if len(overlap) == 1:
        token = next(iter(overlap))
        if len(token) >= 5:
            return 45
    return 0


def match_roster_to_warscrolls(roster: list[str], warscrolls: list[dict]) -> tuple[list[dict], list[str]]:
    id_counts: dict[str, int] = {}
    matched: list[dict] = []
    errors: list[str] = []

    for entry in roster:
        model_count, base_name = parse_model_count(entry)
        best_index = None
        best_score = 0
        for index, warscroll in enumerate(warscrolls):
            score = match_score(base_name, warscroll["name"])
            if score > best_score:
                best_score = score
                best_index = index

        if best_index is None or best_score < 40:
            errors.append(entry)
            continue

        warscroll = warscrolls[best_index]
        base_id = slugify_unit(warscroll["name"])
        id_counts[base_id] = id_counts.get(base_id, 0) + 1
        unit_id = base_id if id_counts[base_id] == 1 else f"{base_id}-{id_counts[base_id]}"
        unit = {
            "id": unit_id,
            "name": warscroll["name"],
            "move": warscroll["move"],
            "save": warscroll["save"],
            "health": warscroll["health"],
            "control": warscroll["control"],
            "keywords": warscroll.get("keywords", []),
            "modelCount": model_count,
        }
        if warscroll.get("weapons"):
            unit["weapons"] = warscroll["weapons"]
        if warscroll.get("abilities"):
            unit["abilities"] = [
                {
                    key: value
                    for key, value in ability.items()
                    if key not in {"summary"}
                }
                for ability in warscroll["abilities"]
            ]
        matched.append(unit)

    return matched, errors


def extract_army_detail(
    page: str, army_id: str, roster: list[str] | None = None
) -> tuple[list[dict], list[dict], list[str]]:
    spear = spearhead_section(page)
    if not spear:
        return [], [], ["missing spearhead section"]

    anchors = [(match.start(), match.group(1)) for match in re.finditer(r'<a name="([^"]+)"></a>', spear)]
    army_anchors = [(pos, name) for pos, name in anchors if not SKIP_ANCHORS.match(name)]

    for index, (pos, anchor) in enumerate(army_anchors):
        if slugify_anchor(anchor) != army_id:
            continue

        end = army_anchors[index + 1][0] if index + 1 < len(army_anchors) else len(spear)
        block = spear[pos:end]
        if not has_roster_table(block):
            return [], [], ["missing roster table"]

        general, parsed_roster = parse_roster(block)
        roster = roster or normalize_roster(general, parsed_roster)
        battle_traits = parse_battle_traits(block)
        warscroll_match = re.search(r'<a name="Warscrolls[^"]*"></a>(.*)', block, re.S | re.I)
        if not warscroll_match:
            return [], battle_traits, ["missing warscroll section"]

        warscrolls = parse_warscroll_profiles(warscroll_match.group(1))
        if not warscrolls:
            return [], battle_traits, ["no warscroll profiles parsed"]

        units, errors = match_roster_to_warscrolls(roster, warscrolls)
        if errors:
            return units, battle_traits, [f"no warscroll for {entry}" for entry in errors]
        return units, battle_traits, []

    return [], [], ["army anchor not found"]


def write_detail_file(army_id: str, units: list[dict], battle_traits: list[dict]) -> None:
    payload: dict = {
        "schemaVersion": 1,
        "armyId": army_id,
        "units": units,
    }
    if battle_traits:
        payload["battleTraits"] = battle_traits
    path = DETAIL_DIR / f"{army_id}.json"
    path.write_text(json.dumps(payload, indent=2) + "\n")


def main() -> None:
    catalog = json.loads(CATALOG_PATH.read_text())
    armies = [army for faction in catalog["factions"] for army in faction["armies"]]
    army_faction = {
        army["id"]: faction["id"]
        for faction in catalog["factions"]
        for army in faction["armies"]
    }

    page_cache: dict[str, str] = {}
    for slugs in FACTION_SOURCES.values():
        for slug in slugs:
            if slug not in page_cache:
                page_cache[slug] = fetch(slug)

    written = 0
    skipped = 0
    failures: list[tuple[str, list[str]]] = []

    for army in armies:
        army_id = army["id"]
        if army_id in PRESERVE_DETAIL_ARMY_IDS:
            skipped += 1
            continue

        faction_id = army_faction[army_id]
        slugs = FACTION_SOURCES.get(faction_id, [])
        units: list[dict] = []
        battle_traits: list[dict] = []
        errors: list[str] = []
        for slug in slugs:
            units, battle_traits, errors = extract_army_detail(
                page_cache[slug], army_id, roster=army["roster"]
            )
            if units:
                break
        if errors or len(units) != len(army["roster"]):
            failures.append((army_id, errors or [f"expected {len(army['roster'])} units, got {len(units)}"]))
            continue

        write_detail_file(army_id, units, battle_traits)
        written += 1

    print(f"Wrote {written} detail files, skipped {skipped} curated overlays.")
    if failures:
        print(f"Failures ({len(failures)}):")
        for army_id, errors in failures:
            print(f"  {army_id}: {', '.join(errors)}")


if __name__ == "__main__":
    main()
