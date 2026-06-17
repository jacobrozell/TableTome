# iPhone Landscape & Large Text Support — Master Plan

Phased plan to enable iPhone landscape across every screen, align layout logic with idiom (not size class alone), and harden Dynamic Type at the same time.

Today the app is **portrait-only on iPhone** (`project.yml`), with landscape work aimed at **iPad** and a few screens that already react to `verticalSizeClass == .compact` (notably onboarding).

Related specs: [AccessibilitySpec.md](AccessibilitySpec.md), [DesignSystemSpec.md](DesignSystemSpec.md), [GuidedMatchUXPolishPlan.md](GuidedMatchUXPolishPlan.md).

---

## 1. Goals & Non-Goals

### Goals

1. **iPhone landscape is a supported orientation** — not merely “doesn’t crash.”
2. **Every user-facing screen** has an explicit layout strategy for compact-height + compact-width combinations.
3. **Large text (AX1–AX5)** does not clip, overlap, or produce unusable touch targets in either orientation.
4. **Battle-time flows** (Guided Match, Battle Tracker, Combat Resolver) remain usable one-handed at the table.
5. **Specs and audits** are updated so orientation + Dynamic Type are verifiable, not tribal knowledge.

### Non-Goals (defer)

- Localization beyond English
- Full per-screen VoiceOver audit files in `accessibility/audits/` (start the structure; don’t block landscape on completing every audit)
- macOS / visionOS targets
- Rules tab `NavigationSplitView` (called out in `GuidedMatchUXPolishPlan.md` as later work)

### Success Criteria

| Criterion | Target |
|-----------|--------|
| Orientation lock | iPhone: portrait + both landscapes; iPad: unchanged |
| Layout regressions | Zero on iPhone portrait (visual snapshot + manual smoke) |
| Dynamic Type | No new clipping at AX3 on any screen; AX5 spot-check on battle tracker |
| Touch targets | 44×44pt minimum on all primary actions in landscape |
| Reduce motion | All step/phase transitions respect `accessibilityReduceMotion` |
| Documentation | `AccessibilitySpec.md`, `DesignSystemSpec.md`, and this plan’s verification blocks updated |

---

## 2. Current State Summary

### What exists today

- **Orientation policy:** iPhone portrait only; iPad portrait + landscape (`project.yml`).
- **`TabletomeLayout.isPadLandscape`:** `regular` horizontal + `compact` vertical — matches iPad landscape **and** iPhone landscape.
- **Already adapted:** Battle Tracker 2- and 3-column layouts, Guided Match `NavigationSplitView` on regular width, Combat Resolver side-by-side on regular width, Onboarding `widePageLayout` on compact height.

### Critical architectural gap

`TabletomeLayout.isPadLandscape` uses **size class only**. On **iPhone landscape**, that condition is also true — so if portrait lock is removed without refactoring, iPhones would immediately get iPad-oriented 3-column battle tracker layouts in a ~390×393pt viewport. That is the highest-risk change in the entire project.

**Decision required in Phase 0:** Replace or augment `isPadLandscape` with idiom-aware logic per `.cursor/rules/ios-agent.mdc`:

```swift
enum TabletomeLayoutContext {
    case phonePortrait
    case phoneLandscape      // primary new design target
    case padPortrait
    case padLandscape
}
```

---

## 3. Layout Taxonomy (Foundation)

Before touching individual views, define four layout contexts and what each implies.

| Context | Width | Height | Primary pattern |
|---------|-------|--------|-----------------|
| **Phone portrait** | Compact | Regular | Current behavior — preserve as baseline |
| **Phone landscape** | Compact* | Compact | Scroll-first; avoid multi-column; pin critical chrome |
| **iPad portrait** | Regular | Regular | Readable column (680pt) or split view |
| **iPad landscape** | Regular | Compact | Multi-column where density helps |

\*iPhone landscape horizontal size class can be `compact` or `regular` depending on device (Plus/Max models). **Do not assume `horizontalSizeClass == .regular` on phone landscape.**

### New shared primitives (Phase 0)

