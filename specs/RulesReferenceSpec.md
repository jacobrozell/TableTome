# Rules Reference Spec

## User Story

As a player at the table, I browse offline rule sections for Spearhead and core combat without network access.

## IA

- Category filter is **scoped to the active game system** — only categories present in that system's `ruleSections` (see `DataSchemaSpec.md` naming table)
- Search: case-insensitive title + content match (client-side), within the selected game system
- Detail: scrollable section with related links (same game system only)

| Game system | Category chips |
|-------------|----------------|
| `aos-spearhead` | All \| Core \| Spearhead \| Glossary |
| `wh40k-10e-cp` | All \| Core \| Combat Patrol \| Glossary |
| `wh40k-11e` | All \| Core \| Glossary |
| `sc-tmg` | All \| Core \| Glossary |

## v0.2 Content Scope (AoS Spearhead)

### Core rules

| Section ID | Topic |
|------------|-------|
| combat-sequence | Hit / wound / save / damage |
| attack-modifiers | Modifier caps, fast dice |
| damage-sequence | Wards, allocation, slain models |
| turn-structure | Seven phases per turn |
| abilities-core | Rules of One, ability timing |
| visibility-combat-range | Line of sight, 3" combat range |
| movement-phase | Normal move, Run, Retreat, coherency, terrain |
| shooting-phase | Shoot ability, range, variable attacks |
| charge-phase | Charge roll, ½" arrival |
| combat-phase-fight | Fight sequence, pile-in |
| weapon-abilities | Crit, Shoot in Combat, Anti-, Charge +1 |
| strike-first-last | Fight order |
| picking-targets | Target eligibility, mixed loadouts |

### Spearhead format

| Section ID | Topic |
|------------|-------|
| spearhead-overview | Mode summary |
| spearhead-format | 4 rounds, roster structure, vs Combat Patrol |
| spearhead-deployment | Board, terrain, reinforcements |
| spearhead-battle-round | Round opener |
| spearhead-scoring | VP and battle tactics |

### Glossary sections

| Section ID | Topic |
|------------|-------|
| glossary-contest | Objective contesting |
| glossary-objective-control | Control characteristic |

Glossary chips (`SpearheadRulesGlossary`) cover additional terms: combat range, retreat, charge, fight, strike-first/last, critical hit, reinforcements, etc.

## v0.1 Content Scope (superseded)

| Section ID | Category |
|------------|----------|
| combat-sequence | core |
| attack-modifiers | core |
| damage-sequence | core |
| spearhead-overview | spearhead |
| spearhead-scoring | spearhead |
| spearhead-battle-round | spearhead |
| glossary-contest | glossary |

## v0.3 Content Scope (40k Combat Patrol — `wh40k-10e-cp`)

Bundled in `rules-v1.json` under game system `wh40k-10e-cp`. Section ids use **`10e-*` (core)**, **`cp-*` (format)**, **`glossary-*-10e` / `glossary-cp-*` (glossary)** — never reuse AoS unprefixed ids or `11e-*` ids. See `specs/40k10eCombatPatrolSpec.md`.

### Core rules (`category: core`, id prefix `10e-`)

| Section ID | Topic |
|------------|-------|
| 10e-overview | 10th Edition overview |
| 10e-turn-overview | Command-first turn structure |
| 10e-command-phase | Command phase, battle-shock |
| 10e-attack-sequence | Hit / wound / save / damage |
| 10e-shooting | Shooting phase |
| 10e-charge-fight | Charge and Fight phases |
| 10e-movement | Movement phase |
| 10e-battle-shock | Battle-shock tests |
| 10e-oc | Objective Control |
| 10e-cover-concealment | Cover and concealment |

### Combat Patrol format (`category: combatPatrol`, id prefix `cp-`)

| Section ID | Topic |
|------------|-------|
| cp-overview | Mode summary |
| cp-pre-battle | Pre-battle sequence (11 GW steps) |
| cp-securing | Securing objective markers |
| cp-reserves | CP reserves timing |
| cp-battle-ready | Battle Ready +10 VP |
| cp-missions | Six missions overview |
| cp-scoring | Primary/secondary VP, round 5 second player |

### Glossary (`category: glossary`)

| Section ID | Topic |
|------------|-------|
| glossary-cp-secure | Securing objectives |
| glossary-cp-patrol-squads | Patrol Squads splits |
| glossary-cp-battle-ready | Battle Ready |
| glossary-cp-leaders | Attached Leaders |
| glossary-cp-reserves | Deep Strike / reserves (CP timing) |
| glossary-oc-10e | Objective Control (10e) |

Glossary chips: `CombatPatrolRulesGlossary` — same terms, links to section ids above.

## v0.4 Content Scope (40k 11th Edition — `wh40k-11e`)

Already in bundle. All section ids prefixed **`11e-*`** (core) or **`glossary-*-11e`** / mode-specific glossary ids. No Spearhead or Combat Patrol category.

## Future

- Deep link to section by ID
- Roll evaluator prefill from combat-sequence

## Verification

| Field | Value |
|-------|-------|
| Target release | v0.1 (AoS); v0.3 (CP) |
| Last verified | 2026-06-17 |
| Commit | (AoS core + Spearhead rules expansion; CP spec promoted) |
| Code paths | `Features/RulesReference/`, `Domain/Models/GameSystemRulesLabels.swift`, `Tests/Unit/RulesReferenceViewModelTests.swift` |
