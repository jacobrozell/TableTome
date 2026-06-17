# Spearhead Content Spec — Scalable Army Data

## Goal

Adding Spearhead support should be **content-only** whenever possible — no app code changes for new armies.

## File Layout

```
Resources/Rules/
  spearhead-catalog-v1.json     # All factions + army roster (required for every army)
  Spearhead/armies/
    {army-id}.json              # Optional battle-tracker overlay per army
```

| Layer | File | Purpose |
|-------|------|---------|
| Catalog | `spearhead-catalog-v1.json` | Faction list, army metadata, regiment abilities, enhancements, match steps |
| Army detail | `Spearhead/armies/{army-id}.json` | Battle traits with phases + unit triggered abilities |

`BundledSpearheadCatalogRepository` merges catalog + detail files at load time. The UI always receives a fully merged `SpearheadArmy`.

Resources ship as a `Rules/` folder reference in the app bundle (`Rules/spearhead-catalog-v1.json`, `Rules/Spearhead/armies/{army-id}.json`). The repository searches both legacy flat paths and the `Rules/` prefix so tests and older bundles keep working.

## Adding a New Army (roster only)

1. Add a stub entry under the faction's `armies` array in `spearhead-catalog-v1.json`:
   - `id`, `name`, `general`, `tagline`, `playstyle`, `unitCount`, `roster`
   - `officialRulesURL` when available
2. Optionally add `regimentAbilities` and `enhancements` for guided match setup.
3. Run unit tests — no Swift changes required.

## Enabling Battle Tracker for an Army

1. Create `Resources/Rules/Spearhead/armies/{army-id}.json`:

```json
{
  "schemaVersion": 1,
  "armyId": "ironjawz-bigmob",
  "battleTraits": [
    {
      "id": "example-trait",
      "name": "Example Trait",
      "summary": "Short summary for lists",
      "phases": ["hero"],
      "usageLimit": "oncePerBattle",
      "declare": "What the player does",
      "effect": "What happens"
    }
  ],
  "units": [
    {
      "id": "megaboss",
      "name": "Megaboss",
      "abilities": [
        {
          "id": "waaagh",
          "name": "Waaagh!",
          "source": "Megaboss",
          "phases": ["hero"],
          "usageLimit": "eachTurn",
          "declare": "...",
          "effect": "...",
          "kind": "ability"
        }
      ]
    }
  ]
}
```

2. `armyId` must match the catalog entry id and the filename.
3. Ability ids are namespaced at runtime as `{armyId}:{unitId}:{abilityId}` — keep local ids short and unique within the unit.

## Content Coverage

`SpearheadArmy.contentCoverage` is computed automatically:

| Level | Meaning |
|-------|---------|
| `roster` | Name, general, playstyle — pickable in guided match |
| `matchSetup` | + regiment abilities and enhancements |
| `battleTracker` | + unit abilities or phased battle traits (detail file) |

## Validation (CI)

`SpearheadCatalogValidator` runs on every catalog load:

- Unique army ids
- Detail files reference valid army ids
- No duplicate namespaced ability ids per army
- Non-passive abilities must declare `phases`

## Migration Policy

1. Bump `schemaVersion` in affected files on breaking changes.
2. Document in this spec and `DataSchemaSpec.md`.
3. Add decoder migration only when required; prefer additive JSON fields.

## Verification

| Field | Value |
|-------|-------|
| Target release | v0.2 |
| Last verified | 2026-06-17 |
| Code paths | `Domain/Models/SpearheadArmyDetail.swift`, `Domain/UseCases/SpearheadArmyMerger.swift`, `Domain/UseCases/SpearheadCatalogValidator.swift`, `Data/JSON/BundledSpearheadCatalogRepository.swift`, `Resources/Rules/Spearhead/armies/` |
