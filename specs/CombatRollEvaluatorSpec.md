# Combat Roll Evaluator Spec

## User Story

As a Spearhead player resolving combat at the table, I enter a weapon profile and the dice I rolled, then see a step-by-step hit → wound → save → damage evaluation with plain-language explanations.

## Flow

```
Spearhead detail / Guided Match
  → Roll Evaluator
  → Enter weapon profile (Hit, Wound, Save, Rend, Damage)
  → Enter dice rolled (hit, wound, save)
  → Optional modifiers
  → Evaluate
  → Step-by-step results + damage dealt
  → Link to Combat Attack Sequence rule section
```

## Engine

`Domain/Engines/CombatRollEngine.swift` — single-attack AoS 4e sequence:

| Step | Rules |
|------|-------|
| Hit | Unmodified 1 fails; modifiers capped ±1 |
| Wound | Unmodified 1 fails; modifiers capped ±1 |
| Save | Unmodified 1 fails; Rend subtracted; save modifiers not capped |
| Ward | Optional; after failed save; unmodified 1 fails |
| Damage | Dealt only if save fails and ward fails (if any) |

## Unit Matchup

Side-by-side attacker vs defender evaluation for starter-set armies:

- `Features/CombatRoll/UnitMatchupEvaluatorView.swift`
- `Features/CombatRoll/UnitMatchupEvaluatorViewModel.swift`
- `Domain/Models/CombatMatchupBuff.swift` — toggleable buffs from keywords/abilities + table modifiers
- `DesignSystem/MatchupSidePanel.swift`, `CombatBuffToggleRow`

Flow:

```
Pick attacker army / unit / weapon  |  Pick defender army / unit
  → Toggle active buffs (Ward, +1 hit, etc.)
  → Roll dice
  → Evaluate Damage: Liberators vs Grey Seer
```

Entry points:

- Warscroll card → Evaluate vs Unit…
- Guided Match / Spearhead guide → Unit Matchup
- Roll Evaluator → Unit Matchup link

## UI

- `Features/CombatRoll/CombatRollEvaluatorView.swift`
- `Features/CombatRoll/CombatRollEvaluatorViewModel.swift`
- `DesignSystem/RollStepCard.swift` — outcome card per step
- `DesignSystem/DiceValuePicker.swift` — 1–6 dice picker

Entry points (when `ReleaseSurface.showsRollEvaluator`):

- Spearhead game guide → Play → Roll Evaluator
- Guided Match → During the Battle → Roll Evaluator

## Accessibility

- Screen: `rollEvaluator.screen`
- Profile fields: `rollEvaluator.hitTarget`, etc.
- Dice: `rollEvaluator.hitRoll`, etc.
- Evaluate: `rollEvaluator.evaluate`
- Steps: `rollEvaluator.step.{id}`

## Release

| Surface | Roll Evaluator |
|---------|----------------|
| Release (v0.2) | ✅ |
| `-enable_full_product_surface` | ✅ |

## Simulated dice

Manual dice entry via `DiceValuePicker` remains available. **Roll in app** mode adds simulated d6 rolls — see [DiceRollerSpec.md](DiceRollerSpec.md). Dice tray (animation) is future work.

## Verification

| Field | Value |
|-------|-------|
| Target release | v0.2 |
| Last verified | 2026-06-17 |
| Code paths | `Features/CombatRoll/`, `Domain/Engines/CombatRollEngine.swift`, `Tests/Unit/CombatRollEngineTests.swift`, `Tests/Unit/CombatRollEvaluatorViewModelTests.swift` |
