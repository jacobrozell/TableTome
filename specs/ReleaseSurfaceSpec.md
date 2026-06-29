# Release Surface Spec

## Module

`Support/ReleaseSurface.swift` — single source for "is feature X reachable?"

## Product scope

See [docs/game-modes/PRODUCT_SCOPE.md](../docs/game-modes/PRODUCT_SCOPE.md). Planned modes: **AoS Spearhead + Full**, **40k 11e + Combat Patrol (10e rules)**, **StarCraft TMG**. **Full 10th Edition matched play is not planned** — only Combat Patrol uses 10e rules.

## Launch Arguments

| Argument | Effect |
|----------|--------|
| `-enable_full_product_surface` | Lists tab, Paints, StarCraft, Rules Q&A, legacy `wh40k-10e` stub visibility, cross-pillar links |
| `-enable_combat_patrol` | No-op when CP already in release defaults; kept for older test schemes |

## Gates (1.0.0 Release defaults)

| Feature | Release | Full Surface |
|---------|---------|--------------|
| Models tab (Collection) | ✅ | ✅ |
| Paints (in Models) | ✅ | ✅ |
| Lists tab (Muster) | ❌ | ✅ |
| Play tab | ✅ | ✅ |
| Rules reference | ✅ | ✅ |
| Rules Q&A assistant | ❌ | ✅ |
| Match history | ✅ | ✅ |
| Roll evaluator | ✅ Spearhead + 11e + CP | ✅ Spearhead + 11e + CP |
| AoS Spearhead | ✅ | ✅ |
| 40k 11th Edition (full) | ✅ | ✅ |
| Combat Patrol (**10th Edition rules**) | ✅ | ✅ |
| StarCraft TMG | ❌ | ✅ |
| 40k 10th Edition (full matched play) | ❌ | ❌¹ |

¹ Legacy `wh40k-10e` id only — **not** Combat Patrol. Full 10e matched play is out of product scope; do not ungate without a new product decision.

Combat Patrol uses `Wh40k10eCombatRollEngine`. 11e uses `Wh40k11eCombatRollEngine`. Spearhead uses AoS combat resolution.

## Gated feature testing (future work)

Before ungating StarCraft, Lists, or Rules Q&A, complete the matching checklist in [docs/release/gated-features-testing.md](../docs/release/gated-features-testing.md). **Paints** ungated in build 11.

Combat Patrol ships in release defaults — run CP manual QA from that doc before App Store if not already signed off.

## Verification

| Field | Value |
|-------|-------|
| Target release | 1.0.0 |
| Distribution phase | TestFlight → App Review |
| Last verified | 2026-06-26 |
| Branch | release/1.0.0 |
| Code paths | `Support/ReleaseSurface.swift` |
| Release status doc | `docs/release/status.md` |
| Gated features testing | `docs/release/gated-features-testing.md` |
| Product scope | `docs/game-modes/PRODUCT_SCOPE.md` |
