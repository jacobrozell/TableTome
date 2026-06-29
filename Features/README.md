# Features

SwiftUI screens and ViewModels, organized by user-facing flow. ViewModels are `@MainActor`; they depend on repository **protocols**, not concrete Data types.

**Last updated:** 2026-06-29 · Code map: [`docs/development/code-map.md`](../docs/development/code-map.md)

---

## Tab mapping

| Tab | Folder | Release |
|-----|--------|---------|
| **Models** | `Bench/` | Shipped (Collection); Paints gated |
| **Lists** | `Muster/` | Gated (`-enable_full_product_surface`) |
| **Play** | `Home/`, `GameGuide/`, `GuidedMatch/`, `Play/`, `CombatRoll/`, `MatchHistory/` | Shipped |
| **Rules** | `RulesReference/`, `Search/` | Shipped |
| **Settings** | `Settings/` | Shipped |
| **Onboarding** | `Onboarding/` | Shipped (overlay, not a tab) |

Root composition: `App/RootTabView.swift` · Play shell: `Play/PlayShell.swift`.

---

## Folder guide

### `Home/`

Play tab landing — game system chooser, continue card, box picker sheets.

### `GameGuide/`

Getting Started walkthroughs, game system detail, sample turn views, army roster previews.

### `GuidedMatch/`

Match setup hub: army selection, setup checklist, sync sheet, hub tabs leading to battle tracker.

Key files: `GuidedMatchViewModel.swift`, `GuidedMatchView.swift`, `MatchStepDetailView.swift`.

Analytics extensions: `GuidedMatchViewModel+Analytics.swift`, `+MatchLog.swift`.

### `Play/`

Battle phase tracker and game-system-specific tracker variants.

| Subfolder | Purpose |
|-----------|---------|
| `Shared/` | Core `BattlePhaseTrackerView` + ViewModel |
| `PhasedRound/` | Spearhead, 40k 11e, Combat Patrol phased rounds |
| `AltActivation/` | StarCraft TMG alternating activation |

### `CombatRoll/`

Standalone hit/wound/save evaluator wizard.

### `MatchHistory/`

Saved match list and detail from victory flow.

### `Bench/`

Models tab — collection, armies, paints (gated).

### `Muster/`

Army lists / rosters (gated).

### `RulesReference/`

Offline rules browser for the Rules tab.

### `Search/`

App-wide search destination (Rules tab entry).

### `Settings/`

About, legal links, theme, replay tour, data management entry points.

### `Onboarding/`

First-launch app tour (shown from `RootTabView`).

---

## Conventions

- **No feature-to-feature imports** — share via `Domain/` or `DesignSystem/`
- **Large views:** split with `+PadLayout.swift`, `+CompactLayout.swift`, `+Analytics.swift`
- **Specs:** each major flow has a matching `specs/*Spec.md`
- **Release surface:** check `Support/ReleaseSurface.swift` before exposing new tabs

---

## Adding a feature

1. Spec in `specs/`
2. ViewModel + unit tests
3. SwiftUI with DesignSystem components
4. Update [`docs/feature-inventory.md`](../docs/feature-inventory.md)
5. Playbook if applicable: [`docs/development/playbooks/`](../docs/development/playbooks/)
