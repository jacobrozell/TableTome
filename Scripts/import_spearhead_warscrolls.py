#!/usr/bin/env python3
"""Generate Spearhead army detail overlays with per-unit wound-tracking stats from Wahapedia."""

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
    spearhead_section,
)

ROOT = Path(__file__).resolve().parents[1]
CATALOG_PATH = ROOT / "Resources/Rules/spearhead-catalog-v1.json"
DETAIL_DIR = ROOT / "Resources/Rules/Spearhead/armies"

# Keep hand-authored overlays with full abilities and weapons.
PRESERVE_DETAIL_ARMY_IDS = {
    "vigilant-brotherhood",
    "gnawfeast-clawpack",
}


def strip_html(value: str) -> str:
    return htmlmod.unescape(re.sub(r"\s+", " ", re.sub(r"<[^>]+>", " ", value))).strip()


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


def parse_warscroll_blocks(wblock: str) -> list[dict]:
    units: list[dict] = []
    pattern = re.compile(
        r'<div class="wsMove[^"]*"[^>]*>([^<]+)</div>\s*'
        r'<div class="wsWounds"[^>]*>([^<]+)</div>\s*'
        r'<div class="wsSave"[^>]*>([^<]+)</div>\s*'
        r'<div class="wsBravery"[^>]*>([^<]+)</div>',
        re.S,
    )
    for match in pattern.finditer(wblock):
        prefix = wblock[max(0, match.start() - 3000) : match.start()]
        headers = list(
            re.finditer(
                r'<div class="wsHeaderWrap_c">(.*?)</div>\s*</div>\s*</div>\s*</div>',
                prefix,
                re.S,
            )
        )
        name = parse_unit_name(headers[-1].group(1)) if headers else ""
        if not name:
            continue
        units.append(
            {
                "name": name,
                "move": match.group(1).strip(),
                "health": int(re.sub(r"\D", "", match.group(2))),
                "save": int(re.sub(r"\D", "", match.group(3))),
                "control": int(re.sub(r"\D", "", match.group(4))),
            }
        )
    return units


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
        matched.append(
            {
                "id": unit_id,
                "name": warscroll["name"],
                "move": warscroll["move"],
                "save": warscroll["save"],
                "health": warscroll["health"],
                "control": warscroll["control"],
                "keywords": [],
                "modelCount": model_count,
            }
        )

    return matched, errors


def extract_army_units(page: str, army_id: str, roster: list[str] | None = None) -> tuple[list[dict], list[str]]:
    spear = spearhead_section(page)
    if not spear:
        return [], ["missing spearhead section"]

    anchors = [(match.start(), match.group(1)) for match in re.finditer(r'<a name="([^"]+)"></a>', spear)]
    army_anchors = [(pos, name) for pos, name in anchors if not SKIP_ANCHORS.match(name)]

    for index, (pos, anchor) in enumerate(army_anchors):
        if slugify_anchor(anchor) != army_id:
            continue

        end = army_anchors[index + 1][0] if index + 1 < len(army_anchors) else len(spear)
        block = spear[pos:end]
        if not has_roster_table(block):
            return [], ["missing roster table"]

        general, parsed_roster = parse_roster(block)
        roster = roster or normalize_roster(general, parsed_roster)
        warscroll_match = re.search(r'<a name="Warscrolls[^"]*"></a>(.*)', block, re.S | re.I)
        if not warscroll_match:
            return [], ["missing warscroll section"]

        warscrolls = parse_warscroll_blocks(warscroll_match.group(1))
        if not warscrolls:
            return [], ["no warscroll profiles parsed"]

        units, errors = match_roster_to_warscrolls(roster, warscrolls)
        if errors:
            return units, [f"no warscroll for {entry}" for entry in errors]
        return units, []

    return [], ["army anchor not found"]


def write_detail_file(army_id: str, units: list[dict]) -> None:
    payload = {
        "schemaVersion": 1,
        "armyId": army_id,
        "units": units,
    }
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
        errors: list[str] = []
        for slug in slugs:
            units, errors = extract_army_units(page_cache[slug], army_id, roster=army["roster"])
            if units:
                break
        if errors or len(units) != len(army["roster"]):
            failures.append((army_id, errors or [f"expected {len(army['roster'])} units, got {len(units)}"]))
            continue

        write_detail_file(army_id, units)
        written += 1

    print(f"Wrote {written} detail files, skipped {skipped} curated overlays.")
    if failures:
        print(f"Failures ({len(failures)}):")
        for army_id, errors in failures:
            print(f"  {army_id}: {', '.join(errors)}")


if __name__ == "__main__":
    main()
