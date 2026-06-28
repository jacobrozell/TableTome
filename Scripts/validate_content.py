#!/usr/bin/env python3
"""Tabletome content linter.

Validates bundled game content (manifest, catalogs, box sets) against the
versioned JSON Schemas in Resources/Schemas AND against cross-reference
invariants that a schema alone cannot express:

  * every manifest system resolves to a catalog file that exists and parses
  * every playEngine is a known archetype
  * faction ids and army ids are unique within a catalog
  * every box-set armyId / factionId resolves to its catalog
  * every box-set defaultMissionId resolves (when the catalog defines missions)

This is the author-facing gate that makes "add a new edition / box set"
a data-only operation. It converts the invariants previously checked only
by Swift unit tests (SpearheadCatalogCompletenessTests, *CatalogRosterAuditTests)
into a fast, Xcode-free check that runs in pre-commit and CI.

Pure stdlib — `jsonschema` is used for schema validation only if installed;
the cross-reference checks always run.

Usage:
    python3 Scripts/validate_content.py            # validate everything
    python3 Scripts/validate_content.py --quiet    # only print on failure
Exit code 0 = clean, 1 = one or more problems.
"""

from __future__ import annotations

import argparse
import json
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RULES_DIR = os.path.join(ROOT, "Resources", "Rules")
SCHEMA_DIR = os.path.join(ROOT, "Resources", "Schemas")

KNOWN_PLAY_ENGINES = {
    "phasedRound",
    "alternatingActivation",
    "gridSportDrive",
    "commandCardPool",
    "heroSkirmish",
    "rulesOnly",
}
KNOWN_AVAILABILITY = {"available", "comingSoon", "hidden"}

problems: list[str] = []


def fail(where: str, msg: str) -> None:
    problems.append(f"{where}: {msg}")


def load_json(path: str):
    try:
        with open(path, "r", encoding="utf-8") as handle:
            return json.load(handle)
    except FileNotFoundError:
        fail(os.path.relpath(path, ROOT), "file not found")
    except json.JSONDecodeError as exc:
        fail(os.path.relpath(path, ROOT), f"invalid JSON — {exc}")
    return None


# --- optional JSON Schema validation -------------------------------------

def try_schema_validation() -> None:
    try:
        import jsonschema  # type: ignore
    except ImportError:
        print("note: `jsonschema` not installed — running cross-reference "
              "checks only (pip install jsonschema for full schema validation).")
        return

    pairs = [
        ("game-systems-manifest-v1.json", "game-systems-manifest-v1.schema.json"),
    ]
    for data_name, schema_name in pairs:
        data = load_json(os.path.join(RULES_DIR, data_name))
        schema = load_json(os.path.join(SCHEMA_DIR, schema_name))
        if data is None or schema is None:
            continue
        try:
            jsonschema.validate(instance=data, schema=schema)
        except jsonschema.ValidationError as exc:  # type: ignore
            fail(data_name, f"schema — {exc.message} (at {list(exc.path)})")

    catalog_schema = load_json(os.path.join(SCHEMA_DIR, "catalog-v1.schema.json"))
    if catalog_schema is not None:
        for path in _catalog_paths():
            data = load_json(path)
            if data is None:
                continue
            try:
                jsonschema.validate(instance=data, schema=catalog_schema)
            except jsonschema.ValidationError as exc:  # type: ignore
                rel = os.path.relpath(path, ROOT)
                fail(rel, f"schema — {exc.message} (at {list(exc.path)})")


def _catalog_paths() -> list[str]:
    return [
        os.path.join(RULES_DIR, name)
        for name in sorted(os.listdir(RULES_DIR))
        if name.endswith("-catalog-v1.json")
    ]


# --- cross-reference invariants ------------------------------------------

def index_catalog(data: dict) -> tuple[set[str], set[str], set[str]]:
    """Return (faction_ids, army_ids, mission_ids) for a catalog dict."""
    faction_ids: set[str] = set()
    army_ids: set[str] = set()
    mission_ids: set[str] = set()
    for faction in data.get("factions", []):
        fid = faction.get("id")
        if fid:
            faction_ids.add(fid)
        for army in faction.get("armies", []):
            aid = army.get("id")
            if aid:
                army_ids.add(aid)
    for mission in data.get("missions", []):
        mid = mission.get("id")
        if mid:
            mission_ids.add(mid)
    return faction_ids, army_ids, mission_ids


