#!/usr/bin/env python3
"""Import AoS 4e Spearhead roster + match-setup options from Wahapedia into spearhead-catalog-v1.json."""

from __future__ import annotations

import html as htmlmod
import json
import re
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CATALOG_PATH = ROOT / "Resources/Rules/spearhead-catalog-v1.json"

# Wahapedia slugs — Orruk Warclans splits across ironjawz + kruleboyz.
FACTION_SOURCES: dict[str, list[str]] = {
    "stormcast-eternals": ["stormcast-eternals"],
    "skaven": ["skaven"],
    "cities-of-sigmar": ["cities-of-sigmar"],
    "daughters-of-khaine": ["daughters-of-khaine"],
    "fyreslayers": ["fyreslayers"],
    "kharadron-overlords": ["kharadron-overlords"],
    "idoneth-deepkin": ["idoneth-deepkin"],
    "lumineth-realm-lords": ["lumineth-realm-lords"],
    "seraphon": ["seraphon"],
    "sylvaneth": ["sylvaneth"],
    "blades-of-khorne": ["blades-of-khorne"],
    "disciples-of-tzeentch": ["disciples-of-tzeentch"],
    "hedonites-of-slaanesh": ["hedonites-of-slaanesh"],
    "maggotkin-of-nurgle": ["maggotkin-of-nurgle"],
    "slaves-to-darkness": ["slaves-to-darkness"],
    "helsmiths-of-hashut": ["helsmiths-of-hashut"],
    "gloomspite-gitz": ["gloomspite-gitz"],
    "orruk-warclans": ["ironjawz", "kruleboyz"],
    "ogor-mawtribes": ["ogor-mawtribes"],
    "sons-of-behemat": ["sons-of-behemat"],
    "flesh-eater-courts": ["flesh-eater-courts"],
    "nighthaunt": ["nighthaunt"],
    "ossiarch-bonereapers": ["ossiarch-bonereapers"],
    "soulblight-gravelords": ["soulblight-gravelords"],
}

ANCHOR_ID_MAP = {
    "fusil-platoon": "fusil-platoon",
    "zenestra-s-zealots": "zenestras-zealots",
    "yndrasta-s-spearhead": "yndrastas-spearhead",
    "crixxit-s-kill-pack": "crixxits-kill-pack",
    "tzaangor-warflock": "tzaangor-warflocks",
    "blades-of-the-lurid-dream": "blades-lurid-dream",
    "tithe-reaper-echelon": "tithe-reaper-echelon",
    "tyrant-s-bellow": "tyrants-bellow",
    "sentinels-of-embergard": "sentinels-embergard",
}

DISPLAY_NAME_MAP = {
    "fusil-platoon": "Fusil Platoon",
    "zenestras-zealots": "Zenestra's Zealots",
    "tzaangor-warflocks": "Tzaangor Warflocks",
    "yndrastas-spearhead": "Yndrasta's Spearhead",
    "crixxits-kill-pack": "Crixxit's Kill-Pack",
    "tyrants-bellow": "Tyrant's Bellow",
    "blades-lurid-dream": "Blades of the Lurid Dream",
    "tithe-reaper-echelon": "Tithe-Reaper Echelon",
    "spitewing-flight": "Spitewing Flight",
    "bubonic-cell": "Bubonic Cell",
    "fangs-of-the-blood-god": "Fangs of the Blood God",
}

CURATED_ARMY_IDS = {
    "vigilant-brotherhood",
    "yndrastas-spearhead",
    "gnawfeast-clawpack",
    "warpspark-clawpack",
}

SKIP_ANCHORS = re.compile(r"^(Battle-Traits|Regiment-Abilities|Enhancements|Warscrolls)", re.I)


def fetch(slug: str) -> str:
    url = f"https://wahapedia.ru/aos4/factions/{slug}/"
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0 (Tabletome import)"})
    with urllib.request.urlopen(req, timeout=90) as response:
        return response.read().decode("utf-8", "replace")


def strip_tags(value: str) -> str:
    value = re.sub(r"<br\s*/?>", "\n", value, flags=re.I)
    value = re.sub(r"</li>", "\n", value, flags=re.I)
    value = re.sub(r"<li[^>]*>", "", value, flags=re.I)
    value = re.sub(r"<[^>]+>", " ", value)
    value = htmlmod.unescape(value)
    return re.sub(r"\s+", " ", value).strip()


def slugify_text(text: str) -> str:
    key = text.lower().replace("'", "")
    key = re.sub(r"[^a-z0-9]+", "-", key).strip("-")
    return key


def slugify_anchor(anchor: str) -> str:
    key = slugify_text(anchor)
    return ANCHOR_ID_MAP.get(key, key)


def display_name(anchor: str, army_id: str) -> str:
    if army_id in DISPLAY_NAME_MAP:
        return DISPLAY_NAME_MAP[army_id]
    words = anchor.replace("-", " ").replace("s ", "'s ").split()
    return " ".join(word.capitalize() if word not in {"of", "the", "on"} else word for word in words)