| Primitive | Purpose |
|-----------|---------|
| `TabletomeLayoutContext` | Single source of truth from idiom + size classes |
| `TabletomeLayoutReader` | Replace/adjust current `isPadLandscape` bool API |
| `compactHeight` | `verticalSizeClass == .compact` — shared by phone landscape and iPad landscape |
| `readableContentWidth()` | Extend: apply on phone landscape for **reading** screens only |
| `dynamicTypeAdaptive()` | Environment-driven padding/column collapse at `isAccessibilitySize` |
| `MinimumTouchTarget` | Enforce 44pt via modifier; audit exceptions |
| `LandscapeAwareHStack` | `ViewThatFits` wrapper: HStack → VStack fallback |
| `HorizontalChipRow` | Standard horizontal scroll for phase/glossary chips on narrow widths |

### Design tokens to add

```swift
// DesignTokens.swift additions
phoneLandscapeHorizontalPadding: 16
phoneLandscapeSectionSpacing: 12
phoneLandscapeStickyBarHeight: 56  // battle tracker combat bar
readableContentMaxWidthPhoneLandscape: 560  // optional narrower cap
accessibilitySizeSectionSpacingMultiplier: 1.25
```

---

## 4. Cross-Cutting Accessibility Hardening

Run **in parallel** with landscape work — many fixes benefit both axes.

### 4.1 Dynamic Type policy

| Tier | `dynamicTypeSize` | Layout behavior |
|------|-------------------|-----------------|
| Standard | `.large` and below | Default layouts |
| Large | `.xxxLarge` | Relax `lineLimit`; increase vertical spacing |
| Accessibility | `.accessibility1`–`.accessibility5` | Collapse multi-column → single column; shrink decorative chrome |

**Pattern to replicate from `OnboardingView.swift`:**

- `@Environment(\.dynamicTypeSize)`
- `@ScaledMetric` for decorative circles/icons
- `widePageLayout` equivalent: `compactHeight && !largeText` for side-by-side hero layouts

**Apply `@ScaledMetric` to:**

- `WalkthroughProgressDots`
- `SampleTurnWalkthroughView` step icon (currently fixed 44×44)
- `BrandCrest` (decorative — cap max size)
- `PhaseChip` minimum grid cell width (scale up with text)

### 4.2 `lineLimit` audit

Files with aggressive truncation — **relax or remove** at accessibility sizes:

| File | Current risk |
|------|--------------|
| `PhaseChip.swift` | `lineLimit(1)` + `minimumScaleFactor(0.8)` |
| `ArmyTrackerCard.swift` | `lineLimit(1)` unit names in compact sidebar |
| `VictoryPointsCard.swift` | Two-column HStack in narrow column |
| `BattleTrackerStickyCombatBar.swift` | `lineLimit(1)` on names + phase |
| `CombatResolverPanel.swift` | `lineLimit(1)` on embedded bar |

### 4.3 Touch target audit

| File | Current | Fix |
|------|---------|-----|
| `VictoryPointsCard.swift` | `minHeight: 32` quick-add | 44pt or `controlSize(.regular)` |
| `ArmyTrackerCard.swift` | `minHeight: 40` rows | 44pt |
| `DiceCoachingHint.swift` | `.controlSize(.small)` | Explicit `minHeight: 44` on actions |

### 4.4 Reduce motion gaps

Add `accessibilityReduceMotion` guards to:

- `PhaseChip.swift` — `PhaseChipRow` animation
- `BattlePhaseTrackerView.swift` — coach card dismiss
- `BattlePhaseTrackerNotices.swift` — turn-handoff dismiss
- `NewPlayerGuidance.swift` — step prev/next
- `ArmyGotchaCard.swift` — dismiss

### 4.5 Accessibility metadata gaps

Per agent rules (label + hint + identifier on every interactive control):

- `PrimaryButton.swift` — add hints
- `VictoryPointsCard.swift` — quick-add buttons
- `BattleTrackerStickyCombatBar.swift` — Undo/Dismiss
- `DiceCoachingHint.swift` — banner actions

---

## 5. Per-Screen Landscape & Large Text Plan

### 5.1 App Shell

#### `RootTabView.swift`

| Aspect | Phone landscape plan |
|--------|---------------------|
| Layout | Keep `TabView` — tab bar is acceptable |
| Risk | Tab bar + navigation bar + sticky bars = very little vertical space |
| Large text | Inline navigation titles on landscape (`navigationBarTitleDisplayMode(.inline)`) |
| Work | Add `compactHeight` environment preference; child screens inherit |

**Acceptance:** All three tabs navigable; no content hidden behind tab bar (existing `tabBarScrollInset()` must apply everywhere scrollable).

