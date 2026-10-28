# 06: Battle tracker → the Spearhead "Battle" screen

Back to [index](README.md). **This is the product.** It's used for 60–90 minutes at a table, often by people holding dice, in dim game-store light, passing a phone across the table. Everything here optimizes for **glanceability, one-handed taps, and never losing your place.**

Run BT WPs **strictly in order**. Nothing else may touch `Features/Play/`, `Features/GuidedMatch/BattleTracker*.swift`, or `DesignSystem/Shared/` while a BT WP is open.

---

## 0. How the tracker works today (read before changing anything)

### 0.1 Composition

`BattlePhaseTrackerView` (`Features/Play/Shared/BattlePhaseTrackerView.swift`) is embedded in `GuidedMatchView` when the hub tab is `.battle` (`embeddedBattleTracker(catalog:)` in `GuidedMatchView+BattleTracker.swift`). It owns about 30 `@State` values (notices, unit focus, victory, scroll targets) and three view models:

| Object | Type | Role |
|--------|------|------|
| `viewModel` | `BattlePhaseTrackerViewModel` (`PhasedRoundBattleTrackerViewModel` for Spearhead), built by `BattleTrackerViewModelFactory.make` | Round, phase, active player, VP, wounds, abilities, guide flow |
| `combatViewModel` | `UnitMatchupEvaluatorViewModel` | Combat resolver (attacker/defender, dice, results) |
| `multiAttackViewModel`, `batchCombatViewModel` | Multi-weapon / batch resolver | Combat tab extras |

Phone layout (`usesCompactBattleTrackerChrome == true`):

```
GuidedMatch hub chrome (status bar, hidden once battle shows)
└ compactTopChrome: BattleTrackerSectionTabBar [Setup | Turn | Combat | Army] + StickyPhaseHeader + collapse chevron
  └ ScrollView(compactLayout) → switch selectedSectionTab
      .setup  : NewMainTurnReminderBanner, StartOfRoundAbilitiesBanner, deploymentSection, roundOpenerChecklistSection
      .turn   : phasePlaybookSection, coachSection, guideSection, startOfRoundHelper, phaseActionNudgeSection,
                turnHandoffSection, scoringReminderSection, heroRoundOneSection, victoryPointsSection,
                roundOpenerSection, movementPhaseHelper   (+ quick actions / control panel for non-playbook systems)
      .combat : shootingPhaseHelper, damageUndoSection, combatPhaseHelper (PileInGuideCard), shootInCombatPhaseHelper, combatResolverSection
      .army   : armyTrackerSection (ArmyTrackerCard), passive abilities / all abilities, secondarySections
  └ compactBottomChrome: BattleTrackerPhaseDock [Phase ▾ | My Unit | Resolve | Score]
```

iPad uses `padTabbedTwoColumnLayout` (`BattlePhaseTrackerView+PadLayout.swift`), the same tabs split into two columns. Phone landscape uses collapsed chrome and a combat split (`+PhoneLandscapeCombat.swift`).

### 0.2 The flow engine (reuse it, don't rebuild it)

`viewModel.currentGuideStep: BattleFlowGuideStep?` (from `Domain/UseCases/BattleFlowGuide.swift`) is the single source of truth for **"what to do now"**. It has `kind`, `title`, `instruction`, `actionLabel`. `viewModel.completeCurrentGuideStep()` performs it.

| `kind` | When (Spearhead) | `completeCurrentGuideStep()` does |
|--------|------------------|-----------------------------------|
| `.deployment(step)` | Round 1 until all 5 `DeploymentChecklistStep`s are done (choose realm side → terrain → objectives → deploy → deployment abilities) | `setDeploymentStep(step, complete: true)` |
| `.roundOpener(step)` | Each round until the 5 `BattleRoundChecklistStep`s are done (first turn/priority → underdog → twist card → battle tactics → start-of-round abilities) | `setRoundChecklistStep(step, complete: true)` |
| `.turnPhase(phase)` | Hero → Movement → Shooting → Charge → Combat | `completePhasedRoundTurnPhase(phase)` → `advancePhase()` |
| `.turnPhase(.endOfTurn)` | End of turn | toggles `activePlayerIsOne`, sets phase to `.hero` |
| `.battleComplete` | `currentPhase == .endOfTurn` and `battleRound >= 4` | nothing (view presents victory) |

Other APIs the new UI calls:

| Need | API |
|------|-----|
| Jump to a phase | `viewModel.setPhase(_:)` |
| Main phases list | `viewModel.playContext.playEngine.mainPhases()` (Spearhead: deployment, hero, movement, shooting, charge, combat, endOfTurn) |
| Round label / count | `playEngine.roundLabel(round:)`, `playEngine.battleRoundCount()` (4) |
| Score | `viewModel.adjustVictoryPoints(playerIsOne:delta:reason:)` with `MatchVictoryPointsReason` `.manual/.objective/.tactic` |
| Wounds | `viewModel.setUnitWounds(key:remaining:)`, `viewModel.woundCapacity(for:unit:)`, `UnitWoundTracker.unitKey(armyId:unitId:)` |
| Abilities now | `viewModel.activeAbilities`, `viewModel.phaseArmyRuleOptions`, `viewModel.isUsed(_:)`, `viewModel.markUsed(_:)`, `viewModel.toggleShowAll()` |
| Underdog | `viewModel.underdogIsPlayerOne` |
| Start-of-round abilities | `viewModel.startOfRoundAbilities`, `viewModel.needsStartOfRoundAbilitiesPrompt` |
| Shooting units | `viewModel.shootingEligibleUnits`, `viewModel.shootInCombatEligibleUnits` |
| Names | `viewModel.playerOneName`, `.playerTwoName`, `.playerOneArmyLabel`, `.playerTwoArmyLabel`, `.armyName` (active) |
| Armies | `viewModel.playerOneArmy`, `.playerTwoArmy`, `.activeArmy`, `.army(withId:)` |
| Reset | `viewModel.resetTracker()` |
| Victory | `presentVictoryScreen()` (view extension, `+Victory.swift`) |

### 0.3 Problems we're fixing (audit A3, A4, A5, A6)

1. **Three stacked navigation layers** (hub tabs → section tabs → phase dock) plus collapse toggles.
2. **Up to 14 stacked sections** on the Turn tab, with 5 notice types that can appear together.
3. **Four ways to advance the phase** (guide card button, playbook "Next", dock "Next:" menu item, control panel).
4. **Score is buried:** VP lives mid-scroll on the Turn tab, behind a dock "Score" button that scrolls to it.
5. **Setup/round-opener checklists live on a separate tab,** so users miss them. The tracker compensates with "Round opener incomplete" notices.
6. **Wounds use tiny `Stepper`s** inside long lists.

---

## 1. Target design

### 1.1 Phone portrait (primary)

