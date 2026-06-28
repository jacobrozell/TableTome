# Content schemas

Versioned JSON Schemas that define the contract for Tabletome's bundled game
content. They make "add a new edition / box set" a **data** operation gated by
a machine check — not a Swift edit. See
[`FutureIdeas/ArchitectureRefactorMasterPlan.md`](../../FutureIdeas/ArchitectureRefactorMasterPlan.md)
(Component D, Phase 0/4).

| Schema | Describes | Lives in |
|--------|-----------|----------|
| `game-systems-manifest-v1.schema.json` | Runtime wiring for every game system (id, play engine, publisher, catalog bundle, availability) | `Resources/Rules/game-systems-manifest-v1.json` |
| `catalog-v1.schema.json` | A system's factions → armies (box rosters), missions, guided-match steps | `Resources/Rules/<system>-catalog-v1.json` |
| `boxset-v1.schema.json` | Featured starter box sets (matchup, starter rosters, mission) | `Resources/Rules/<system>-boxsets-v1.json` (Phase 4+) |

## Validate before you commit

```bash
python3 Scripts/validate_content.py        # schema + cross-reference checks
```

The linter checks more than the schema: it confirms every catalog resolves,
ids are unique, and every box-set `armyId`/`factionId`/`missionId` actually
exists in its catalog. It runs in `Scripts/pre-commit` and in CI. Install
`jsonschema` (`pip install jsonschema`) for full schema validation on top of
the always-on cross-reference checks.

## Adding content (the cookbook)

- **New box set, existing edition:** add units to the catalog (via the
  sanctioned `Scripts/import_*.py`), add one object to the system's
  `*-boxsets-v1.json`, run the linter. Zero Swift.
- **New edition, existing engine:** add a manifest row + a catalog + a box-set
  file; flip `availability` to `available` when the featured matchup is
  playable end to end.

All content files must carry `"schemaVersion": 1`. v1 is additive-only; a
breaking change means a v2 schema + migration note.