---

### 5.2 Onboarding

#### `OnboardingView.swift` — reference implementation

| Aspect | Status | Additional work |
|--------|--------|-----------------|
| Landscape | `widePageLayout` when `compactHeight && !largeText` | Extend to `largeText` case: stay stacked, reduce hero further |
| Large text | Hero caps, padding adjustments | Verify AX5 on iPhone landscape — footer buttons must not overlap content |
| iPhone unlock | Already handles compact height | Re-test when portrait lock removed |

**Acceptance:** 4 pages readable; Skip/Continue reachable; no footer overlap at AX5 landscape.

---

### 5.3 Home / Play Tab

#### `HomeView.swift`

| Aspect | Plan |
|--------|------|
| Layout | `List(.insetGrouped)` — works in landscape |
| Large text | List rows auto-grow — low risk |
| Landscape | Switch to `.inline` nav title when `compactHeight` |
| Embedded | `HomeWelcomeCard` (`NewPlayerStartHereCard.swift`) — ensure card body wraps, link row ≥ 44pt |

#### `EmptyStateView.swift`

| Aspect | Plan |
|--------|------|
| Risk | Not scrollable — long error messages clip in landscape |
| Fix | Wrap in `ScrollView` when `compactHeight` or `dynamicTypeSize.isAccessibilitySize` |

---

### 5.4 Game Guide

#### `GameSystemDetailView.swift`

| Aspect | Plan |
|--------|------|
| Layout | List — low risk |
| Landscape | Inline nav title; verify embedded cards don’t use excessive vertical padding |
| Large text | Section headers may wrap — acceptable |

#### `GettingStartedDestinationView.swift`

Thin loader — no landscape-specific work.

#### `GettingStartedView.swift`

| Aspect | Plan |
|--------|------|
| Layout | List + `readableContentWidth()` |
| Phone landscape | Apply readable width on phone landscape (new modifier behavior) |
| Embedded | `WhatYouNeedCard` — checklist rows must wrap at AX3+ |

#### `GuideStepDetailView.swift`

| Aspect | Plan |
|--------|------|
| Layout | ScrollView + readable width |
| Phone landscape | Readable width; glossary chips already horizontal scroll |
| Large text | Tips card — verify toggle + tips don’t collide |
| Reduce motion | Already handled |

#### `SampleTurnWalkthroughView.swift`

| Aspect | Plan |
|--------|------|
| Risk | Phase strip (`HStack` of capsules) overflows narrow landscape |
| Fix | `ViewThatFits`: horizontal strip → vertical list of phases at `compactWidth` or `isAccessibilitySize` |
| Large text | Step icon: `@ScaledMetric`; progress dots: scale |
| Reduce motion | Already handled |

---

### 5.5 Guided Match (highest complexity)

#### `GuidedMatchDestinationView.swift`

Loader only — no work.

#### `GuidedMatchView.swift`

| Context | Layout |
|---------|--------|
| iPhone portrait | Current `List` — unchanged |
| **iPhone landscape** | **Keep `List`** — do NOT use `NavigationSplitView` on phone |
| iPad regular | `NavigationSplitView` — unchanged |
| iPad landscape | Narrower sidebar (220–300pt) — verify at AX3 |

**Key change:** Gate `NavigationSplitView` on `UIDevice.current.userInterfaceIdiom == .pad`, not `horizontalSizeClass == .regular`.

#### `ArmySelectionView.swift`

| Aspect | Plan |
|--------|------|
| Layout | `Form` + readable width |
| Phone landscape | Form scrolls naturally; inline nav title |
| Large text | `ContentCoverageBadge` — allow wrap |
| Touch | Save toolbar button ≥ 44pt |

#### `MatchStepDetailView.swift`

| Aspect | Plan |
|--------|------|
| Current | Side-by-side `HStack` when `horizontalSizeClass == .regular` |
| **Phone landscape fix** | Gate two-column layout on **iPad regular**, not phone landscape regular width |
| Large text | Force single column at `isAccessibilitySize` even on iPad |

#### `BattlePhaseTrackerView.swift` — critical path

| Context | Layout strategy |
|---------|-----------------|
| iPhone portrait | Current single-column stacked — **unchanged** |
| **iPhone landscape** | **New layout mode:** compressed single column (see below) |
| iPad portrait | Current 2-column HStack |
| iPad landscape | Current 3-column `BattleTrackerLandscapeLayout` |

