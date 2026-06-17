# Guided Match UX Polish Plan

## Goal

Make Guided Match and Battle Phase Tracker intuitive for new Spearhead players, comfortable on iPad and landscape, and compliant with the WCAG 2.1 AA baseline in `AccessibilitySpec.md`.

This plan covers layout adaptation, clarity improvements, and accessibility hardening identified in the 2026-06-17 UX review.

## Scope

| In scope | Out of scope (later) |
|----------|----------------------|
| Guided Match hub, army picker, match steps | Combat dice roller UI |
| Battle Phase Tracker | Rules Reference split view |
| Shared design-system layout helpers | Full `accessibility/audits/` per-screen files |
| `UnitAbilityCard`, `GuideStepCard` a11y | Localization beyond English |

## Implementation order

Work proceeds in dependency order: shared layout primitives first, then high-value game-time screens, then clarity copy, then accessibility depth, then structural iPad navigation.

---

## Phase 1 — Readable content width

### Problem

Scroll views and lists stretch to the full iPad width (~1024pt in landscape). Body text and ability cards become hard to scan; line length exceeds comfortable reading width (~60–80 characters).

### Solution

Add `DesignTokens.readableContentMaxWidth` (680pt) and a `readableContentWidth()` view modifier in `DesignSystem/`.

```swift
.frame(maxWidth: DesignTokens.readableContentMaxWidth)
.frame(maxWidth: .infinity) // center in parent
```

### Apply to

| View | Notes |
|------|-------|
| `BattlePhaseTrackerView` | ScrollView inner `VStack` |
| `MatchStepDetailView` | ScrollView inner `VStack` |
| `GuidedMatchView` | List wrapper (regular width only; phone stays edge-to-edge grouped list) |
| `ArmySelectionView` | Form wrapper on regular width |
| `GettingStartedView` / `GuideStepDetailView` | Same pattern for consistency |

### Acceptance

- [x] iPhone portrait: no visual regression (full-width grouped lists preserved)
- [x] iPad / landscape: primary content column ≤ 680pt, centered
- [ ] Dynamic Type AX1–AX3: no new horizontal clipping at readable width

### Files

- `DesignSystem/DesignTokens.swift` — add constant
- `DesignSystem/ReadableContentWidth.swift` — new modifier
- `specs/DesignSystemSpec.md` — document token + modifier

---

## Phase 2 — Battle Tracker two-column layout

### Problem

On iPad, controls (round, player, phases) stack above a long ability list. During a game, players want controls visible while scrolling abilities.

### Solution

When `horizontalSizeClass == .regular`:

```
┌─────────────────┬──────────────────────────────┐
│  Control panel  │  Available Now / Always On   │
│  (fixed ~320pt) │  (ability cards, scrollable) │
└─────────────────┴──────────────────────────────┘
```

When `horizontalSizeClass == .compact` (iPhone): keep existing single-column `VStack`.

### Phase chip layout

| Width | Control |
|-------|---------|
| Compact | Horizontal `ScrollView` of `PhaseChip` (current) |
| Regular | `LazyVGrid` with adaptive columns (min 72pt) so all main phases visible without horizontal scroll |

### Acceptance

- [x] iPhone: unchanged single-column layout
- [x] iPad landscape: controls left, abilities right
- [x] Phase chips visible without horizontal scroll on iPad
- [ ] VoiceOver reading order: controls → abilities (manual pass pending)

### Files

- `Features/GuidedMatch/BattlePhaseTrackerView.swift`
- `DesignSystem/PhaseChip.swift` — extract `PhaseChip` + `PhaseChipRow` (grid vs scroll)

---

## Phase 3 — Intuitiveness: progress & disabled states

### Problem

1. Users don't know how far they are through the 6 setup steps.
2. Battle Tracker `NavigationLink` is disabled with no explanation when armies aren't chosen.
3. Battle tracker empty state mentions internal "detail files."
4. Content coverage badges ("Roster", "Match Setup", "Battle Tracker") are engineer-facing.

### Solution

#### 3a — Setup progress header

Add `GuidedMatchViewModel.setupProgress: (completed: Int, total: Int)` counting `completedStepIds` against `matchSteps`.

Display in Guided Match `Section` header or banner:

> **Setup progress:** 3 of 6 steps complete

Use `ProgressView(value:)` below the matchup summary when both armies are selected.

#### 3b — Battle Tracker disabled footer

In the "During the Battle" section:

```swift
Section {
    NavigationLink { ... } label: { ... }
        .disabled(!viewModel.matchState.hasBothArmies)
} footer: {
    if !viewModel.matchState.hasBothArmies {
        Text("Choose both player armies to open the battle tracker.")
    }
}
```

#### 3c — Player-facing empty state

Replace developer copy in `BattlePhaseTrackerView.emptyState` with:

> Ability reminders for this army aren't in Tabletome yet. Use the **GW Spearhead PDF** link on the army picker for full rules.

#### 3d — Coverage badge copy

| `SpearheadContentCoverage` | UI label |
|--------------------------|----------|
| `roster` | Army list only |
| `matchSetup` | Setup ready |
| `battleTracker` | Rules reminders ready |

Add army picker section footer legend explaining the three levels.

### Acceptance

- [x] Progress updates when steps are toggled complete
- [x] Disabled tracker shows footer on phone and iPad
- [x] No user-facing "detail file" or "JSON" language
- [x] Coverage badges use player-facing labels

### Files

- `Features/GuidedMatch/GuidedMatchViewModel.swift`
- `Features/GuidedMatch/GuidedMatchView.swift`
- `Features/GuidedMatch/BattlePhaseTrackerView.swift`
- `Features/GuidedMatch/ArmySelectionView.swift`
- `Domain/Models/SpearheadArmyDetail.swift` — optional `playerFacingTitle` on coverage enum

