# Coin Flip Spec — Realm Side Picker

## User Story

As a Spearhead defender setting up the Fire and Jade board, I flip a fair coin to decide between Aqshy (Fire) and Ghyran (Jade) when neither player has a preference.

## Rules context

- The **defender** chooses the realm side after attacker/defender is decided.
- The board has two sides: **Aqshy** (Fire) and **Ghyran** (Jade).
- Players should match their twist deck to the chosen side.
- This is a table convenience — not an official GW randomizer. Either player can call for a flip.

## Behavior

| Requirement | Detail |
|-------------|--------|
| Odds | Strict 50/50 between Aqshy and Ghyran |
| RNG | `SystemRandomNumberGenerator` via `Bool.random(using:)` |
| Persistence | None — result is session-only; checklist toggle is separate |
| Re-flip | Allowed; each tap produces a new independent flip |
| Checklist | Does **not** auto-complete “Defender chooses realm side” |

## Flow

```
Guided Match → Realm Battlefield step
  or Battle Tracker (round 1 deployment)
  → Realm Side coin flip card
  → Tap “Flip Coin”
  → See Aqshy or Ghyran result
  → Mark deployment checklist step when done
```

## Architecture

```
Domain/
  Models/RealmSide.swift           — Aqshy / Ghyran labels
  Engines/CoinFlipEngine.swift     — flip(generator:) → RealmSide

DesignSystem/
  RealmSideCoinFlipCard.swift      — flip button, result, side labels

Features/GuidedMatch/
  MatchStepDetailView.swift        — realm-battlefield step
  BattlePhaseTrackerView.swift     — round 1 deployment section
```

Domain stays free of SwiftUI. Randomness is testable via injected `RandomNumberGenerator`.

## UI

- Card title: “Realm Side”
- Caption: fair 50/50 between Fire and Jade sides
- Two side chips: **Aqshy** (Fire) and **Ghyran** (Jade); winner highlighted after flip
- Primary button: “Flip Coin” (disabled briefly while animating)
- Result line: “Aqshy — Fire side” or “Ghyran — Jade side”
- Reduce Motion: skip flip animation; show result immediately
- VoiceOver: announce result after each flip

## Accessibility

| Control | Identifier |
|---------|------------|
| Screen region | `coinFlip.card` |
| Flip button | `coinFlip.flip` |
| Result | `coinFlip.result` |
| Aqshy label | `coinFlip.side.aqshy` |
| Ghyran label | `coinFlip.side.ghyran` |

## Out of scope

- Persisting last flip across app launches
- Generic heads/tails coin (realm-specific labels only)
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
| Code paths | `Domain/Models/RealmSide.swift`, `Domain/Engines/CoinFlipEngine.swift`, `DesignSystem/RealmSideCoinFlipCard.swift`, `Features/GuidedMatch/MatchStepDetailView.swift`, `Features/GuidedMatch/BattlePhaseTrackerView.swift`, `Tests/Unit/CoinFlipEngineTests.swift` |