**Proposed iPhone landscape layout:**

```
┌──────────────────────────────────────────────────┐
│ Phase bar (horizontal scroll)                    │
├──────────────────────────────────────────────────┤
│ ScrollView: abilities + VP + round checklist       │
│ (single column, tight spacing)                   │
├──────────────────────────────────────────────────┤
│ safeAreaInset: sticky combat bar (if combat)     │
└──────────────────────────────────────────────────┘
```

**Do NOT** use 3-column layout on iPhone landscape. Refactor `isPadLandscape` → `isPadLandscape && idiom == .pad`.

| Sub-component | Phone landscape | Large text |
|---------------|-----------------|------------|
| `PhaseChipRow` | Horizontal scroll (not grid) | Larger chip min width; allow 2-line labels |
| `VictoryPointsCard` | Full width, stacked players | Single column at AX2+ |
| `ArmyTrackerCard` | Collapsed disclosure — not sidebar | Multi-line unit names |
| `BattleTrackerStickyCombatBar` | Full width | Stack name + phase vertically |
| `CombatResolverPanel` | Keep stacked (not side-by-side) | Expand disclosure by default |

#### `BattleTrackerLandscapeLayout.swift`

- Pad landscape only — caller guard: `idiom == .pad`
- Column widths: consider `@ScaledMetric` or increase min widths at accessibility sizes
- At AX4+ on iPad landscape: fallback to 2-column or single column

---

### 5.6 Spearhead / Army Reference

#### `ArmyRosterView.swift`

| Aspect | Plan |
|--------|------|
| Layout | ScrollView + readable width |
| Phone landscape | Readable width; inline title |

#### `UnitWarscrollCard.swift`

| Aspect | Plan |
|--------|------|
| Risk | Stats `HStack` crowds narrow width |
| Fix | `ViewThatFits`: HStack → 2×2 `LazyVGrid` when width < 320 or `isAccessibilitySize` |

---

### 5.7 Combat Roll / Resolver

#### `UnitMatchupEvaluatorView.swift`

ScrollView + readable width — single column scroll on phone landscape.

#### `CombatResolverPanel.swift`

| Aspect | Plan |
|--------|------|
| Current | Side-by-side when regular width |
| **Phone landscape** | Force stacked unless `idiom == .pad` |
| Large text | Always stacked at `isAccessibilitySize` |

#### `RulesGlossaryView.swift`

Replace `.font(.system(size: 6))` bullet with `@ScaledMetric` or SF Symbol.

#### `BattleTacticsReferenceView.swift`

ScrollView + readable width — standard scroll on phone landscape.

---

### 5.8 Rules Tab

#### `RulesReferenceView.swift`

Searchable list — inline nav title on compact height.

#### `RuleSectionDetailView.swift`

| Aspect | Plan |
|--------|------|
| Current | **No `readableContentWidth()`** |
| Fix | Add `readableContentWidth()` for all non–battle-tracker contexts |
| Phone landscape | Prevents 80+ character lines on Pro Max |

---

### 5.9 Settings

#### `SettingsView.swift`

List — low risk; inline title; onboarding replay inherits onboarding landscape behavior.

---

### 5.10 Shared Design System Components

| Component | Strategy |
|-----------|----------|
| `PhaseChip` / `PhaseChipRow` | Grid only on iPad regular; scroll elsewhere; AX → vertical list |
| `GlossaryChip` / `GlossaryChipsRow` | Horizontal scroll on phone — OK |
| `VictoryPointsCard` | Stacked on phone landscape / AX |
| `ArmyTrackerCard` | Disclosure on phone landscape; sidebar only iPad landscape |
| `MatchupSidePanel` | Never side-by-side on phone |
| `ReadableContentWidth` | Extend modifier with explicit context parameter |

---

## 6. Implementation Phases

### Phase 0 — Foundation & policy (1–2 days)

**Blocks everything else.**

1. Update `project.yml` iPhone orientations to include landscape left/right
2. Run `xcodegen generate`
3. Implement `TabletomeLayoutContext` + idiom-aware helpers
4. Refactor `isPadLandscape` call sites to use new context
5. Add unit tests: phone landscape ≠ pad landscape
6. Update `AccessibilitySpec.md` orientations section
7. Create `accessibility/audits/_template.md` and landscape test matrix