---

## Phase 4 — Richer VoiceOver on ability cards

### Problem

`UnitAbilityCard` combines children into a label of only `name + effect`. VoiceOver users miss declare text, phase, usage limit, and used state.

### Solution

Build structured accessibility strings:

```
Label:  Wither. Grey Seer.
Value:  Hero phase. Once per battle. Declare: Pick an enemy unit within 12". Effect: ...
Hint:   Double tap to mark as used.  (when applicable)
```

When `isUsed`: add `.accessibilityAddTraits(.isSelected)` or announce "Used this battle" in `accessibilityValue`.

Do **not** rely on opacity alone for used state.

### Also fix

| Component | Change |
|-----------|--------|
| `ArmyOptionRow` | Include coverage label in combined accessibility label |
| `PhaseChip` | Already has `phase.title` + `isSelected` — verify |
| Segmented player picker | `accessibilityLabel` uses full player name even when truncated visually |

### Acceptance

- [x] VoiceOver reads declare, effect, phase, and usage for ability cards
- [x] Used abilities announced as used
- [x] Army row announces coverage level

### Files

- `DesignSystem/UnitAbilityCard.swift`
- `Features/GuidedMatch/ArmySelectionView.swift`
- `Features/GuidedMatch/BattlePhaseTrackerView.swift`

---

## Phase 5 — NavigationSplitView for Guided Match (iPad)

### Problem

Guided Match is a deep `NavigationStack` on iPad. Users lose context when drilling into steps; sidebar + detail is the standard iPad pattern.

### Solution

Introduce `GuidedMatchDestination: Hashable`:

```swift
enum GuidedMatchDestination: Hashable {
    case playerOne
    case playerTwo
    case battleTracker
    case step(String) // step id
}
```

| Size class | Navigation |
|------------|------------|
| `.compact` | Existing `NavigationLink` stack (unchanged) |
| `.regular` | `NavigationSplitView`: sidebar list + detail pane |

#### Sidebar contents (top to bottom)

1. Today's Match summary (if both armies)
2. Setup progress
3. Player 1 / Player 2 rows (tagged `.playerOne` / `.playerTwo`)
4. Battle Phase Tracker (tagged `.battleTracker`, disabled when armies missing)
5. Match setup steps (tagged `.step(id)`)
6. Reset Match (button, not a destination)

#### Detail pane

| Selection | Detail |
|-----------|--------|
| `nil` | `ContentUnavailableView` — "Select a step or player" |
| `.playerOne` / `.playerTwo` | `ArmySelectionView(dismissesOnSave: false)` |
| `.battleTracker` | `BattlePhaseTrackerView` |
| `.step(id)` | `MatchStepDetailView` |

`ArmySelectionView` gains `dismissesOnSave: Bool` — when `false`, Save updates state without `dismiss()`.

### Acceptance

- [x] iPhone: no change to navigation flow
- [x] iPad: sidebar persists while viewing step detail
- [x] Army selection on iPad saves in place (no pop)
- [ ] Selection state restores after rotation if possible

### Files

- `Features/GuidedMatch/GuidedMatchDestination.swift` — new
- `Features/GuidedMatch/GuidedMatchView.swift` — split vs stack
- `Features/GuidedMatch/ArmySelectionView.swift` — `dismissesOnSave`
- `specs/GuidedMatchSpec.md` — document iPad layout

---

## Phase 6 — Remaining polish

### 6a — Army row buttons

Replace `onTapGesture` on `ArmyOptionRow` with `Button` for keyboard, Switch Control, and clearer tap affordance.

### 6b — Dynamic Type hardening

| Component | Fix |
|-----------|-----|
| `GuideStepCard` | `@ScaledMetric` for 36pt step circle |
| `PhaseChip` | `minimumScaleFactor(0.8)` on caption text |
| `ContentCoverageBadge` | Allow badge to wrap on AX3+ |

### 6c — Color-independent status

Pair green checkmarks and coverage badges with SF Symbols (`checkmark.seal.fill`, `book.closed` / `flag.checkered`).

### 6d — Reduce Motion

Read `@Environment(\.accessibilityReduceMotion)` in Guided Match; disable any future step transition animations (parity with `GettingStartedView`).

### 6e — Match step side-by-side pickers (iPad)

In `MatchStepDetailView`, when `horizontalSizeClass == .regular`, show Player 1 and Player 2 regiment/enhancement pickers in an `HStack` instead of stacked `VStack`.

### Acceptance

- [x] Army rows work with Button (keyboard / Switch Control)
- [ ] AX5 spot-check on Battle Tracker: no clipped phase chips
- [x] Status distinguishable with symbol + text (not color alone)

---

## Test plan

| Area | Test |
|------|------|
| Layout | Manual: iPhone 17 + iPad simulator, portrait and landscape |
| Progress | Unit test: `GuidedMatchViewModel.setupProgress` counts correctly |
| Coverage labels | Unit test: `SpearheadContentCoverage.playerFacingTitle` |
| Regression | Full `xcodebuild test` on CI scheme |
| Accessibility | Manual VoiceOver pass on Guided Match + Battle Tracker (document in `accessibility/audits/guided-match.md` when done) |

## Spec updates

After each phase, update:

- `specs/DesignSystemSpec.md` — new components
- `specs/GuidedMatchSpec.md` — iPad navigation, progress UI
- `specs/AccessibilitySpec.md` — verification block date
- `specs/README.md` — link this plan

## Verification

| Field | Value |
|-------|-------|
| Target release | v0.2 |
| Last verified | 2026-06-17 |
| Code paths | `DesignSystem/ReadableContentWidth.swift`, `Features/GuidedMatch/`, `DesignSystem/UnitAbilityCard.swift` |