```
┌───────────────────────────────────────────┐
│ ‹  ①Azure   7   ROUND 2 / 4   5   Gold②  ⋯│ ← BT-02 Scoreboard header (tap → score sheet)
│    Bleak Host       ▲Underdog  Vigilant B.│   active player side glows in player color
├───────────────────────────────────────────┤
│  Hero · Move · Shoot · Charge · Combat · End│ ← BT-03 Phase rail (current = filled pill)
│   ✓      ●                                │   done phases ✓, tap to jump
├───────────────────────────────────────────┤
│ AZURE'S TURN · MOVEMENT PHASE             │ ← BT-05 "Now" panel (scrolls)
│ Move your units                    (serif)│
│ Move up to each unit's Move value. ⓘ      │
│                                           │
│ USE NOW (2)                               │
│ ┌───────────────────────────────────────┐ │
│ │ MOVEMENT · ONCE PER TURN              │ │
│ │ Rally Point                     [Use] │ │
│ │ Effect: …                             │ │
│ └───────────────────────────────────────┘ │
│ ┌───────────────────────────────────────┐ │
│ │ …                                     │ │
│ └───────────────────────────────────────┘ │
│ Show all abilities ›                      │
├───────────────────────────────────────────┤
│ [👥 Units] [🎲 Dice]  [ Start Shooting  ›]│ ← BT-04 Primary action bar
└───────────────────────────────────────────┘
```

### 1.2 Moments (full-panel states inside the Now area)

| Moment | Trigger | What fills the Now area | Action bar CTA |
|--------|---------|-------------------------|----------------|
| **Deployment** | `currentGuideStep.kind == .deployment` | BT-06 Deployment panel: 5-step checklist, current step expanded with instruction, realm side coin flip | step `actionLabel` → rewritten "Done, Next Step" → "Next" (final step: "Begin Round 1") |
| **Round start** | `.roundOpener` | BT-06 Round-start panel: "Round 2 begins", priority-roll picker, underdog callout, twist + tactics checklist, start-of-round abilities | "Next" / final: "Start {name}'s Turn" |
| **Phase** | `.turnPhase(phase)` (not endOfTurn) | BT-05 phase panel | "Start {next phase}" |
| **End of turn** | `.turnPhase(.endOfTurn)` | BT-05 end-of-turn panel: scoring prompt with inline quick-add buttons for the active player | "Pass to {other player}" → BT-07 handoff |
| **Round end** | `.startNextRound` (after BT-00) | Round summary: scoreboard, "Round {r} complete" | "Start Round {r+1}" |
| **Battle over** | `.battleComplete` | "Battle over" panel with final score | "See Results" → victory screen |

### 1.3 Phone landscape (BT-12)

Two columns: left 42% = scoreboard (stacked vertically) + phase rail (vertical list) + action bar; right 58% = Now panel. Tab bar stays hidden (existing `hidesTabBarInLandscapeBattle`).

### 1.4 iPad (BT-12)

Three regions: top scoreboard + phase rail spanning the width; left column (≤ 420 pt) = Now panel; right column = Units panel (always visible, BT-09) with the combat resolver opening as a sheet over it. Action bar pinned at the bottom of the left column.

### 1.5 Where the old tabs' content goes

| Old location | New location |
|--------------|--------------|
| Setup tab: deployment checklist | Deployment moment (BT-06) |
| Setup tab: round opener checklist, `NewMainTurnReminderBanner`, `StartOfRoundAbilitiesBanner` | Round-start moment (BT-06) |
| Turn tab: `BattlePhasePlaybookPanel` | Phase moment: Now panel (BT-05) |
| Turn tab: `BattleGuideCard` | Split: title/instruction → Now panel header; button → action bar (BT-04) |
| Turn tab: `VictoryPointsCard` | Scoreboard header (BT-02) + score sheet (BT-08) + end-of-turn inline quick-add (BT-05) |
| Turn tab: notices (handoff, scoring reminder, round opener, phase nudge, hero round one), coach card | Toasts or one-time `TTNotice` (BT-11) |
| Turn tab: `MovementActionPicker` | Now panel, Movement phase helper (BT-05) |
| Combat tab: `ShootingEligibleUnitsCard`, `PileInGuideCard`, `ShootInCombatEligibleUnitsCard` | Now panel phase helpers (BT-05) |
| Combat tab: `combatResolverSection` | Dice sheet (BT-10) |
| Combat tab: `damageUndoSection` | Toast with Undo (BT-11) |
| Army tab: `ArmyTrackerCard` | Units sheet / iPad column (BT-09) |
| Army tab: passive / all abilities | Now panel "Show all abilities" (BT-05) + Units sheet per-unit |
| Army tab: rosters / loadouts / reference links (`secondarySections`) | Battle menu ⋯ (BT-13) |
| Dock: Phase ▾ | Phase rail (BT-03) |
| Dock: My Unit | Units sheet → unit focus (BT-09) |
| Dock: Resolve | Action bar Dice (BT-04 → BT-10) |
| Dock: Score | Tap scoreboard (BT-02 → BT-08) |
| Toolbar: Reset, chrome collapse | Battle menu ⋯ (BT-13); collapse removed |

---

## BT-00: Turn and round flow correctness (Domain, verify first)

> **Suspected bug, confirm before coding.** For Spearhead, `BattleFlowGuide.currentStep` never returns `.startNextRound`. At `.endOfTurn`, `completePhasedRoundTurnPhase(.endOfTurn)` only toggles the active player and resets to Hero. `battleRound` changes only through the round `Stepper` in `BattleTrackerControlPanel`, and that panel is **hidden** when `showsSlimTurnTab` is true, which is the Spearhead playbook path. Also, `battleComplete` triggers at the **first** end of turn in round 4, before the second player has played.
>
> **Verify:** run with `-skip_onboarding -open_guided_match -open_battle_tracker`, complete deployment and the round opener, then tap through both players' turns to End of Turn twice. If the round shows **2** afterwards, the logic exists somewhere this audit missed. Then **skip BT-00** and write down where it lives. If the round stays at 1, do BT-00.

**Goal:** a Spearhead round = first player's turn + second player's turn, then the round opener for the next round. The battle ends only after the second turn of round 4.
**Files:** `Domain/Models/BattleTracker.swift` (`BattleTrackerState`), `Domain/UseCases/BattleFlowGuide.swift`, `Features/Play/PhasedRound/BattlePhaseTrackerViewModel+PhasedRound.swift`, `Features/Play/Shared/BattlePhaseTrackerViewModel+GuideFlow.swift`, `Tests/Unit/BattleFlowGuideTests.swift`, `Tests/Unit/BattleTrackerTests.swift`

### Steps
1. Add to `BattleTrackerState`: `public var firstTurnPlayerIsOneThisRound: Bool?`. Add it to `init` (default `nil`), to `CodingKeys` if the type declares them, and decode with `decodeIfPresent` in the custom `init(from:)` (around line 392). Encode it in `encode(to:)` if a custom encoder exists. Old saved states decode as `nil`.
2. **Set it when a turn starts from the round opener.** In `setRoundChecklistStep(_:complete:)` (PhasedRound extension), when the last opener step for the round becomes complete, set `trackerState.firstTurnPlayerIsOneThisRound = trackerState.activePlayerIsOne` and persist. Also set it at the end of deployment for round 1 if it's still `nil` (`setDeploymentStep` when the last deployment step completes).
3. **`BattleFlowGuide` (phased-round default branch):** replace
   ```swift
   if trackerState.currentPhase == .endOfTurn {
       if round >= roundCount { return battleCompleteStep(roundCount: roundCount) }
       return endOfTurnHandoffStep()
   }
   ```
   with
   ```swift
   if trackerState.currentPhase == .endOfTurn {
       let isSecondTurn = trackerState.firstTurnPlayerIsOneThisRound.map { $0 != trackerState.activePlayerIsOne } ?? false
       if isSecondTurn {
           if round >= roundCount { return battleCompleteStep(roundCount: roundCount) }
           return startNextRoundStep(round: round)
       }
       return endOfTurnHandoffStep()
   }
   ```
   Add `startNextRoundStep(round:)` → `BattleFlowGuideStep(kind: .startNextRound(round), title: "Round \(round) complete", instruction: "Both players have taken a turn. Next: the round \(round + 1) opener — priority roll, twist card, and battle tactics.", actionLabel: "Start Round \(round + 1)")`.
   **Legacy safety:** when `firstTurnPlayerIsOneThisRound == nil` (mid-match upgrade), `isSecondTurn` is false, so the old behavior holds for that round. It self-heals at the next round opener.