def spearhead_section(page: str) -> str:
    match = re.search(r"<h2[^>]*>\s*SPEARHEAD\s*</h2>(.*)", page, re.S | re.I)
    if not match:
        return ""
    spear = match.group(1)
    cut = re.search(
        r"<h2[^>]*>\s*(?:ARMY OF RENOWN|REGIMENTS OF RENOWN|BATTALIONS|FACTION RULES)\s*</h2>",
        spear,
        re.I,
    )
    return spear[: cut.start()] if cut else spear


def parse_roster(block: str) -> tuple[str | None, list[str]]:
    general = None
    roster: list[str] = []
    general_match = re.search(
        r'hi_custom">GENERAL</div><ul class="Rhombus">(.*?)</ul>', block, re.S | re.I
    )
    if general_match:
        general = strip_tags(general_match.group(1))
    units_match = re.search(
        r'hi_custom">UNITS</div><ul class="Rhombus">(.*?)</ul>', block, re.S | re.I
    )
    if units_match:
        roster = [strip_tags(item) for item in re.findall(r"<li>(.*?)</li>", units_match.group(1), re.S)]
    return general, roster


def normalize_roster(general: str | None, roster: list[str]) -> list[str]:
    if not general:
        return roster
    general_key = general.strip().lower()
    if any(entry.strip().lower() == general_key for entry in roster):
        return roster
    return [general, *roster]


def has_roster_table(block: str) -> bool:
    return bool(re.search(r'hi_custom">(?:GENERAL|General)</div><ul class="Rhombus">', block, re.I))


def parse_options(block: str, header: str, limit: int) -> list[dict]:
    match = re.search(
        rf"<h3[^>]*>\s*{header}\s*</h3>(.*?)(?=<h3[^>]*>\s*(?:Regiment Abilities|Enhancements|Warscrolls)\s*</h3>|<a name=\"Warscrolls)",
        block,
        re.S | re.I,
    )
    if not match:
        return []

    section = match.group(1)
    options: list[dict] = []
    for body_match in re.finditer(
        r'class="abBody[^"]*"[^>]*>(.*?)</div>\s*(?:<div class="abKeywords"|</div>)',
        section,
        re.S | re.I,
    ):
        text = strip_tags(body_match.group(1))
        name_match = re.search(r"^([A-Z][A-Z0-9' \-!]+)\s*:", text) or re.search(
            r"\s([A-Z][A-Z0-9' \-!]{2,})\s*:", text
        )
        if not name_match:
            continue
        raw_name = name_match.group(1).strip()
        name = raw_name.title() if raw_name.isupper() else raw_name
        timing_search = section[: body_match.start()]
        timing_match = re.findall(
            r'class="abHeader"[^>]*>([^<]+(?:<[^>]+>[^<]*)*)</td>',
            timing_search,
        )
        timing = strip_tags(timing_match[-1]) if timing_match else None
        rest = text[name_match.end() :].strip()
        summary = rest.split("Declare:", 1)[0].strip().rstrip(".") if rest else name
        if summary.startswith("Effect:"):
            summary = name
        options.append(
            {
                "id": slugify_text(name),
                "name": name,
                "summary": summary[:320],
                "timing": timing,
            }
        )

    if not options:
        for chunk in re.findall(
            r'<div class="BreakInsideAvoid">(.*?)</div>\s*</div>\s*</div>',
            section,
            re.S,
        ):
            text = strip_tags(chunk)
            name_match = re.search(r"^([A-Z][A-Z0-9' \-!]+)\s*:", text) or re.search(
                r"\s([A-Z][A-Z0-9' \-!]{2,})\s*:", text
            )
            if not name_match:
                continue
            raw_name = name_match.group(1).strip()
            name = raw_name.title() if raw_name.isupper() else raw_name
            timing = text[: name_match.start()].strip() or None
            rest = text[name_match.end() :].strip()
            summary = rest.split("Declare:", 1)[0].strip().rstrip(".") if rest else name
            if summary.startswith("Effect:"):
                summary = name
            options.append(
                {
                    "id": slugify_text(name),
                    "name": name,
                    "summary": summary[:320],
                    "timing": timing,
                }
            )

    return options[:limit]


def extract_armies(faction_id: str, page: str) -> dict[str, dict]:
    spear = spearhead_section(page)
    if not spear:
        return {}

    armies: dict[str, dict] = {}
    anchors = [(match.start(), match.group(1)) for match in re.finditer(r'<a name="([^"]+)"></a>', spear)]
    army_anchors = [(pos, name) for pos, name in anchors if not SKIP_ANCHORS.match(name)]

    for index, (pos, anchor) in enumerate(army_anchors):
        end = army_anchors[index + 1][0] if index + 1 < len(army_anchors) else len(spear)
        block = spear[pos:end]
        if not has_roster_table(block):
            continue

        army_id = slugify_anchor(anchor)
        general, roster = parse_roster(block)
        roster = normalize_roster(general, roster)
        battle_traits = parse_options(block, "Battle Traits", 4)
        regiment = parse_options(block, "Regiment Abilities", 2)
        enhancements = parse_options(block, "Enhancements", 4)

        armies[army_id] = {
            "id": army_id,
            "name": display_name(anchor, army_id),
            "general": general or "",
            "tagline": "",
            "playstyle": "",
            "unitCount": len(roster),
            "roster": roster,
            "battleTraitName": battle_traits[0]["name"] if battle_traits else display_name(anchor, army_id),
            "officialRulesURL": faction_rules_url(faction_id),
            "battleTraits": battle_traits,
            "regimentAbilities": regiment,
            "enhancements": enhancements,
        }

    return armies


