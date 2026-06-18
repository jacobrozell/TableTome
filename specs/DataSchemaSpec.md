# Data Schema Spec

## Overview

All reference content ships as versioned JSON in `Resources/Rules/`. Loaded at launch via `BundledRulesRepository`.

## Top-Level Envelope

```json
{
  "schemaVersion": 1,
  "gameSystems": [ GameSystem ]
}
```

## Types

### GameSystem

| Field | Type | Required |
|-------|------|----------|
| id | string | yes — e.g. `aos-spearhead` |
| name | string | yes |
| tagline | string | yes |
| edition | string | yes |
| availability | enum | `available` \| `comingSoon` |
| gettingStartedSteps | [GuideStep] | yes |
| ruleSections | [RuleSection] | yes |
| externalLinks | [ExternalLink] | no |

### GuideStep

| Field | Type |
|-------|------|
| id | string |
| order | int |
| title | string |
| summary | string |
| body | string (markdown-lite: paragraphs only in v1) |
| tips | [string] |

### RuleSection

| Field | Type |
|-------|------|
| id | string — **must follow game-mode prefix rules below** |
| title | string |
| category | `core` \| `spearhead` \| `combatPatrol` \| `glossary` |
| order | int |
| content | string |
| relatedSectionIds | [string] |

## Rule Section Naming (by game mode)

Each `GameSystem` in `rules-v1.json` owns an isolated namespace. **Never reuse section ids across game systems** — even when topics sound similar (combat sequence, turn structure, etc.). Prefixed ids prevent cross-mode link breakage and keep search unambiguous.

| Game system | Core section ids | Format category | Format section ids | Glossary ids |
|-------------|------------------|-----------------|-------------------|--------------|
| `aos-spearhead` | Unprefixed legacy (`combat-sequence`, `turn-structure`, …) — AoS-only | `spearhead` | `spearhead-*` | `glossary-*` (AoS terms) |
| `wh40k-10e-cp` | `10e-*` | `combatPatrol` | `cp-*` | `glossary-*-10e`, `glossary-cp-*` |
| `wh40k-11e` | `11e-*` | — (matched play / Armageddon; no separate format category) | — | `glossary-*-11e`, `glossary-*` (11e-specific) |
| `sc-tmg` | `sc-*` | — | — | `glossary-*` (SC terms, e.g. `glossary-surge`) |

### Prefix rules

1. **Core** — edition/mode-specific shared rules (combat, phases, movement). Id prefix matches the row above.
2. **Format** — box-set or mission format rules (Spearhead rounds, CP missions). Use the format category + `spearhead-*` or `cp-*` ids.
3. **Glossary** — always `glossary-` prefix; add `-10e`, `-11e`, or `-cp` suffix when a term differs by edition/mode.
4. **`relatedRuleSectionId`** on `GuideStep` and **`relatedSectionIds`** on `RuleSection` must reference ids **within the same game system** only.
5. **Catalog `matchSteps`** `relatedRuleSectionId` uses the same prefixes for that game system's bundle.

### UI category filters

Category picker shows **only categories that appear in the active game system** (via `GameSystemRulesLabels.availableCategories`). Display labels are mode-specific:

| Category value | Label (examples by system) |
|----------------|------------------------------|
| `core` | Core |
| `spearhead` | Spearhead |
| `combatPatrol` | Combat Patrol |
| `glossary` | Glossary |

Implement in `GameSystemRulesLabels.categoryLabel(category:gameSystemId:)` and `availableCategories(gameSystemId:)`.

## Migration Policy

1. Bump `schemaVersion` on breaking changes.
2. Document in this file; add decoder migration in `Data/JSON/RulesDecoder.swift`.
3. CI test: decode bundled `rules-v1.json` fixture.

## Content Files

| File | Purpose |
|------|---------|
| `Resources/Rules/rules-v1.json` | Production bundle |
| `Resources/Rules/spearhead-catalog-v1.json` | Spearhead factions, armies, match steps |
| `Resources/Rules/combat-patrol-catalog-v1.json` | Combat Patrol factions, armies, missions, match steps |
| `Resources/Rules/Spearhead/armies/{army-id}.json` | Optional per-army battle-tracker overlay |
| `Resources/Rules/CombatPatrol/armies/{army-id}.json` | Optional CP army detail overlay |
| `Tests/Unit/Fixtures/rules-v1-minimal.json` | Test fixture |

## Verification

| Field | Value |
|-------|-------|
| Target release | v0.1 |
| Last verified | 2026-06-17 |
| Commit | (multi-mode rule naming) |
| Code paths | `Domain/Models/RulesContent.swift`, `Domain/Models/GameSystemRulesLabels.swift`, `Data/JSON/BundledRulesRepository.swift` |