4. `completeCurrentGuideStep()` already handles `.startNextRound(round)`: `setBattleRound(round + 1)` + `setPhase(turnStartPhase())`. Also set `trackerState.firstTurnPlayerIsOneThisRound = nil` there (the next opener sets it again). The round opener for the new round then appears automatically, because `nextIncompleteRoundOpenerStep` keys off the round.
5. **End-of-turn toggle:** `completePhasedRoundTurnPhase(.endOfTurn)` keeps toggling the active player for the **first** turn only. It's only reached when the guide emitted `.turnPhase(.endOfTurn)`, i.e. not the second turn, so no change is needed. Verify with tests.
6. **Round opener "first turn" step:** the `firstTurnOrPriority` step must let the user **choose who goes first** (BT-06 UI calls `viewModel.setActivePlayer(isOne:)`). Round 1: default = attacker's choice (existing `matchState.attackerIsPlayerOne` + `firstTurnIsPlayerOne` logic in the engine `bootstrap`). Don't change the engine. Just make sure the UI exposes the choice.
7. **Tests** (add to `BattleFlowGuideTests`):
   - `testSpearheadEndOfFirstTurnHandsOffToSecondPlayer`
   - `testSpearheadEndOfSecondTurnStartsNextRound`
   - `testSpearheadBattleCompletesOnlyAfterSecondTurnOfRoundFour`
   - `testLegacyStateWithoutFirstTurnMarkerKeepsHandoffBehavior`
   - `testBattleTrackerStateDecodesWithoutFirstTurnMarker` (decode JSON missing the key).
8. Update `specs/BattleTableFlowSpec.md` with the round model and its Verification block.

### Acceptance
- [ ] Full 4-round Spearhead match plays start to finish through the guide alone (no manual round stepper).
- [ ] Victory appears after the 8th turn, not the 7th.
- [ ] All new tests pass. Existing CP/40k/StarCraft flows are untouched (they have their own branches).

---

## BT-01: Battle screen skeleton

**Goal:** a new layout path for Spearhead, selected by capability, that hosts the new regions. The legacy layout keeps serving the other systems.
**Depends on:** GM-01, SH-04, BT-00 (or a skip note)
**Files:** `Features/Play/Shared/BattlePhaseTrackerView.swift`, new `Features/Play/BattleScreen/BattlePhaseTrackerView+BattleScreen.swift`, new `Features/Play/BattleScreen/BattleScreenLayout.swift`

### Steps
1. Create folder `Features/Play/BattleScreen/`.
2. In `BattlePhaseTrackerView`, add:
   ```swift
   /// Spearhead (battle tactic deck systems) use the single-screen layout from ongoing/ui-overhaul/06.
   var usesBattleScreenLayout: Bool {
       supportsBattleTracker
           && viewModel.playContext.capabilities.showsBattleTacticDecks
           && !BattleScreenFeatureFlag.forcesLegacyLayout
   }
   ```
   `BattleScreenFeatureFlag.forcesLegacyLayout` reads `UserDefaults.standard.bool(forKey: "ui.battleScreen.legacy")` (Debug-only toggle in the gallery/settings debug section; always `false` in Release builds). It's the comparison/rollback switch while BT is in progress.
3. In `trackerScreen`, wrap the existing `Group { … }` so that `if usesBattleScreenLayout { battleScreen } else { /* existing Group unchanged */ }`. **All modifiers after the `Group`** (`BattleTrackerScreenChrome`, unit focus presentation, victory `fullScreenCover`, `onAppear`, `onChange`, `.task`) must keep applying to **both** branches. Move them onto a wrapping `Group` if needed.
4. `battleScreen` (in the new extension file):
   ```swift
   var battleScreen: some View {
       BattleScreenLayout(layoutContext: layoutContext, dynamicTypeSize: dynamicTypeSize) {
           battleScoreboard          // BT-02 (placeholder Text until then)
       } phaseRail: {
           battlePhaseRail           // BT-03
       } content: {
           battleNowContent          // BT-05/06 (placeholder: existing turnTabContent until BT-05)
       } actionBar: {
           battleActionBar           // BT-04
       } sidePanel: {
           battleUnitsPanel          // BT-09, iPad only
       }
       .ttScreenBackground()
       .environment(\.toastBottomInset, DesignTokens.Size.actionBarHeight)
   }
   ```
5. `BattleScreenLayout` is a generic container that arranges the five slots per §1.1/§1.3/§1.4. Phone portrait: `VStack(spacing: 0) { scoreboard; phaseRail; ScrollView { content }; actionBar }`. Landscape and iPad come in BT-12; until then, every context uses the portrait arrangement.
6. When embedded in Guided Match (`isEmbeddedInGuidedMatch`), the battle screen owns the whole area. GM-01 already hides the stage header in battle. Confirm no duplicate title or toolbar items appear.
7. The legacy `compactTopChrome` / `compactBottomChrome` / section tabs are **not rendered** in the new branch. Don't delete them (other systems use them).

### Acceptance
- [ ] Spearhead battle shows the 4-slot skeleton. The full-surface 40k/CP battle shows the legacy tracker unchanged.
- [ ] Debug toggle switches Spearhead back to legacy.
- [ ] Unit focus, victory cover and analytics `onAppear` still fire in the new branch.

---

## BT-02: Scoreboard header

```
┌─────────────────────────────────────────────────┐
│  ①  Azure             7  │ ROUND │  5             Gold  ② │
│     Bleak Host            │ 2 / 4 │         Vigilant Br.   │
│ ▔▔▔▔▔▔▔▔▔▔▔▔ (active underline, playerOne) ▔▔▔▔ │
└─────────────────────────────────────────────────┘
```

**Goal:** VP, round and whose turn it is are always visible. Tap opens scoring.
**Depends on:** BT-01
**Files:** new `DesignSystem/Shared/BattleScoreboardHeader.swift`; `Features/Play/BattleScreen/BattlePhaseTrackerView+BattleScreen.swift`

### API
```swift
struct BattleScoreboardHeader: View {
    struct Side: Equatable {
        let name: String
        let armyName: String
        let victoryPoints: Int
        let isActive: Bool
        let isUnderdog: Bool
        let isAttacker: Bool
    }
    let playerOne: Side
    let playerTwo: Side
    let round: Int
    let roundCount: Int
    var compact: Bool = false          // phone landscape / AX: single line
    let onTapScore: (_ isPlayerOne: Bool) -> Void
    let onTapRound: () -> Void         // opens battle menu round info (BT-13)
}
```