def check_catalog_uniqueness(rel: str, data: dict) -> None:
    seen_factions: set[str] = set()
    for faction in data.get("factions", []):
        fid = faction.get("id")
        if not fid:
            fail(rel, "faction missing id")
            continue
        if fid in seen_factions:
            fail(rel, f"duplicate faction id '{fid}'")
        seen_factions.add(fid)
        seen_armies: set[str] = set()
        for army in faction.get("armies", []):
            aid = army.get("id")
            if not aid:
                fail(rel, f"army in faction '{fid}' missing id")
                continue
            if aid in seen_armies:
                fail(rel, f"duplicate army id '{aid}' in faction '{fid}'")
            seen_armies.add(aid)
            if not army.get("name"):
                fail(rel, f"army '{aid}' missing name")


def validate() -> None:
    try_schema_validation()

    manifest = load_json(os.path.join(RULES_DIR, "game-systems-manifest-v1.json"))
    if manifest is None:
        return

    if manifest.get("schemaVersion") != 1:
        fail("manifest", "schemaVersion must be 1")

    catalog_index: dict[str, tuple[set[str], set[str], set[str]]] = {}

    seen_system_ids: set[str] = set()
    for system in manifest.get("systems", []):
        sid = system.get("id", "<missing>")
        where = f"manifest[{sid}]"
        if sid in seen_system_ids:
            fail(where, "duplicate system id")
        seen_system_ids.add(sid)

        engine = system.get("playEngine")
        if engine not in KNOWN_PLAY_ENGINES:
            fail(where, f"unknown playEngine '{engine}'")

        availability = system.get("availability", "available")
        if availability not in KNOWN_AVAILABILITY:
            fail(where, f"unknown availability '{availability}'")

        bundle = system.get("catalogBundleName")
        if not bundle:
            if engine != "rulesOnly":
                fail(where, "missing catalogBundleName")
            continue

        catalog_path = os.path.join(RULES_DIR, f"{bundle}.json")
        data = load_json(catalog_path)
        if data is None:
            fail(where, f"catalogBundleName '{bundle}' does not resolve to a file")
            continue

        rel = os.path.relpath(catalog_path, ROOT)
        check_catalog_uniqueness(rel, data)
        catalog_index[sid] = index_catalog(data)

        box_bundle = system.get("boxSetBundleName")
        if box_bundle:
            _validate_box_sets(sid, box_bundle, catalog_index[sid])

    # Standalone box-set files (Phase 4+) keyed by gameSystemId.
    for name in sorted(os.listdir(RULES_DIR)):
        if not name.endswith("-boxsets-v1.json"):
            continue
        data = load_json(os.path.join(RULES_DIR, name))
        if data is None:
            continue
        sid = data.get("gameSystemId")
        if sid not in catalog_index:
            fail(name, f"gameSystemId '{sid}' has no catalog in the manifest")
            continue
        _validate_box_set_payload(name, data, catalog_index[sid])


def _validate_box_sets(sid: str, bundle: str, index) -> None:
    data = load_json(os.path.join(RULES_DIR, f"{bundle}.json"))
    if data is None:
        fail(f"manifest[{sid}]", f"boxSetBundleName '{bundle}' does not resolve")
        return
    _validate_box_set_payload(f"{bundle}.json", data, index)


def _validate_box_set_payload(rel: str, data: dict, index) -> None:
    faction_ids, army_ids, mission_ids = index
    for box in data.get("boxSets", []):
        bid = box.get("id", "<missing>")
        where = f"{rel}[{bid}]"
        for side in ("playerOne", "playerTwo"):
            sel = box.get(side)
            if not sel:
                fail(where, f"missing {side}")
                continue
            if sel.get("factionId") not in faction_ids:
                fail(where, f"{side}.factionId '{sel.get('factionId')}' not in catalog")
            if sel.get("armyId") not in army_ids:
                fail(where, f"{side}.armyId '{sel.get('armyId')}' not in catalog")
        for aid in box.get("armyIds", []):
            if aid not in army_ids:
                fail(where, f"armyIds entry '{aid}' not in catalog")
        mid = box.get("defaultMissionId")
        if mid and mission_ids and mid not in mission_ids:
            fail(where, f"defaultMissionId '{mid}' not in catalog missions")


def main() -> int:
    parser = argparse.ArgumentParser(description="Validate Tabletome bundled content.")
    parser.add_argument("--quiet", action="store_true", help="only print on failure")
    args = parser.parse_args()

    validate()

    if problems:
        print(f"content-lint: {len(problems)} problem(s) found:\n", file=sys.stderr)
        for problem in problems:
            print(f"  ✗ {problem}", file=sys.stderr)
        return 1

    if not args.quiet:
        catalogs = len(_catalog_paths())
        print(f"content-lint: OK — manifest + {catalogs} catalog(s) valid, "
              "all cross-references resolve.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
