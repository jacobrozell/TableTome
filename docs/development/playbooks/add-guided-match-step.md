# Playbook: Add a guided match step

**Last updated:** 2026-06-29 · Spec: [`GuidedMatchSpec.md`](../../../specs/GuidedMatchSpec.md)

---

## Overview

Guided match setup is a checklist of steps (armies, mission, deployment, etc.) driven by `GuidedMatchViewModel` and rendered in `GuidedMatchView` / `MatchStepDetailView`.

---

## Steps

### 1. Spec the step

Update [`GuidedMatchSpec.md`](../../../specs/GuidedMatchSpec.md):

- Step id, title, order, which game systems include it
- Completion criteria
- Verification block (release, date, code paths)

### 2. Domain / setup model

Locate step definitions in Domain (search `GuidedMatchStep`, `MatchSetup`, `SetupStep`). Add the step to the catalog for relevant `GameSystemId` values.

Ensure persistence via `MatchSetupStore` restores state after relaunch.

### 3. ViewModel

`Features/GuidedMatch/GuidedMatchViewModel.swift`:

- Handle step selection, completion, validation
- Log analytics in `GuidedMatchViewModel+Analytics.swift`:
  - `guided_match_step_completed` with `guidedMatchStep` metadata
- Keep body length manageable — extract analytics to `+Analytics.swift`

### 4. UI

| Component | File |
|-----------|------|
| Step list | `GuidedMatchView+ListSections.swift`, `DesignSystem/Shared/GuidedMatchSetupProgressList.swift` |
| Step detail | `MatchStepDetailView.swift`, `+InlineCompact.swift` |
| System-specific cards | `DesignSystem/PhasedRound/`, `DesignSystem/AltActivation/` |

Add `accessibilityIdentifier` on primary actions: `guidedMatch.step.<stepId>.complete`.

### 5. Navigation to battle tracker

If the step gates battle tab access, coordinate with `GuidedMatchView+BattleTracker.swift` and `BattleTrackerViewModelFactory`.

Launch shortcut for tests: `-open_battle_tracker`.

### 6. Tests

- ViewModel: step completion, ordering, validation errors
- Persistence: relaunch restores step progress (`MatchSetupStore` tests if present)
- UI test identifier smoke optional

### 7. Analytics

- `guided_match_step_completed` — allowlisted, include `guidedMatchStep`, `gameSystemSection`
- Update event table in [`firebase-analytics.md`](../../release/firebase-analytics.md) if milestone step

---

## Layout notes

- iPhone compact: `GuidedMatchView+CompactLayout.swift`
- iPad: `GuidedMatchView+PadLayout.swift`, `NavigationSplitView`
- Landscape battle immersion: `usesPhoneLandscapeBattleImmersion` — see [`iPhoneLandscapePlan.md`](../../../specs/iPhoneLandscapePlan.md)

---

## Checklist

- [ ] Spec updated with Verification
- [ ] Step in domain catalog for correct game systems
- [ ] ViewModel completion + persistence
- [ ] UI with a11y identifiers
- [ ] Analytics event wired + tested
- [ ] Manual pass iPhone + iPad