### Look
- Height `DesignTokens.Size.scoreboardHeight` (64) at default type; grows with Dynamic Type.
- Background: `TTColor.surface` + bottom 1 pt `stroke`. On iOS 26, `.glassEffect(.regular, in: .rect)` behind `#available`.
- Each side: `TTPlayerToken(isActive:)`, name `TTFont.headline` (1 line, truncation tail), army `TTFont.caption` inkSecondary (1 line), VP `TTFont.numericHero` in **player color** when active, `inkPrimary` otherwise, `.contentTransition(.numericText(value:))`.
- Active side: 3 pt underline in player color across that half, plus a `playerSoft` background wash. Animate the switch with `TTMotion.emphasis`.
- Center: eyebrow "ROUND", `"\(round) / \(roundCount)"` in `TTFont.numericMedium`. Optional tiny 4-dot round progress below (filled dots ≤ round).
- Underdog: `TTBadge("Underdog", tone: .warning, systemImage: "arrow.down.circle.fill")` under the name of `viewModel.underdogIsPlayerOne` side (only from round 2, when VP differ).
- Attacker: no badge here. Attacker/defender is setup info that lives in the battle menu.
- **AX sizes:** switch to two stacked rows (P1 row, P2 row) + round line; VP stays numericLarge.

### Wiring
- `round` = `viewModel.trackerState.battleRound`; `roundCount` = `viewModel.playContext.playEngine.battleRoundCount()`.
- `isActive` = `viewModel.trackerState.activePlayerIsOne == isPlayerOne`.
- `onTapScore` → presents the score sheet (BT-08) with that player preselected.
- Haptic `.ttHaptic(.scoreUp, trigger: totalVP)` is fired by the counter in BT-08, not here.

### Accessibility
- Each side is one button element: label "{name}, {army}, {vp} victory points{, active turn}{, underdog}", hint "Opens scoring". Ids: `battleTracker.scoreboard.playerOne` / `.playerTwo`.
- Center: label "Round {r} of {n}". Id `battleTracker.scoreboard.round`.
- Keep the old `battleTracker.vp.playerOne/Two` ids on the score sheet counters (BT-08).

### Acceptance
- [ ] VP updates animate. Active side switches on handoff.
- [ ] Fits iPhone SE portrait with names "Player 1"/"Player 2" and 2-digit VP.
- [ ] VoiceOver reads both sides and the round.

---

## BT-03: Phase rail

```
  Hero    Move    Shoot   Charge  Combat   End
  ✓       ●━━━━   ○       ○       ○        ○
```

**Goal:** see where you are in the turn at a glance, and jump phases without a menu.
**Depends on:** BT-01
**Files:** new `DesignSystem/Shared/BattlePhaseRail.swift`

### API
```swift
struct BattlePhaseRail: View {
    let phases: [BattleTurnPhase]          // mainPhases() minus .deployment
    let current: BattleTurnPhase
    let tone: TTTone                        // active player's tone
    var axis: Axis = .horizontal            // .vertical in phone landscape (BT-12)
    var isInteractive: Bool = true          // false in onboarding illustration
    let onSelect: (BattleTurnPhase) -> Void
}
```

### Look
- Height `DesignTokens.Size.phaseRailHeight` (44). `ScrollView(.horizontal)` with `scrollPosition` centered on the current phase, `scrollIndicators(.hidden)`.
- Each phase: short label (add `BattleTurnPhase.shortTitle` in **DesignSystem** as an extension, not Domain: Hero, Move, Shoot, Charge, Combat, End), `TTFont.buttonSmall`.
  - Done (index < current): `inkSecondary` label + small `checkmark` (tone.foreground).
  - Current: capsule `tone.solid` fill + `tone.onSolid` label + phase icon (add `BattleTurnPhase.systemImage` in DesignSystem: hero `sparkles` → use `wand.and.stars`, movement `figure.walk`, shooting `scope`, charge `bolt.horizontal`, combat `shield.lefthalf.filled`, endOfTurn `flag.checkered`).
  - Upcoming: `inkTertiary` label.
- Deployment is **not** in the rail. During deployment the rail shows a single "Deployment" capsule (current) instead.
- Phase change animation: `matchedGeometryEffect` on the current capsule (`TTMotion.emphasis`), plus `.ttHaptic(.phaseAdvanced, trigger: current)`.

### Behavior
- Tap a phase → `viewModel.setPhase(phase)`. Jumping **backward** is allowed (mistake correction). Jumping **forward over** phases shows no confirmation (tables move fast). The match log records phase changes already.
- Long-press a phase → shows `phase.playerFacingSummary(gameSystemId:)` in a popover (`.popover` on iPad, a small `TTNotice` sheet on phone).

### Accessibility
- The rail is an `.accessibilityElement(children: .contain)` labeled "Turn phases". Each phase is a button: "Movement Phase, current" / "Hero Phase, done" / "Charge Phase", hint "Jumps to this phase". Ids `battleTracker.phaseRail.{phase.rawValue}`, container `battleTracker.phaseRail`.
- Add an `accessibilityAdjustableAction` on the container: swipe up = next phase, down = previous.

### Acceptance
- [ ] Current phase always scrolled into view on iPhone SE.
- [ ] Tap jumps phases and the Now panel updates.

---

## BT-04: Primary action bar

```
┌─────────────────────────────────────────────┐
│  [ 👥 ]  [ 🎲 ]   [   Start Shooting Phase  › ] │
│  Units    Dice                                │
└─────────────────────────────────────────────┘
```

**Goal:** one obvious forward action, driven by `currentGuideStep`, plus two tool buttons. It replaces the guide card button, the playbook "Next" button, the dock, and the control panel advance.
**Depends on:** BT-01
**Files:** new `DesignSystem/Shared/BattlePrimaryActionBar.swift`; `Features/Play/BattleScreen/BattlePhaseTrackerView+BattleScreen.swift`

### API
```swift
struct BattlePrimaryActionBar: View {
    let primaryTitle: String
    let primarySystemImage: String?
    let primaryTone: TTTone                 // .brand normally, .player(next) for "Pass to …"
    var isPrimaryEnabled: Bool = true
    let onPrimary: () -> Void
    let onUnits: () -> Void
    let onDice: () -> Void
    var diceEnabled: Bool = true
}
```

### Look
- Height ≥ `DesignTokens.Size.actionBarHeight` (64) + bottom safe area. Background `barChromeBackground()` with a top 1 pt `stroke`.
- Left: two square 52 pt tool buttons (`raised` fill, radius `md`, icon + tiny caption `TTFont.caption`): **Units** (`person.3.fill`) and **Dice** (`dice.fill`). Ids `battleTracker.actionBar.units`, `battleTracker.actionBar.dice`.
- Right: `.ttPrimary` (or `.ttPlayer(isPlayerOne:)` for handoff) filling the remaining width. Title = mapped label (below), trailing `chevron.right`. Id `battleGuide.action` (**reuse the old guide-card id** so it stays stable). For `.battleComplete` use `battleGuide.complete` (**reuse**).
- AX sizes: tool buttons collapse into a single `ellipsis` menu button (Units / Dice), so the primary keeps ≥ 70% width.

