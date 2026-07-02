# SwiftUI View Extraction — Full Refactor

**Status:** Complete (phases 0–7) — incremental extraction continues via Cursor rule  
**Last updated:** 2026-07-01  
**Scope:** All Tabletome view files (~300 across Features/ and DesignSystem/)

---

## Problem

SwiftUI re-evaluates computed `@ViewBuilder` properties whenever their parent view's state changes. Extracting sections into separate `View` structs gives each its own invalidation boundary — only views whose inputs changed get re-evaluated.

~300 view files across Features/ and DesignSystem/ use inline `@ViewBuilder` computed properties instead of dedicated structs.

---

## Strategy

1. **Cursor rule** — enforce the pattern on all new code and when touching existing files
2. **Incremental refactor** — extract sections when modifying a file for other work
3. **Phased bulk refactor** — tackle hotspots in priority order during dedicated sessions

---

## Phase 0: Cursor Rule

Create `.cursor/rules/swiftui-view-extraction.mdc` — see [`swiftui-view-extraction.mdc`](../.cursor/rules/swiftui-view-extraction.mdc) once created.

Pattern:

```swift
// AVOID — shares parent invalidation boundary
extension ParentView {
    @ViewBuilder var fooSection: some View {
        Section { ... }
    }
}

// PREFER — own invalidation boundary
struct FooSection: View {
    let data: FooData
    @Binding var selection: String?
    let onTap: () -> Void

    var body: some View {
        Section { ... }
    }
}
```

**Reference:** [`SpearheadStarterBoxSection`](../Features/GuidedMatch/Spearhead/SpearheadStarterBoxSection.swift) — canonical example.

---

## Phase 1: GuidedMatch (highest impact)

**Target files:**
- [`GuidedMatchView+ListSections.swift`](../Features/GuidedMatch/GuidedMatchView+ListSections.swift) — 795 lines, 17 `@ViewBuilder`s
- [`MatchStepDetailView.swift`](../Features/GuidedMatch/MatchStepDetailView.swift) — 763 lines, 11+ game-system sections

**Extract to `Features/GuidedMatch/Sections/`:**

| Current | New Struct |
|---------|------------|
| `sampleTurnSection` | `SampleTurnSection` |
| `collapsedMatchSetupSection` | `CollapsedMatchSetupSection` |
| `matchupSection` | `MatchupSection` |
| `setupProgressSection` | `SetupProgressSection` |
| `rollPromptSection` | `RollPromptSection` |
| `preBattleLoadoutReviewSection` | `PreBattleLoadoutReviewSection` |
| `continueSetupSection` | `ContinueSetupSection` |
| `setupCompleteHandoffSection` | `SetupCompleteHandoffSection` |
| `playersSection` | `PlayersSection` |
| `battleTrackerSection` | `BattleTrackerSection` |
| `matchSetupSection` | `MatchSetupSection` |
| `resetSection` | `ResetSection` |

**MatchStepDetailView game-system sections** — extract to `Features/GuidedMatch/StepContent/`:
- `SpearheadStepContent.swift`
- `Wh40k11eStepContent.swift`
- `CombatPatrolStepContent.swift`
- `ScTmgStepContent.swift`

---

## Phase 2: Play / BattlePhaseTracker

**Status:** Done — `BattleTrackerSections.swift` split to `Features/Play/Shared/Sections/`; top chrome and quick-action hints extracted.

**Target files:**
- [`BattlePhaseTrackerView.swift`](../Features/Play/Shared/BattlePhaseTrackerView.swift) — shell layout only; tab content in extensions + `Sections/`
- ~~[`BattleTrackerSections.swift`](../Features/Play/Shared/BattleTrackerSections.swift)~~ — removed; one struct per file under `Sections/`
- [`BattlePhaseTrackerNotices.swift`](../Features/Play/Shared/BattlePhaseTrackerNotices.swift) — thin re-exports; notices in `Notices/`

**From main view:** `coachSection`, `guideSection`, `deploymentSection`, `roundOpenerChecklistSection`, `victoryPointsSection`, `gotchaSection`

**From extensions:** Extract tab content from `+CompactTabs`, `+PadLayout` into dedicated layout views.

---

## Phase 3: CombatRoll

**Status:** Done — `CombatResolverPanel` delegates to `Features/CombatRoll/Sections/`.

**Target files:**
- [`CombatResolverPanel.swift`](../Features/CombatRoll/CombatResolverPanel.swift) — orchestration only
- [`BatchCombatResolverSection.swift`](../Features/CombatRoll/BatchCombatResolverSection.swift) — batch UI in `Sections/`

---

## Phase 4: Bench

**Target files:**
- [`Armies/ArmySheets.swift`](../Features/Bench/Armies/ArmySheets.swift) — 770 lines, 6 sheets

**Split into individual files:**
- `AddArmySheet.swift`
- `AddUnitSheet.swift`
- `RenameArmySheet.swift`
- `ArmyPipelineEditorSheet.swift`
- `MoveUnitSheet.swift`

Also: [`ArmyDetailView.swift`](../Features/Bench/Collection/ArmyDetailView.swift) (461 lines) — extract tab sections.

---

## Phase 5: DesignSystem/Shared

**Target files:**
- [`MatchVictoryScreen.swift`](../DesignSystem/Shared/MatchVictoryScreen.swift) — 410 lines
- [`VictoryPointsCard.swift`](../DesignSystem/Shared/VictoryPointsCard.swift) — 395 lines
- [`MatchupSidePanel.swift`](../DesignSystem/MatchupSidePanel.swift) — 326 lines
- [`BattleTrackerSectionTab.swift`](../DesignSystem/Shared/BattleTrackerSectionTab.swift) — 320 lines

**Extract:** scoreboard, per-turn breakdown, unit/weapon pickers, sticky phase header.

---

## Phase 6: DesignSystem multi-struct files

Split aggregator files into one struct per file:
- [`NewPlayerGuidance.swift`](../DesignSystem/NewPlayerGuidance.swift) (454) → `BattleTrackerCoachCard`, `PhaseGuidanceBar`, `CombatSequencePrimer`
- [`Hobby/Components.swift`](../DesignSystem/Hobby/Components.swift) (410) → `PointsSourceViews`, `ProgressMeter`, `CrestBadge`, `StatTile`
- [`DiceCoachingHint.swift`](../DesignSystem/DiceCoachingHint.swift) (260) → one file per banner

---

## Phase 7: Remaining Features

Lower priority — tackle when touching:
- `Muster/RosterEditorView.swift` (618)
- `Muster/NewRosterSheet.swift` (455)
- `Home/BoxIdentificationSheet.swift` (397)
- `GameGuide/GameSystemDetailView.swift` (430)
- `Settings/SettingsDataSection.swift` (504)

---

## Validation per phase

1. Build succeeds ✅
2. Lint check — no new warnings ✅
3. UI renders identically (manual / snapshot QA)
4. Instruments / SwiftUI view debugger — optional spot-check when touching hotspots

## Incremental backlog

~250 `@ViewBuilder` properties remain across the app (Spearhead battle UI, Bench collection depth, etc.). The Cursor rule enforces extraction on touch; no dedicated bulk pass planned unless profiling shows a hotspot.
