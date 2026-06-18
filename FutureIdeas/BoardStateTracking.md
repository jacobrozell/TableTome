# Board State Tracking — Objectives, Twists & Battle Tactics

Non-authoritative backlog. Promote to `specs/` when behavior locks.

**Status:** Not started (2026-06-17)

---

## Problem

At end of turn, players score VP from **objectives held** and **battle tactics completed**, but the app only offers coarse quick-add buttons (`+1 objective`, `+1 tactic`) with no link to the actual board or cards in play.

Round-opener reminders (`BattleRoundChecklist`, `StartOfRoundAbilitiesBanner`) nudge players to draw a twist and refresh battle tactics, but nothing tracks **which twist is active this round** or **what is in each player's hand**.

New players forget scoring breakpoints (any objective vs two+ vs majority) and lose track of personal battle tactic cards vs shared twist effects.

---

## Goal

Help players **track table state** tied to the selected realm board, then **coach scoring and reminders** from that state — without replacing physical cards or requiring licensed card text in v1.

---

## Scope (phased)

| Phase | What | Why |
|-------|------|-----|
| **v1 — Objective control** | Per-board objective list; tap to assign holder (P1 / P2 / contested / none) | Derive end-of-turn VP suggestions; show "you hold 2 of 4" at a glance |
| **v2 — Active twist** | Record this round's twist (user-entered name or pick from side deck list) | Reminders can reference underdog-favouring effects; round history |
| **v3 — Battle tactic hands** | Track 3 cards per player: in hand / used as command / completed for VP | End-of-turn nudge for incomplete tactics; priority-rule coaching |
| **v4 — Smart coaching** | End-of-turn banner: suggested VP breakdown + incomplete tactics + objective deltas | Replaces guesswork behind quick-add buttons |

**Out of v1:** objective positions on a visual board map, auto-detect control from miniatures, full card text catalog (licensing).

---

## v1 — Objective control (foundation)

### Board-linked objective catalog

Add bundled metadata keyed by `SpearheadBattlefield` + `BattlefieldSide` (objective count and layout differ per board; City of Ash differs from Fire and Jade).

Each objective entry:

- Stable `id` (e.g. `fire-and-jade:aqshy:behemat`)
- Display `name` (godbeast name from the printed board — research from official battleplan / board art)
- Optional `sortOrder` for consistent UI list

**Domain:** new `BattlefieldObjective` + `BattlefieldObjectiveCatalog` in `Domain/Models/`. No SwiftUI.

**Content:** extend rules bundle JSON (same pattern as `spearhead-catalog-v1.json`) — summaries only, no GW art.

### Match state

Extend `BattleTrackerState` (or nested struct) with:

```swift
// objectiveId → holder
public enum ObjectiveHolder: String, Codable, Sendable {
    case none
    case playerOne
    case playerTwo
    case contested
}
```

Default all objectives to `.none` when match starts; reset not required mid-game unless board changes (board change should warn + clear).

Wire through `MatchSyncSnapshot` so two-phone sync stays consistent.

### UI

- **Setup / Battlefield tab:** objective list for the chosen side; tap cycles holder (or P1 | contested | P2 picker).
- **End of turn:** read-only summary on Turn tab — "You hold 2 objectives (Behemat, Droggz)" + suggested VP chips mirroring `spearhead-scoring` rules:
  - +1 any objective
  - +1 two or more
  - +1 more than opponent
- Keep existing `VictoryPointsCard` quick-add; optionally pre-fill suggestion as tappable chips (user confirms — table state may lag reality).

### Scoring helper (Domain)

Pure function:

```swift
ObjectiveScoring.suggestedVP(
    control: [String: ObjectiveHolder],
    objectiveIds: [String],
    scoringPlayerIsOne: Bool
) -> Int
```

Unit-test against rules in `Resources/Rules/rules-v1.json` scoring section.

---

## v2 — Active twist card

- After `drawTwistCard` checklist step: prompt to enter or pick twist name from a **side-specific deck list** (names only — no card body text in v1).
- Store `activeTwistCardId` + `activeTwistRound` on tracker state.
- Show on Turn tab while round is active; clear when round advances.
- Future: tie underdog callouts to twist reminder copy (already in glossary).

---

## v3 — Battle tactic hands

Per player, track up to 3 slots:

| Slot | Status |
|------|--------|
| In hand |
| Used as command (card consumed) |
| Completed for VP (card scored) |
| Empty | |

User-entered labels or pick-from-deck-list (no licensed text). Aligns with existing `+1 tactic` quick-add — later replace naive +1 with completion flow.

Priority rule coaching (seizing initiative → may not refresh) stays in guides; optional link when refresh blocked.

---

## Dependencies & touchpoints

| Area | Today | Change |
|------|-------|--------|
| Board selection | `BattlefieldSide`, coin flip / match setup | Feed objective catalog lookup |
| VP | `VictoryPointsCard`, `BattleTrackerState` VP fields | Suggested VP from control state |
| Round opener | `BattleRoundChecklist` checkboxes | Twist + tactic *identity*, not only step done |
| Sync | `MatchSyncSnapshot` | Include objective control + card state |
| Rules | `spearhead-scoring` in `rules-v1.json` | Scoring helper tests |
| Licensing | `FutureIdeas/README.md` battle tactic browser note | User labels / deck lists only in v1 |

---

## Open questions

1. **Objective names per board** — confirm godbeast names and counts from official battleplans for all 6 sides before locking JSON.
2. **Contested vs held** — Spearhead scores *holding* at end of turn; contested may still matter for abilities. v1: holder enum includes contested; scoring counts only uncontested control unless rules say otherwise.
3. **Board diagram** — list-first v1; optional schematic later (no GW board art).
4. **Card text** — v1 user-entered / pick-from-list; full text needs licensing review.

---

## Promote to `specs/` when

- Objective catalog verified for all Spearhead boards.
- v1 UX scoped (list vs diagram, sync fields, migration for `BattleTrackerState`).
- Scoring suggestion behavior agreed (suggest-only vs auto-apply).

---

## Related code (today)

- `DesignSystem/VictoryPointsCard.swift` — manual VP quick-add
- `Domain/Models/BattleTracker.swift` — `BattleTrackerState`
- `Domain/Models/BattlefieldSide.swift` / `SpearheadBattlefield.swift` — board context
- `Domain/Models/BattleRoundChecklist.swift` — twist + tactic *steps*
- `Domain/Models/MatchSyncSnapshot.swift` — multi-device sync
- `Resources/Rules/rules-v1.json` — scoring + contest rules
