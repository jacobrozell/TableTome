#!/usr/bin/env python3
"""Apply GW Munitorum Field Manual points to bundled Muster catalog JSON.

Source: Warhammer 40,000 Munitorum Field Manual (March 2025 text export) with
June 2025 Balance Dataslate point adjustments for Space Marines units we ship.

Run from repo root:
  python3 Scripts/update_muster_catalog_points.py [--mfm PATH] [--dry-run]
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
CATALOG_DIR = REPO / "Resources" / "Catalogs" / "40k"
DEFAULT_MFM = Path.home() / ".cursor/projects/Users-jrozell-Desktop-personal/agent-tools/ad23c4d0-9b80-43f6-8bd9-842443ceefa8.txt"

# catalog unit id → (MFM unit name, model count)
UNIT_ALIASES: dict[str, tuple[str, int]] = {
    "40k:chaos-space-marines:rhino": ("Chaos Rhino", 1),
    "40k:chaos-space-marines:land-raider": ("Chaos Land Raider", 1),
    "40k:chaos-space-marines:lord-discordant": ("Lord Discordant on Helstalker", 1),
    "40k:chaos-space-marines:dark-apostle": ("Dark Apostle", 3),
    "40k:necrons:lord": ("Overlord", 1),
    "40k:necrons:destroyer-squad": ("Skorpekh Destroyers", 3),
    "40k:necrons:scarab-swarms": ("Canoptek Scarab Swarms", 3),
    "40k:necrons:canoptek-spyder": ("Canoptek Spyders", 1),
    "40k:orks:killa-kan": ("Killa Kans", 3),
    "40k:orks:lootas": ("Lootas", 5),
    "40k:orks:gretchin": ("Gretchin", 11),
    "40k:orks:beast-snagga-boss": ("Beastboss", 1),
    "40k:space-marines:assault-intercessors": ("Assault Intercessor Squad", 5),
    "40k:space-marines:heavy-intercessors": ("Heavy Intercessor Squad", 5),
    "40k:orks:tankbustas": ("Tankbustas", 6),
    "40k:grey-knights:rhino": ("Grey Knights Rhino", 1),
    "40k:grey-knights:razorback": ("Grey Knights Razorback", 1),
    "40k:grey-knights:land-raider": ("Grey Knights Land Raider", 1),
    "40k:grey-knights:stormraven-gunship": ("Grey Knights Stormraven Gunship", 1),
    "40k:grey-knights:venerable-dreadnought": ("Grey Knights Venerable Dreadnought", 1),
    "40k:grey-knights:terminator-squad": ("Grey Knights Terminator Squad", 5),
    "40k:grey-knights:brotherhood-ancient": ("Ancient", 1),
    "40k:grey-knights:brotherhood-apothecary": ("Apothecary Biologis", 1),
}

# (unit name, model count) → points after June 2025 Balance Dataslate
JUNE_2025_OVERRIDES: dict[tuple[str, int], int] = {
    ("Aggressor Squad", 3): 100,
    ("Heavy Intercessor Squad", 5): 100,
    ("Hellblaster Squad", 5): 110,
    ("Lootas", 5): 50,
}


def normalize_name(name: str) -> str:
    return re.sub(r"\s+", " ", name.strip().lower())


def parse_mfm(path: Path) -> dict[str, dict[int, int]]:
    """Parse MFM text into {unit_name: {model_count: points}}."""
    text = path.read_text(encoding="utf-8", errors="ignore")
    lines = [ln.strip() for ln in text.splitlines()]
    units: dict[str, dict[int, int]] = {}
    current: str | None = None

    model_re = re.compile(
        r"(?P<count>\d+)\s+models?\s+.*?(?P<pts>\d+)\s+pts",
        re.IGNORECASE,
    )
    single_re = re.compile(r"1\s+model\s+.*?(?P<pts>\d+)\s+pts", re.IGNORECASE)

    for line in lines:
        if not line or line.startswith("CODEX:") or "DETACHMENT" in line:
            continue
        if "FORGE WORLD" in line:
            current = None
            continue

        m = model_re.search(line)
        if m and current:
            count = int(m.group("count"))
            pts = int(m.group("pts"))
            units.setdefault(current, {})[count] = pts
            continue

        m1 = single_re.search(line)
        if m1 and current:
            units.setdefault(current, {})[1] = int(m1.group("pts"))
            continue

        if not re.search(r"\d+\s+pts", line, re.IGNORECASE) and len(line) > 2:
            cleaned = re.sub(r"[.\uFFFD]+", "", line).strip()
            if cleaned and not cleaned.isdigit():
                current = cleaned

    return units


def lookup_points(
    mfm: dict[str, dict[int, int]],
    name: str,
    model_count: int,
) -> int | None:
    if (name, model_count) in JUNE_2025_OVERRIDES:
        return JUNE_2025_OVERRIDES[(name, model_count)]

    if name in mfm and model_count in mfm[name]:
        pts = mfm[name][model_count]
        if (name, model_count) in JUNE_2025_OVERRIDES:
            return JUNE_2025_OVERRIDES[(name, model_count)]
        return pts

    target = normalize_name(name)
    for mfm_name, sizes in mfm.items():
        if normalize_name(mfm_name) == target and model_count in sizes:
            pts = sizes[model_count]
            key = (mfm_name, model_count)
            return JUNE_2025_OVERRIDES.get(key, pts)
    return None


def update_catalog(mfm: dict[str, dict[int, int]], dry_run: bool) -> list[str]:
    changes: list[str] = []
    points_key = "2025-06"

    for path in sorted(CATALOG_DIR.glob("*.json")):
        data = json.loads(path.read_text(encoding="utf-8"))
        for unit in data.get("units", []):
            uid = unit["id"]
            name = unit["name"]
            count = unit["modelCount"]
            if uid in UNIT_ALIASES:
                mfm_name, mfm_count = UNIT_ALIASES[uid]
            else:
                mfm_name, mfm_count = name, count

            new_pts = lookup_points(mfm, mfm_name, mfm_count)
            if new_pts is None:
                changes.append(f"MISSING\t{uid}\t{name}\t{count} models")
                continue

            old_pts = unit["basePoints"]
            if old_pts != new_pts or unit.get("pointsKey") != points_key:
                changes.append(f"UPDATE\t{uid}\t{name}\t{old_pts} → {new_pts}")
                unit["basePoints"] = new_pts
                unit["pointsKey"] = points_key
                unit["edition"] = "10th"

        if not dry_run:
            path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")

    manifest_path = REPO / "Resources" / "Catalogs" / "manifest.json"
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    new_manifest = {
        "version": "2026.06.2",
        "generatedAt": "2026-06-23",
        "pointsKey": points_key,
        "attribution": (
            "Points from Games Workshop Munitorum Field Manual (June 2025). "
            "Unofficial fan reference — verify before events."
        ),
        "games": manifest.get("games", ["40k"]),
    }
    if not dry_run:
        manifest_path.write_text(json.dumps(new_manifest, indent=2) + "\n", encoding="utf-8")
    changes.append(f"MANIFEST\tversion → {new_manifest['version']}")

    return changes


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--mfm", type=Path, default=DEFAULT_MFM)
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    if not args.mfm.is_file():
        print(f"MFM file not found: {args.mfm}", file=sys.stderr)
        return 1

    mfm = parse_mfm(args.mfm)
    changes = update_catalog(mfm, dry_run=args.dry_run)
    for line in changes:
        print(line)

    missing = sum(1 for c in changes if c.startswith("MISSING"))
    updates = sum(1 for c in changes if c.startswith("UPDATE"))
    print(f"\n{updates} updates, {missing} unmatched units", file=sys.stderr)
    return 1 if missing else 0


if __name__ == "__main__":
    raise SystemExit(main())