def faction_rules_url(faction_id: str) -> str:
    slug = faction_id.replace("_", "-")
    file_slug = slug.replace("-", "_")
    return (
        "https://assets.warhammer-community.com/rules-downloads/age-of-sigmar/"
        f"{slug}-spearhead/eng_{file_slug}_spearhead.pdf"
    )


def merge_option_lists(existing: list[dict], imported: list[dict]) -> list[dict]:
    existing_by_id = {item["id"]: item for item in existing}
    merged: list[dict] = []
    for item in imported:
        prior = existing_by_id.get(item["id"], {})
        merged_item = {**item}
        if prior.get("newPlayerHint"):
            merged_item["newPlayerHint"] = prior["newPlayerHint"]
        merged.append(merged_item)
    return merged


def merge_army(existing: dict, imported: dict) -> dict:
    merged = {**existing}
    preserve_loadouts = existing.get("id") in CURATED_ARMY_IDS
    for key in (
        "name",
        "general",
        "unitCount",
        "roster",
        "battleTraitName",
        "officialRulesURL",
        "battleTraits",
        "regimentAbilities",
        "enhancements",
    ):
        if preserve_loadouts and key in {"battleTraits", "regimentAbilities", "enhancements", "battleTraitName"}:
            continue
        if key in imported and imported[key]:
            if key in {"battleTraits", "regimentAbilities", "enhancements"}:
                merged[key] = merge_option_lists(existing.get(key, []), imported[key])
            else:
                merged[key] = imported[key]

    if existing.get("tagline"):
        merged["tagline"] = existing["tagline"]
    elif imported.get("tagline"):
        merged["tagline"] = imported["tagline"]

    if existing.get("playstyle"):
        merged["playstyle"] = existing["playstyle"]
    elif imported.get("playstyle"):
        merged["playstyle"] = imported["playstyle"]

    return merged


def default_new_army(army_id: str, imported: dict) -> dict:
    return {
        **imported,
        "tagline": imported.get("tagline") or f"AoS 4e Spearhead — {imported['name']}",
        "playstyle": imported.get("playstyle")
        or "Fixed box-set roster. Pick regiment ability and general enhancement during guided match setup.",
    }


def dedupe_faction_armies(catalog: dict) -> None:
    for faction in catalog["factions"]:
        seen: dict[str, dict] = {}
        deduped: list[dict] = []
        for army in faction["armies"]:
            existing = seen.get(army["id"])
            if existing is None:
                seen[army["id"]] = army
                deduped.append(army)
                continue
            existing_score = len(existing.get("roster", [])) + len(existing.get("regimentAbilities", []))
            army_score = len(army.get("roster", [])) + len(army.get("regimentAbilities", []))
            if army_score > existing_score:
                deduped = [item for item in deduped if item["id"] != army["id"]]
                deduped.append(army)
                seen[army["id"]] = army
        faction["armies"] = deduped


def main() -> None:
    imported_by_id: dict[str, dict] = {}
    imported_faction: dict[str, str] = {}

    for faction_id, slugs in FACTION_SOURCES.items():
        for slug in slugs:
            page = fetch(slug)
            for army_id, army in extract_armies(faction_id, page).items():
                imported_by_id[army_id] = army
                imported_faction[army_id] = faction_id

    catalog = json.loads(CATALOG_PATH.read_text())
    known_ids = {
        army["id"]
        for faction in catalog["factions"]
        for army in faction["armies"]
    }

    updated = 0
    added = 0
    for faction in catalog["factions"]:
        new_armies = []
        for army in faction["armies"]:
            if army["id"] in imported_by_id:
                new_armies.append(merge_army(army, imported_by_id[army["id"]]))
                updated += 1
            else:
                new_armies.append(army)
        faction["armies"] = new_armies

    for army_id, army in imported_by_id.items():
        if army_id in known_ids:
            continue
        faction_id = imported_faction[army_id]
        faction = next(item for item in catalog["factions"] if item["id"] == faction_id)
        faction["armies"].append(default_new_army(army_id, army))
        added += 1

    missing = sorted(known_ids - set(imported_by_id))
    dedupe_faction_armies(catalog)
    CATALOG_PATH.write_text(json.dumps(catalog, indent=2) + "\n")
    print(f"Updated {updated} armies, added {added}, catalog armies without Wahapedia import: {missing}")


if __name__ == "__main__":
    main()
