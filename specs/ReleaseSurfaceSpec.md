# Release Surface Spec

## Module

`Support/ReleaseSurface.swift` — single source for "is feature X reachable?"

**Agent deep-dive:** [`docs/release/1.0.0-release-surface.md`](../docs/release/1.0.0-release-surface.md) (file map, API cheat sheet, ungate checklist)

## Product scope (1.0.0)

**Shipped:** Age of Sigmar **Spearhead** (`aos-spearhead`) for Play, Guided Match, Rules, and Settings game-guide links. **Models** (Collection + Paints) ships without game-system gating.

**Bundled but hidden until post-1.0 or launch args:** 40k 11e, Combat Patrol (10e), StarCraft TMG. See [docs/game-modes/PRODUCT_SCOPE.md](../docs/game-modes/PRODUCT_SCOPE.md) for long-term franchise plans.

## Launch Arguments

| Argument | Effect |
|----------|--------|
| `-enable_full_product_surface` | All play modes, Lists tab, StarCraft, Rules Q&A, legacy `wh40k-10e` stub visibility, cross-pillar links |
| `-enable_all_play_modes` | 40k 11e + Combat Patrol on **Play tab home** only |
| `-enable_combat_patrol` | Combat Patrol visibility (`showsCombatPatrol`) |

## Gates (1.0.0 Release defaults)

| Feature | Release | Full Surface |
|---------|---------|--------------|
| Models tab (Collection) | ✅ | ✅ |
| Paints (in Models) | ✅ | ✅ |
| Lists tab (Muster) | ❌ | ✅ |
| Play tab | ✅ (Spearhead-only home) | ✅ all modes |
| Rules reference | ✅ Spearhead only | ✅ all visible systems |
| Rules Q&A assistant | ❌ | ✅ |
| Match history | ✅ (Spearhead matches) | ✅ |
| Roll evaluator / combat resolver | ✅ Spearhead only | ✅ per-system capabilities |
| Guided Match | ✅ Spearhead only | ✅ 40k + CP + SC where configured |
| AoS Spearhead | ✅ | ✅ |
| 40k 11th Edition (full) | ❌ | ✅ |
| Combat Patrol (**10th Edition rules**) | ❌ | ✅ |
| StarCraft TMG | ❌ | ✅ |
| 40k 10th Edition (full matched play) | ❌ | ❌¹ |

¹ Legacy `wh40k-10e` id only — **not** Combat Patrol. Full 10e matched play is out of product scope.

Combat Patrol uses `Wh40k10eCombatRollEngine`. 11e uses `Wh40k11eCombatRollEngine`. Spearhead uses AoS combat resolution.

## Entry-point guards

| Surface | Gate API | Load guard |
|---------|----------|------------|
| Guided Match destination | `showsGuidedMatch(for:)` | `GuidedMatchDestinationView.load()` |
| Game guide detail | `isGameSystemIdVisible(_:)` | `GameSystemDetailView.load()` |
| Rules browser | `isGameSystemVisible(_:)` | `RulesReferenceViewModel.load()` |

## Gated feature testing (future work)

Before ungating 40k, Combat Patrol, StarCraft, Lists, or Rules Q&A, complete the matching checklist in [docs/release/gated-features-testing.md](../docs/release/gated-features-testing.md).

## Verification

| Field | Value |
|-------|-------|
| Target release | 1.0.0 |
| Distribution phase | TestFlight → App Review |
| Last verified | 2026-10-28 |
| Branch | release/1.0.0 |
| Code paths | `Support/ReleaseSurface.swift` |
| Release status doc | `docs/release/status.md` |
| Agent map | `docs/release/1.0.0-release-surface.md` |
| Gated features testing | `docs/release/gated-features-testing.md` |
| Product scope | `docs/game-modes/PRODUCT_SCOPE.md` |
| Unit tests | `Tests/Unit/ReleaseSurfaceTests.swift` — release defaults = Spearhead only |