### Label mapping (UI copy layer, keep Domain strings as fallback)

Map `currentGuideStep` to a better button title in a **DesignSystem-side** helper (`BattleActionCopy.swift`), so Domain stays untouched:

| `kind` | Button title | Icon | Tone |
|--------|--------------|------|------|
| `.deployment(step)` (not last) | "Next" | — | brand |
| `.deployment(.deploymentAbilities)` (last) | "Begin Round 1" | `flag.checkered` | brand |
| `.roundOpener(step)` (not last) | "Next" | — | brand |
| `.roundOpener(.startOfRoundAbilities)` (last) | "Start {firstPlayerName}'s Turn" | — | `.player(activePlayerIsOne)` |
| `.turnPhase(p)` where `p` not endOfTurn | "Start {nextPhase.shortTitle} Phase" (e.g. "Start Shooting Phase"); if `nextMainPhase` is endOfTurn: "End Turn" | — | brand |
| `.turnPhase(.endOfTurn)` | "Pass to {otherPlayerName}" | `arrow.left.arrow.right` | `.player(!activePlayerIsOne)` |
| `.startNextRound(r)` | "Start Round {r+1}" | `flag.checkered` | brand |
| `.battleComplete` | "See Results" | `trophy.fill` | brand |
| `nil` | "Next Phase" → `viewModel.advancePhase()` | — | brand |

Use `BattleTurnPhase.mainTurnPhases` / `playEngine.nextMainPhase(after:)` to find the next phase.

### `onPrimary` behavior
```swift
func performPrimaryAction() {
    guard let step = viewModel.currentGuideStep else { viewModel.advancePhase(); return }
    switch step.kind {
    case .battleComplete:
        if ReleaseSurface.showsMatchHistory { presentVictoryScreen() }
        dismissedBattleCompleteGuide = true
    case .turnPhase(.endOfTurn):
        presentTurnHandoff()            // BT-07; it calls completeCurrentGuideStep() on confirm
    default:
        viewModel.completeCurrentGuideStep()
    }
}
```
(This mirrors the existing `guideSection` closure in `BattlePhaseTrackerView.swift`, so behavior stays identical apart from the handoff interstitial.)

- Haptic: `.ttHaptic(.phaseAdvanced, trigger: primaryTapCount)`.
- Debounce: disable the primary button for 400 ms after a tap to prevent double-advance (people double-tap at tables).

### Acceptance
- [ ] Exactly one primary forward button on screen in every moment.
- [ ] Every guide step kind maps to a title (unit test `BattleActionCopyTests` for each row of the table).
- [ ] Double-tap advances only once.

---

## BT-05: "Now" panel (phase content)

**Goal:** show only what matters in this phase: a short heading, abilities usable now, and phase helpers.
**Depends on:** BT-03
**Files:** new `Features/Play/BattleScreen/BattleNowPanel.swift`; restyle `DesignSystem/Shared/BattlePhasePlaybookPanel.swift` (logic reused), `DesignSystem/UnitAbilityCard.swift` (GG-04), `DesignSystem/ShootingEligibleUnitsCard.swift`, `DesignSystem/ShootInCombatEligibleUnitsCard.swift`, `DesignSystem/Shared/BattleTrackerPhaseGuides.swift` (`PileInGuideCard`), `DesignSystem/MovementActionPicker.swift`, `DesignSystem/StartOfRoundAbilitiesBanner.swift`

### Layout (phase moment)
1. **Header** (not a card):
   - Eyebrow: "{ACTIVE NAME}'S TURN · {PHASE TITLE}" in the active player's color (`TTTone.player(...).foreground`).
   - Headline: `TTFont.title`, a short imperative per phase (new DesignSystem helper `BattleTurnPhase.headline`): Hero "Heroic actions & spells", Movement "Move your units", Shooting "Shoot", Charge "Declare charges", Combat "Fight", End of Turn "Score and wrap up".
   - One-line summary: `step.instruction` truncated to 2 lines (`lineLimit(2)`), with an ⓘ `.ttTertiary` "More" that expands to the full instruction plus `phase.playerFacingSummary(gameSystemId:)`.
2. **Use now** (`TTSectionHeader("Use Now (\(count))")`): `viewModel.activeAbilities` → `UnitAbilityCard` (GG-04 restyle) with `onMarkUsed` for once-per-battle, and `onResolveAttack` → Dice sheet prefilled (BT-10). `viewModel.phaseArmyRuleOptions` → `ArmyRuleOptionCard` under `TTSectionHeader("Army Picks")`.
3. **Phase helpers** (only for that phase, after abilities):
   - Movement: `MovementActionPicker` restyled as `TTSegmentedControl` (Normal / Run / Retreat) with a one-line consequence caption.
   - Shooting: `ShootingEligibleUnitsCard` → `TTSectionHeader("Can Shoot")` + compact unit rows (name, weapon count). Tap → Dice sheet with that unit as attacker (`handleArmyUnitSelection(armyId:unitId:preferredWeaponId:)` exists).
   - Combat: `PileInGuideCard` → collapsed `TTNotice(title: "Pile in", tone: .neutral)` with ⓘ expansion. `ShootInCombatEligibleUnitsCard` → unit rows like Shooting.
   - Start-of-round abilities (if `needsStartOfRoundAbilitiesPrompt`): shown in the **round-start moment** (BT-06), not here.
4. **Empty phase** (no abilities): a quiet `TTEmptyState`-style block (no buttons): icon for the phase, `emptyPhaseTitle` / `emptyPhaseDetail` from `BattlePhasePlaybookPanel` (move those two computed properties into a shared helper so both layouts use them).
5. **Show all abilities**: `.ttTertiary` row at the bottom → `viewModel.toggleShowAll()`. When on, the header eyebrow reads "ALL ABILITIES" and the button reads "Show this phase only".
6. **End of turn moment:** header "Score and wrap up". Below it, **inline scoring for the active player**: two large quick-add buttons using `VictoryPointsScoring` labels (`+1 objective`, `+1 tactic`) styled `.ttSecondary` with the player tone, plus a `TTCounter(.large)` bound to the active player's VP. Then "End-of-turn abilities" if any. This replaces `ScoringReminderNotice`.
7. Remove the playbook's own `advanceButton` in the new layout (the action bar owns it). Keep `BattlePhasePlaybookPanel` intact for the legacy layout.

### Copy
- Never show the raw `"\(count) available now"` + uppercase label. Use "Use Now (2)".
- Ability cards show the **source unit name** first (`ability.source`), so players know which model to look at.

### Acceptance
- [ ] Each Spearhead phase shows header + relevant abilities + helpers only.
- [ ] No inline notices appear in the Now panel except the one-time coach (BT-11).
- [ ] Marking an ability used updates its badge immediately.

---

## BT-06: Deployment and round-start moments

**Depends on:** BT-04
**Files:** new `Features/Play/BattleScreen/BattleDeploymentPanel.swift`, `Features/Play/BattleScreen/BattleRoundStartPanel.swift`; restyle `DesignSystem/Shared/DeploymentChecklistCard.swift`, `DesignSystem/Shared/RoundChecklistCard.swift`, `DesignSystem/Shared/RealmSideCoinFlipCard.swift`, `DesignSystem/StartOfRoundAbilitiesBanner.swift`, `DesignSystem/Shared/BattleTrackerPhaseGuides.swift` (`NewMainTurnReminderBanner`, `SeizingInitiativeCallout`)

