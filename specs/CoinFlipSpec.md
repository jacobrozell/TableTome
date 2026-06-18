# Coin Flip Spec — Board Side Picker

## User Story

As a Spearhead defender setting up a game, I flip a fair coin to decide which side of the board to play on when neither player has a preference.

## Supported boards

| Board | Side A | Side B |
|-------|--------|--------|
| Fire and Jade | Aqshy (Fire) | Ghyran (Jade) |
| Sand and Bone | Ossia (Sand) | Dolorum (Bone) |
| City of Ash | Ashen Bastion | Shattered Crossroads |

## Rules context

- The **defender** chooses the board side after attacker/defender is decided.
- Each board has its own twist deck — match the deck to the chosen side.
- This is a table convenience — not an official GW randomizer. Either player can call for a flip.

## Behavior

| Requirement | Detail |
|-------------|--------|
| Board picker | Menu: Fire and Jade, Sand and Bone, City of Ash |
| Direct selection | Tap either side chip to choose without flipping |
| Odds | Strict 50/50 between the two sides of the selected board (coin flip only) |
| RNG | `SystemRandomNumberGenerator` via `Bool.random(using:)` |
| Persistence | None — result is session-only; checklist toggle is separate |
| Re-flip | Allowed; each tap produces a new independent flip |
| Board change | Clears the current side selection; picker stays editable after a flip |
| Checklist | Does **not** auto-complete “Defender chooses realm side” |

## Flow

```
Guided Match → Realm Battlefield step
  or Battle Tracker (round 1 deployment)
  → Board Side coin flip card
  → Select battlefield (Fire and Jade, Sand and Bone, or City of Ash)
  → Tap a side chip to choose directly, or tap “Flip Coin” for a fair tie-break
  → See result (e.g. Shattered Crossroads)
  → Mark deployment checklist step when done
```

## Architecture

```
Domain/
  Models/SpearheadBattlefield.swift  — Fire and Jade / Sand and Bone
  Models/BattlefieldSide.swift       — Aqshy, Ghyran, Ossia, Dolorum labels
  Engines/CoinFlipEngine.swift       — flip(for:generator:) → BattlefieldSide

DesignSystem/
  RealmSideCoinFlipCard.swift        — board picker, flip button, result, side labels

Features/GuidedMatch/
  MatchStepDetailView.swift          — realm-battlefield step
  BattlePhaseTrackerView.swift       — round 1 deployment section
```

Domain stays free of SwiftUI. Randomness is testable via injected `RandomNumberGenerator`.

## UI

- Card title: “Board Side”
- Segmented picker for battlefield
- Caption updates per board (50/50 between that board’s two sides)
- Two side chips with winner highlight after flip
- Primary button: “Flip Coin” (disabled briefly while animating)
- Reduce Motion: skip flip animation; show result immediately
- VoiceOver: announce result after each flip

## Accessibility

| Control | Identifier |
|---------|------------|
| Screen region | `coinFlip.card` |
| Battlefield picker | `coinFlip.battlefieldPicker` |
| Flip button | `coinFlip.flip` |
| Result | `coinFlip.result` |
| Side chips | `coinFlip.side.{sideId}` |

## Out of scope

- Persisting last flip or board choice across app launches
- Generic heads/tails coin
- Tie-breaking or best-of-three
- Linking flip result to twist deck selection

## Related specs

- [GuidedMatchSpec.md](GuidedMatchSpec.md) — match setup & deployment
- [DiceRollerSpec.md](DiceRollerSpec.md) — separate dice simulation feature

## Verification

| Field | Value |
|-------|-------|
| Target release | v0.3 |
| Last verified | 2026-06-17 |
| Status | **Implemented** |
| Code paths | `Domain/Models/SpearheadBattlefield.swift`, `Domain/Models/BattlefieldSide.swift`, `Domain/Engines/CoinFlipEngine.swift`, `DesignSystem/RealmSideCoinFlipCard.swift`, `Features/GuidedMatch/MatchStepDetailView.swift`, `Features/GuidedMatch/BattlePhaseTrackerView.swift`, `Tests/Unit/CoinFlipEngineTests.swift` |
