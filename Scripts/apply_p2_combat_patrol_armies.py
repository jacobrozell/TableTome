#!/usr/bin/env python3
"""Merge P2 Combat Patrol roster metadata into combat-patrol-catalog-v1.json."""

from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CATALOG_PATH = ROOT / "Resources/Rules/combat-patrol-catalog-v1.json"

sys.path.insert(0, str(Path(__file__).resolve().parent))
from p2_combat_patrol_armies_data import P2_ARMIES, P2_FACTION_IDS  # noqa: E402


def merge_catalog(catalog: dict) -> tuple[int, list[str]]:
    warnings: list[str] = []
    merged = 0

    for faction in catalog.get("factions", []):
        faction_id = faction.get("id")
        if faction_id not in P2_FACTION_IDS:
            continue
        armies = faction.get("armies", [])
        if armies:
            warnings.append(f"{faction_id}: already has armies — skipped")
            continue
        faction["armies"] = [P2_ARMIES[faction_id]]
        merged += 1

    missing = P2_FACTION_IDS - {f["id"] for f in catalog.get("factions", [])}
    if missing:
        warnings.append(f"factions missing from catalog: {sorted(missing)}")

    for step in catalog.get("matchSteps", []):
        if step.get("id") != "choose-armies":
            continue
        step["tips"] = [
            "Tap Use Starter Matchup for Strike Force Octavius vs The Vardenghast Swarm (demo only).",
            "All 23 faction Combat Patrol boxes appear in the picker — pick the patrol you own.",
            "Six patrols include full battle tracker datasheets (SM, Tyranids, Orks, Necrons, Custodes, Guard); others show roster and setup for now.",
        ]
        step["body"] = (
            "Combat Patrol armies are fixed box-set rosters — no list building. "
            "Pick the patrol each player fields today. Tap Use Starter Matchup for the built-in "
            "Space Marines vs Tyranids demo, or choose any of the 23 faction patrols in the list."
        )

    return merged, warnings


def main() -> int:
    with CATALOG_PATH.open(encoding="utf-8") as handle:
        catalog = json.load(handle)

    merged, warnings = merge_catalog(catalog)

    playable = sum(len(f.get("armies", [])) for f in catalog["factions"])
    if playable != 23:
        print(f"Expected 23 playable patrols after merge, found {playable}", file=sys.stderr)
        return 1

    with CATALOG_PATH.open("w", encoding="utf-8") as handle:
        json.dump(catalog, handle, indent=2, ensure_ascii=False)
        handle.write("\n")

    print(f"Merged {merged} P2 armies into {CATALOG_PATH.relative_to(ROOT)}")
    print(f"  playable patrols: {playable}")
    for warning in warnings:
        print(f"  warning: {warning}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