**Exit gate:** App builds with iPhone landscape enabled; battle tracker does NOT show 3-column layout on iPhone simulator.

### Phase 1 — Low-risk reading screens (2–3 days)

`HomeView`, `GameSystemDetailView`, `GettingStartedView`, `GuideStepDetailView`, `ArmyRosterView`, `RulesReferenceView`, `RuleSectionDetailView`, `BattleTacticsReferenceView`, `SettingsView`, `EmptyStateView`.

**Exit gate:** Manual pass on iPhone 16 + 16 Pro Max, portrait + landscape, Default + AX3.

### Phase 2 — Walkthrough & onboarding polish (1–2 days)

`OnboardingView`, `SampleTurnWalkthroughView`, `WalkthroughProgressDots`.

### Phase 3 — Guided Match setup flow (3–4 days)

`GuidedMatchView`, `ArmySelectionView`, `MatchStepDetailView`, embedded setup cards.

**Exit gate:** Complete 6-step setup in iPhone landscape without horizontal clipping.

### Phase 4 — Battle Tracker (5–7 days)

Refactor layout selection; iPhone landscape single-column; iPad landscape AX hardening; sticky bar + tab bar inset; component context-aware layouts.

**Exit gate:** One full battle round on iPhone landscape with combat sticky bar; iPad landscape AX3 spot-check.

### Phase 5 — Combat Resolver (2–3 days)

`CombatResolverPanel`, `UnitMatchupEvaluatorView`, `MultiAttackEvaluatorView`, `MatchupSidePanel`.

### Phase 6 — Design system sweep (2–3 days)

Touch targets, `@ScaledMetric`, `ReadableContentWidth` API, reduce motion on remaining animations.

### Phase 7 — Testing, snapshots, documentation (3–4 days)

Device matrix (iPhone SE, 16, 16 Pro Max, iPad 10th gen, iPad Pro 11"); unit + UI tests; manual VoiceOver; spec updates.

---

## 7. Risk Register

| Risk | Severity | Mitigation |
|------|----------|------------|
| iPhone gets iPad 3-column layout when lock removed | Critical | Phase 0 idiom gate before enabling orientations |
| Vertical space starvation (nav + tab + sticky bar) | High | Inline titles; collapse chrome; `safeAreaInset` audit |
| Phase chips unreadable in landscape | High | Horizontal scroll on phone; grid only iPad |
| Pro Max regular width triggers wrong breakpoints | High | Idiom-first gating |
| Battle tracker scope creep | Medium | Ship iPhone landscape compressed single-column first |
| Regression on iPhone portrait | Medium | Portrait is explicit baseline in every PR |

---

## 8. Open Questions (decide in Phase 0)

1. Should iPhone landscape hide the tab bar during Battle Tracker?
2. Readable width on phone landscape — always on prose screens, or only Pro Max?
3. Upside-down portrait on iPhone — include or exclude?
4. Snapshot test infrastructure — invest now or manual-only for v0.1?
5. Combat resolver side-by-side on iPhone Pro Max landscape — recommend never.

---

## 9. Effort Estimate

| Phase | Duration | Cumulative |
|-------|----------|------------|
| 0 Foundation | 1–2 days | 2 days |
| 1 Reading screens | 2–3 days | 5 days |
| 2 Walkthrough | 1–2 days | 7 days |
| 3 Guided Match setup | 3–4 days | 11 days |
| 4 Battle Tracker | 5–7 days | 18 days |
| 5 Combat Resolver | 2–3 days | 21 days |
| 6 Design system sweep | 2–3 days | 24 days |
| 7 Testing & docs | 3–4 days | **~28 days** |

**Minimum viable slice** (Phases 0 + 1 + 4a/4b): ~10 days.

---

## 10. Recommended First PR

1. Phase 0: `TabletomeLayoutContext` + idiom gate (orientations still locked)
2. Fix `RuleSectionDetailView` readable width
3. Gate `MatchStepDetailView` and `CombatResolverPanel` side-by-side on idiom
4. Enable iPhone landscape in `project.yml`
5. Manual smoke test all 22 screens — file issues per screen

---

## Verification

| Field | Value |
|-------|-------|
| Target release | TBD (post v0.1) |
| Last verified | 2026-06-17 |
| Commit | (plan authored) |
| Code paths | All `Features/`, `DesignSystem/`, `App/`, `project.yml` |
