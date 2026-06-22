# Release Surface Spec

## Module

`Support/ReleaseSurface.swift` — single source for "is feature X reachable?"

## Launch Arguments

| Argument | Effect |
|----------|--------|
| `-enable_full_product_surface` | Lists tab, Paints, StarCraft, Rules Q&A, 40k 10e, cross-pillar links |
| `-enable_combat_patrol` | Combat Patrol only (10e engine — SM/Tyranids today) |

## Gates (1.0.0 Release defaults)

| Feature | Release | Full Surface |
|---------|---------|--------------|
| Models tab (Collection) | ✅ | ✅ |
| Paints (in Models) | ❌ | ✅ |
| Lists tab (Muster) | ❌ | ✅ |
| Play tab | ✅ | ✅ |
| Rules reference | ✅ | ✅ |
| Rules Q&A assistant | ❌ | ✅ |
| Match history | ✅ | ✅ |
| Roll evaluator | ✅ Spearhead + 11e | ✅ Spearhead + 11e |
| AoS Spearhead | ✅ | ✅ |
| 40k 11th Edition | ✅ | ✅ |
| Combat Patrol (10e CP) | ❌ | ❌¹ |
| StarCraft TMG | ❌ | ✅ |
| 40k 10th Edition | ❌ | ✅ |

¹ Requires `-enable_combat_patrol` (separate from full surface — all armies + polish pending).

11e combat resolver uses `Wh40k11eCombatRollEngine` and ships in 1.0.0 release defaults for Spearhead and 40k 11e Guided Match.

## Gated feature testing (future work)

Before ungating any row above, complete the matching checklist in [docs/release/gated-features-testing.md](../docs/release/gated-features-testing.md) (unit gaps, manual QA, UI automation, promotion criteria).

## Verification

| Field | Value |
|-------|-------|
| Target release | 1.0.0 |
| Distribution phase | TestFlight → App Review |
| Last verified | 2026-06-22 |
| Branch | release/1.0.0 |
| Code paths | `Support/ReleaseSurface.swift` |
| Release status doc | `docs/release/status.md` |
| Gated features testing | `docs/release/gated-features-testing.md` |
