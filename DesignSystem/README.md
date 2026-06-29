# DesignSystem

Reusable SwiftUI components, tokens, and layout helpers. Feature screens compose these rather than duplicating styling.

**Last updated:** 2026-06-29 · Spec: [`specs/DesignSystemSpec.md`](../specs/DesignSystemSpec.md)

---

## Core tokens

| File | Contents |
|------|----------|
| `DesignTokens.swift` | Spacing, radii, typography scale |
| `BrandColors.swift` | Brand palette + semantic colors |
| `BrandCrest.swift` | App mark |
| `TabletomeLayout.swift` | Phone vs pad layout helpers |
| `ReadableContentWidth.swift` | Max readable width on iPad |
| `AccessibilityLayout.swift` | Dynamic Type / touch target helpers |

---

## Shared components

`Shared/` — cross-feature UI:

- Guided match chrome (`GuidedMatchHubChrome`, setup progress)
- Battle tracker (`BattleTrackerSectionTab`, phase guides, VP cards)
- Game guide shells (`GameGuideStartHereShell`, deployment checklists)
- Victory screen (`MatchVictoryScreen`)

Prefer adding here when **two or more features** need the same pattern.

---

## Game-system-specific cards

Organized by tracker mode:

| Folder | Game systems |
|--------|--------------|
| `PhasedRound/` | Spearhead, 40k 11e, Combat Patrol |
| `AltActivation/` | StarCraft TMG |

Getting Started / home cards at root: `SpearheadRulesComparisonCard` peers live under `PhasedRound/` or `AltActivation/`.

---

## Hobby / Models UI

`Hobby/` — form fields, chips, progress rings, adaptive collection layouts used by `Features/Bench/` and `Features/Muster/`.

---

## Feature-adjacent components

Root-level cards tied to one domain but reused in multiple views:

- `GuideStepCard`, `UnitWarscrollCard`, `RollStepCard` — keep here if used across GameGuide + GuidedMatch + CombatRoll
- `GlossaryChip`, `GlossaryEntrySheetView` — rules glossary UX

If a component is **only** used in one feature file, it can stay in `Features/` until a second consumer appears.

---

## Conventions

- Use semantic Dynamic Type text styles — not fixed point sizes
- Minimum **44×44 pt** touch targets ([`AccessibilitySpec.md`](../specs/AccessibilitySpec.md))
- Colors: prefer `BrandColors` / asset catalog semantic colors for dark mode
- New shared control: add preview-friendly struct, document in `DesignSystemSpec.md` if it becomes a pattern

---

## When not to add here

- One-off layout private to a single view → keep in Feature file or `+CompactLayout` extension
- ViewModels and business logic → `Domain/` or `Features/`
