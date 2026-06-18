# Rules Reference Spec

## User Story

As a player at the table, I browse offline rule sections for Spearhead and core combat without network access.

## IA

- Filter by category: All | Core | Spearhead | Glossary
- Search: case-insensitive title + content match (client-side)
- Detail: scrollable section with related links

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

## Future

- Deep link to section by ID
- Roll evaluator prefill from combat-sequence

## Verification

| Field | Value |
|-------|-------|
| Target release | v0.1 |
| Last verified | 2026-06-17 |
| Commit | (AoS core + Spearhead rules expansion) |
| Code paths | `Features/RulesReference/`, `Tests/Unit/RulesReferenceViewModelTests.swift` |