### Deployment panel (`.deployment` steps, round 1)
```
BATTLEFIELD SETUP · STEP 2 OF 5
Set up terrain                          (serif)
✓ Defender chooses realm side   Jade
● Set up terrain
   Place the terrain shown on your realm board…  ⓘ
○ Place objectives
○ Deploy armies
○ Deployment abilities
```
- Vertical checklist of `DeploymentChecklistStep.allCases`. Done = ✓ (`success`), current = expanded with `step.detail` (2 lines + ⓘ) and any step-specific control, upcoming = dim.
- Step-specific control: `chooseRealmSide` embeds the restyled `RealmSideCoinFlipCard` (GM-04 §5) and shows the chosen side as a `TTBadge` on the done row.
- Tapping a **done** row un-completes it (`viewModel.setDeploymentStep(step, complete: false)`) after a confirmation (`confirmationDialog`): "Mark '{title}' as not done?".
- Action bar handles "Next" / "Begin Round 1".

### Round-start panel (`.roundOpener` steps)
```
ROUND 2 BEGINS
Priority roll                           (serif)
Both players roll a D6. Winner picks who goes first.
[ ① Azure goes first ] [ ② Gold goes first ]     ← ttPlayer buttons
▲ Gold is the underdog (5 vs 7 VP)               ← TTNotice(tone: .warning) when underdog
✓ Identify the underdog
○ Draw a twist card  (shared deck from your battlefield pack)
○ Refresh battle tactic hands
○ Start-of-round abilities (2)
```
- Title per round: "Round {r} begins" (eyebrow) + current step title (serif).
- `.firstTurnOrPriority`: round 1 → copy "The attacker chooses who goes first." Round > 1 → "Roll off. The winner chooses who goes first." Both show two `.ttPlayer` buttons calling `viewModel.setActivePlayer(isOne:)`. The selected one is solid, the other secondary. Default = current `activePlayerIsOne`. Ids `battleTracker.roundStart.firstPlayer.playerOne/Two`. `SeizingInitiativeCallout` → ⓘ disclosure under the buttons (round > 1 only).
- `.identifyUnderdog`: auto-filled text "{name} is the underdog ({a} vs {b} VP)" or "No underdog: scores are tied" from `viewModel.underdogIsPlayerOne`. (Auto-completion already exists in `syncAutoCompletions`.)
- `.drawTwistCard` / `.drawBattleTactics`: `step.title(round:)` as the row title. The long `detail(round:)` text sits behind ⓘ, with a short one-liner shown instead (new DesignSystem helper `BattleRoundChecklistStep.shortDetail(round:)`): twist "Draw 1 card from the shared twist deck."; tactics round 1 "Each player draws 3 from their own battle tactic deck."; later rounds "Discard any, then draw back up to 3."
- `.startOfRoundAbilities`: list `viewModel.startOfRoundAbilities` as compact `UnitAbilityCard`s; if none, "No start-of-round abilities this round" and the step auto-completes on Next.
- `NewMainTurnReminderBanner` and `StartOfRoundAbilitiesBanner` are **not rendered** in the new layout (their content is here).
- Haptic `.ttHaptic(.handoff, trigger: round)` when the panel first appears for a new round. Announce "Round {r} begins" to VoiceOver.

### Acceptance
- [ ] Round 1: deployment → round opener → Hero with no tab switching.
- [ ] Round 2+: round-start panel appears automatically after the round advances (BT-00).
- [ ] Choosing who goes first changes the active player and the scoreboard underline.

---

## BT-07: Turn handoff interstitial

**Goal:** the "pass the phone" moment is explicit and satisfying, and it prevents the next player from accidentally acting during the previous turn.
**Depends on:** BT-04
**Files:** new `Features/Play/BattleScreen/BattleTurnHandoffView.swift`; replaces `turnHandoffSection` / `TurnHandoffNotice` in the new layout

```
┌──────────────────────────────────┐
│                                  │
│           ②  (96pt token)        │
│                                  │
│        Gold's turn               │ ← TTFont.display in player color
│   Round 2 · Pass the device      │
│                                  │
│   Azure scored 2 this turn       │ ← optional, from VP delta since turn start
│   Score: Azure 7 – 5 Gold        │
│                                  │
│  [      Start Gold's Turn     ]  │ ← ttPlayer(isPlayerOne: false)
│    Back to End of Turn           │ ← ttTertiary
└──────────────────────────────────┘
```

### Steps
1. Present as `.fullScreenCover` (phone) / `.sheet` with `.presentationDetents([.large])` (iPad) driven by `@State var showsTurnHandoff = false` in `BattlePhaseTrackerView`. `presentTurnHandoff()` sets it.
2. Background: `TTColor.canvas` with a large soft radial gradient in the **next** player's soft color.
3. "Start {name}'s Turn" → `viewModel.completeCurrentGuideStep()` (toggles player, phase → Hero), dismiss, `.ttHaptic(.handoff, …)`. Id `battleTracker.handoff.start`.
4. "Back to End of Turn" → dismiss only. Id `battleTracker.handoff.back`.
5. VP delta: capture `turnStartVP` (both players) when a turn starts (on `activePlayerIsOne` change) in `@State`. Show "{name} scored {n} this turn" if n > 0.
6. Reduce Motion: no token scale-in. Otherwise the token springs in (`TTMotion.emphasis`).
7. VoiceOver: focus moves to the title ("Gold's turn"). Use `@AccessibilityFocusState`.
8. When `.startNextRound` or `.battleComplete` is the step instead, **no handoff** is shown (the action bar handles those directly).

### Acceptance
- [ ] Ending turn 1 shows the handoff. Confirming starts the other player's Hero phase.
- [ ] Cancelling leaves state unchanged.

---

## BT-08: Score sheet

**Goal:** fast, error-proof VP entry for both players.
**Depends on:** BT-02
**Files:** new `Features/Play/BattleScreen/BattleScoreSheet.swift`; `DesignSystem/Shared/VictoryPointsCard.swift` (legacy keeps it)

```
┌──────────────────────────────────┐
│ Score                        (✕) │ ← TTSheetHeader
│ Round 2 of 4 · Azure's turn      │
│ ┌──────────────┐┌──────────────┐ │
│ │ ① Azure      ││ ② Gold       │ │
│ │  [−]  7  [+] ││  [−]  5  [+] │ │ ← TTCounter(.large), player tones
│ │ [+1 Objective]││[+1 Objective]│ │
│ │ [+1 Tactic]   ││[+1 Tactic]   │ │
│ └──────────────┘└──────────────┘ │
│ Spearhead scoring rules ›        │ ← link to scoringRuleSectionId
└──────────────────────────────────┘
```

