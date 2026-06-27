#!/usr/bin/env python3
"""Validate and optionally refresh Combat Patrol catalog metadata from Wahapedia research."""

from __future__ import annotations

import json
import sys
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CATALOG_PATH = ROOT / "Resources/Rules/combat-patrol-catalog-v1.json"
ARMIES_DIR = ROOT / "Resources/Rules/CombatPatrol/armies"

DETAIL_ARMY_IDS: set[str] | None = None  # None = all armies in catalog


def all_army_ids(catalog: dict) -> set[str]:
    return {
        army["id"]
        for faction in catalog.get("factions", [])
        for army in faction.get("armies", [])
        if army.get("id")
    }

REQUIRED_MATCH_STEP_IDS = {
    "choose-armies",
    "pick-enhancement",
    "determine-mission",
    "setup-battlefield",
    "declare-formations",
    "deploy-armies",
    "roll-first-turn",
    "fight-battle",
}

WAHAPEDIA_CP_FACTIONS: dict[str, str] = {
    "space-marines": "strike-force-octavius",
    "tyranids": "the-vardenghast-swarm",
}


def load_catalog() -> dict:
    with CATALOG_PATH.open(encoding="utf-8") as handle:
        return json.load(handle)


def fetch_wahapedia(slug: str) -> str:
    url = f"https://wahapedia.ru/wh40k10ed_cp/factions/{slug}/"
    request = urllib.request.Request(url, headers={"User-Agent": "Tabletome-import/1.0"})
    with urllib.request.urlopen(request, timeout=30) as response:
        return response.read().decode("utf-8", errors="replace")


def validate_catalog(catalog: dict) -> list[str]:
    errors: list[str] = []
    if catalog.get("schemaVersion") != 1:
        errors.append("schemaVersion must be 1")

    factions = catalog.get("factions", [])
    if len(factions) != 23:
        errors.append(f"expected 23 factions, found {len(factions)}")

    step_ids = {step["id"] for step in catalog.get("matchSteps", [])}
    missing_steps = REQUIRED_MATCH_STEP_IDS - step_ids
    if missing_steps:
        errors.append(f"missing matchSteps: {sorted(missing_steps)}")

    missions = catalog.get("missions", [])
    if not any(m.get("id") == "clash-of-patrols" for m in missions):
        errors.append("missing clash-of-patrols mission")

    detail_army_ids = DETAIL_ARMY_IDS if DETAIL_ARMY_IDS is not None else all_army_ids(catalog)

    for army_id in sorted(detail_army_ids):
        army = next(
            (a for f in factions for a in f.get("armies", []) if a.get("id") == army_id),
            None,
        )
        if army is None:
            errors.append(f"missing army {army_id}")
            continue
        if len(army.get("enhancements", [])) < 2:
            errors.append(f"{army_id}: expected 2 enhancements")
        if len(army.get("secondaryObjectives", [])) < 2:
            errors.append(f"{army_id}: expected 2 secondary objectives")
        if len(army.get("stratagems", [])) < 3:
            errors.append(f"{army_id}: expected 3 stratagems")

        detail_path = ARMIES_DIR / f"{army_id}.json"
        if not detail_path.exists():
            errors.append(f"missing detail JSON {detail_path.name}")
            continue
        with detail_path.open(encoding="utf-8") as handle:
            detail = json.load(handle)
        units = detail.get("units", [])
        if not units:
            errors.append(f"{army_id}: detail JSON has no units")
        elif not any(u.get("weapons") or u.get("save") is not None for u in units):
            errors.append(f"{army_id}: detail units lack warscroll stats")

    return errors


def verify_wahapedia_links() -> list[str]:
    warnings: list[str] = []
    for _faction_id, slug in WAHAPEDIA_CP_FACTIONS.items():
        try:
            html = fetch_wahapedia(slug)
        except OSError as exc:
            warnings.append(f"wahapedia fetch failed for {slug}: {exc}")
            continue
        if "STRATAGEMS" not in html.upper():
            warnings.append(f"wahapedia page for {slug} missing STRATAGEMS section")
    return warnings


def main() -> int:
    catalog = load_catalog()
    errors = validate_catalog(catalog)
    if errors:
        print("Catalog validation failed:")
        for error in errors:
            print(f"  - {error}")
        return 1

    print(f"Validated {CATALOG_PATH.relative_to(ROOT)}")
    print(f"  factions: {len(catalog['factions'])}")
    print(f"  missions: {len(catalog.get('missions', []))}")
    detail_army_ids = DETAIL_ARMY_IDS if DETAIL_ARMY_IDS is not None else all_army_ids(catalog)
    print(f"  detail JSON files: {len(detail_army_ids)}")

    if "--check-wahapedia" in sys.argv:
        warnings = verify_wahapedia_links()
        for warning in warnings:
            print(f"Warning: {warning}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