### Steps
1. `.sheet` with `.presentationDetents([.medium, .large])`, `.presentationBackground(TTColor.canvas)`.
2. Two columns (stacked at AX sizes), each `surfaceCard()` with a 3 pt top stripe in the player color. The preselected player (from the scoreboard tap) gets a `strokeStrong` outline.
3. `TTCounter(size: .large, tone: .player(isOne))` bound to `trackerState.playerXVictoryPoints` via a `Binding` whose `set` computes the delta and calls `viewModel.adjustVictoryPoints(playerIsOne:delta:reason: .manual)`. Keep ids `battleTracker.vp.playerOne` / `.playerTwo` on the counters.
4. Quick-add buttons from `viewModel.playContext.victoryPointsScoring` (`primaryQuickAddLabel/Amount` → reason `.objective`, `secondaryQuickAddLabel/Amount` → `.tactic`). Style `.ttSecondary`, `controlSize(.large)`. Ids `battleTracker.vp.{playerOne|playerTwo}.objective` / `.tactic`.
5. Each quick-add posts a toast (SH-04): "Azure +1 objective", with Undo (calls `adjustVictoryPoints(... delta: -amount ...)`). Id `battle.vp.{timestamp}` so rapid taps queue.
6. Link row to the scoring rules section (`capabilities.scoringRuleSectionId`, existing `battleTracker.scoringRules` id). Push inside the sheet's own `NavigationStack`.

### Acceptance
- [ ] Scoring both players takes ≤ 3 taps from the battle screen.
- [ ] Undo toast reverses a quick add.
- [ ] VoiceOver adjusts counters with swipe up/down.

---

## BT-09: Units panel (army health)

**Goal:** both armies' health at a glance, big tap targets for wounds, and the entry to unit focus.
**Depends on:** BT-01, DS-07
**Files:** `DesignSystem/Shared/ArmyTrackerCard.swift` (`ArmyTrackerCard`, `ArmyHealthPanel`, `ArmyUnitHealthRow`, `ArmyHealthProgressBar`), new `Features/Play/BattleScreen/BattleUnitsSheet.swift`

```
┌──────────────────────────────────┐
│ Units                        (✕) │
│ [ ① Azure · Bleak Host ][ ② Gold ]│ ← TTSegmentedControl (phone)
│ Army health ▓▓▓▓▓▓▓░░░  18/26     │
│ ┌──────────────────────────────┐ │
│ │ Spoilpox Scrivener   HERO    │ │
│ │ ▓▓▓▓▓▓░░░░        [−] 3 [+]  │ │ ← TTCounter(.regular), tap row → unit focus
│ ├──────────────────────────────┤ │
│ │ Plaguebearers ×10            │ │
│ │ ▓▓▓▓▓▓▓▓▓▓       [−] 10 [+]  │ │
│ ├──────────────────────────────┤ │
│ │ Putrid Blightkings  DESTROYED│ │ ← dimmed, danger badge
│ └──────────────────────────────┘ │
│ Hide destroyed units   (toggle)  │
└──────────────────────────────────┘
```

### Steps
1. **Phone:** `.sheet` from the action bar Units button, detents `[.medium, .large]`, default `.medium`, `presentationBackgroundInteraction(.enabled(upThrough: .medium))` so the Now panel stays usable behind it.
2. **iPad:** the same content rendered inline as the side panel (BT-12), both armies stacked (no segmented control).
3. Player switcher: `TTSegmentedControl` with `TTPlayerToken` + name. Default selection = active player.
4. Army summary: `ArmyHealthSummary` (exists in Domain/UseCases) → `TTProgressBar(tone: .player(isOne))` + "{remaining}/{total}" in `TTFont.numericSmall`.
5. Unit rows (`ArmyUnitHealthRow` re-implementation):
   - Name `TTFont.headline`, keyword badge (`Hero`), model count "×{n}" if > 1.
   - `TTProgressBar` per unit (player tone, danger when ≤ 35%).
   - `TTCounter(value:range: 0...capacity, label: "{unit} wounds remaining", tone: .player(isOne))` → `viewModel.setUnitWounds(key:remaining:)`. **Keep** `battleTracker.wounds.{armyId}.{unitId}` ids on the counters.
   - Haptics: `.wound` on decrease, `.unitDestroyed` when reaching 0.
   - When a unit hits 0: row dims to 55%, `TTBadge("Destroyed", tone: .danger)`, and a toast "Plaguebearers destroyed" with Undo (restores previous value).
   - Row tap (outside the counter) → `presentUnitFocus(armyId:unitId:preferredWeaponId:)` (existing) → UF-01.
6. "Hide destroyed units" toggle keeps the existing `ArmyTrackerCard` storage key (check its `@AppStorage`).
7. Health-per-model overrides (`unitHealthPerModelOverrides`) show a `*` next to capacity, as today.

### Acceptance
- [ ] Applying 3 wounds to a unit takes 3 taps on a 44+ pt control. Long-press repeats.
- [ ] Destroying a unit shows the badge + undo toast.
- [ ] iPhone: the sheet at medium detent leaves the scoreboard and phase rail visible.

---

## BT-10: Dice (combat resolver) entry

**Goal:** the combat resolver opens as a focused sheet from anywhere (action bar, ability "Resolve", shooting rows, unit focus), prefilled with context.
**Depends on:** BT-01, UF-02
**Files:** new `Features/Play/BattleScreen/BattleCombatSheet.swift`; `Features/GuidedMatch/BattleTrackerCombatResolverSection.swift`; `Features/Play/Shared/BattlePhaseTrackerView+Combat.swift` (`handleResolveAttack`, `handleArmyUnitSelection`, `applyCombatDamage`), `+CombatFocus.swift`

### Steps
1. `@State var showsCombatSheet = false`. Action bar Dice → `showsCombatSheet = true`. Existing entry points (`handleResolveAttack`, `handleArmyUnitSelection`, `focusCombatResolverSection`) set the combat view model's attacker/defender exactly as today, then set `showsCombatSheet = true` **instead of** switching to the Combat tab / scrolling.
2. Sheet content: `NavigationStack { BattleTrackerCombatResolverSection(...) }` with the **same** bindings the Combat tab passes today (copy the argument list from `combatResolverSection(usesLandscapeSplit:)`). Title "Resolve Attack", close button, detents `[.large]` on phone, `.medium/.large` on iPad.
3. Header strip inside the sheet: attacker (active player tone) → defender (other tone) with unit names, tappable to change (opens the existing pickers).
4. After `applyCombatDamage`, dismiss the sheet, show a damage toast "4 damage to Plaguebearers" with **Undo** (replacing `damageUndoSection`/`DamageUndoNotice`; reuse its undo logic), and fire `.ttHaptic(.wound…)`.
5. The resolver's internal visuals are handled in UF-02/UF-03.

### Acceptance
- [ ] Every "Resolve" entry point opens the sheet prefilled.
- [ ] Applying damage updates the Units panel, dismisses, and shows an undo toast.

---

## BT-11: Notices → toasts and one-time coach

**Goal:** at most **one** coaching element on screen. Transient confirmations become toasts.
**Depends on:** BT-05, SH-04
**Files:** `Features/Play/Shared/BattlePhaseTrackerNotices.swift`, `DesignSystem/Shared/GuidedMatchCoachingBanners.swift`, `DesignSystem/Shared/BattleTrackerQuickActionsList.swift` (`BattleTrackerTabHintBanner`), `BattlePhaseTrackerView+ScrollTracking.swift` (`TrackerNoticeDismissalsModifier`), `BattlePhaseTrackerView.swift` (`coachSection`)

| Old notice | New layout treatment |
|------------|----------------------|
| `TurnHandoffNotice` | Removed (BT-07 interstitial). |
| `DamageUndoNotice` | Toast with Undo (BT-10). |
| `RoundOpenerNotice` ("finish your round opener") | Removed (round-start moment is mandatory in the flow). |
| `ScoringReminderNotice` | Removed (end-of-turn moment has inline scoring). |
| `PhaseActionNudgeNotice` | Toast, max once per phase per match, only when the user tries to advance with unused "once per turn" abilities: "2 abilities unused this phase", action "Review". |
| `showsHeroRoundOneNotice` / `HeroPhaseRoundOneBanner` | Folded into the Hero phase header ⓘ text for round 1. |
| `BattleTrackerCoachCard` (first battle) | One-time `TTNotice(tone: .brand)` at the top of the Now panel on first open: "Tap the big button to move through each phase. Score from the top bar." Dismiss is remembered by the existing `NewPlayerTipsStore.markBattleTrackerCoachSeen()`. |
| `RoundOneMilestoneBanner` | Toast "Round 1 complete. Nice!" (the one allowed exclamation mark) once per install (`FirstSessionStore.markRoundOneMilestoneSeen()`). |
| `PhysicalDiceResolverHint` | Moves into the Dice sheet (UF-03), shown once. |
| `BattleTrackerTabHintBanner` | Removed (no tabs). |

Steps: implement the table **only in the new layout branch** (check `usesBattleScreenLayout` before presenting the old inline sections). Keep the old notice types for the legacy layout. Use `BannerItem` ids prefixed `battle.` (`battle.damageUndo`, `battle.phaseNudge`, `battle.roundOneMilestone`).

### Acceptance
- [ ] Playing a full round never shows more than one coach element at once.
- [ ] Toasts never cover the primary button (they sit above the action bar via `toastBottomInset`).

---

## BT-12: Phone landscape and iPad layouts

**Depends on:** BT-02 … BT-10
**Files:** `Features/Play/BattleScreen/BattleScreenLayout.swift`, `Features/GuidedMatch/GuidedMatchView+PadLayout.swift` (battle detail column), `DesignSystem/DesignTokens.swift` (landscape tokens exist)

### Phone landscape (`layoutContext == .phoneLandscape`)
- `HStack(spacing: 0)`: **left column** (width = 42%, min 280): scoreboard `compact: true` (two stacked rows), phase rail `axis: .vertical` (rows 36 pt), Spacer, action bar (tool buttons as icons only). **Right column:** `ScrollView { now content }` with `phoneLandscapeHorizontalPadding`.
- Tab bar hidden (existing `hidesTabBarInLandscapeBattle`). Respect horizontal safe areas (notch side).
- The existing `+PhoneLandscapeCombat.swift` split (pinned warscroll) is legacy-only. In the new layout the Dice sheet is full screen in landscape.

### iPad (`usesPadSplitNavigation`)
- Guided Match uses `NavigationSplitView`. When the detail is the battle tracker, set `splitColumnVisibility = .detailOnly` by default (the existing marketing flag does this; make it default for battle) with a toolbar button to show the sidebar.
- Battle detail: `VStack { scoreboard (full width); phase rail (centered, max 720) ; HStack(alignment: .top, spacing: lg) { VStack { now content (ScrollView); action bar } .frame(maxWidth: 480) ; units panel (ScrollView, both armies) } }`.
- In iPad landscape, the units panel shows both armies side by side (two columns) if width ≥ 1000 pt.
- Keyboard shortcuts (iPad with keyboard): `→` / `Space` = primary action, `←` = previous phase, `S` = score sheet, `U` = toggle units focus, `D` = dice. Use `.keyboardShortcut` on hidden buttons or the real buttons.

### Dynamic Type (all devices)
- At `needsLayoutAdaptation`: scoreboard → two rows; phase rail shows only the current phase + "x of 6" with a chevron menu for jumping; action bar tool buttons → overflow menu.

### Acceptance
- [ ] QA-02 matrix passes for the battle screen (all devices, both orientations, AX3).
- [ ] No content hidden behind the notch or home indicator in landscape.

---

## BT-13: Battle menu (⋯)

**Goal:** everything secondary lives in one predictable place.
**Depends on:** BT-01
**Files:** `Features/Play/BattleScreen/BattlePhaseTrackerView+BattleScreen.swift`, `BattleTrackerScreenChrome` (in `BattlePhaseTrackerView.swift`), `Features/GuidedMatch/GuidedMatchView.swift` (menu merge with GM-01)

Menu (`Menu` with `ellipsis.circle`, top-trailing of the scoreboard, id `battleTracker.menu`):

| Group | Item | Action | Id |
|-------|------|--------|-----|
| Match | Match Setup | `hubTab = .setup` (GuidedMatch) | `battleTracker.menu.setup` |
| Match | Armies & Loadouts | sheet with `BattleTrackerBothLoadoutsSection` + `BattleTrackerBothRostersSection` restyled (both players' regiment, enhancement, rosters, warscroll links) | `battleTracker.menu.loadouts` |
| Match | Change Round… | sheet with a round `TTSegmentedControl` (1–4) → `viewModel.setBattleRound(_:)`. **This is the manual escape hatch** for mistakes. | `battleTracker.round` (**reuse old id**) |
| Reference | Spearhead Rules | push `GameSystemRulesReferenceLink` | `battleTracker.menu.rules` |
| Reference | Card Decks Guide | `BattleTacticsReferenceLink` | `battleTracker.battleTactics` (**reuse**) |
| Reference | Glossary | `RulesGlossaryBrowseLink` | `battleTracker.glossary` (**reuse**) |
| Device | Sync with Nearby Device | existing sync sheet | (reuse GM-01 id) |
| Danger | Reset Battle… (`role: .destructive`) | `confirmationDialog` → `viewModel.resetTracker()` | `battleTracker.reset` (**reuse**) |
| Danger | End Match… | Guided Match `showsResetConfirmation` (Save and Reset / Discard) | `guidedMatch.menu.endMatch` |

Remove the standalone toolbar "Reset" button and `ChromeCollapseToolbarButton` from the new layout (legacy keeps them).

### Acceptance
- [ ] Every function from the old tabs/dock/toolbar is reachable (cross-check §1.5).
- [ ] Destructive items always confirm.

---

## Battle tracker QA script (run after BT-12)

1. Fresh install → onboarding → Start a Battle → Use Starter Matchup → complete Setup → Start Battle.
2. Deployment: complete 5 steps (coin flip on step 1). Undo one step by tapping its ✓.
3. Round 1 opener: pick first player → Hero.
4. Hero → Move → Shoot (open a shooting unit → Dice sheet → enter dice → apply damage → undo via toast → re-apply) → Charge → Combat → End of Turn: +1 objective, +1 tactic → Pass to Player 2 → handoff → Player 2 Hero.
5. Player 2 turn through End of Turn → round 1 complete → Start Round 2 → round-start panel shows underdog.
6. Open Units at medium detent, wound and destroy a unit, undo.
7. Rotate to landscape mid-phase. State is preserved and the layout switches.
8. Background the app for 1 minute, return. State persists (stores already persist).
9. Play to round 4, second turn → See Results → victory screen.
10. Repeat steps 1–5 with VoiceOver on, and at AX3.
