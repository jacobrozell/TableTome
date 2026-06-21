# Release Surface Spec

## Module

`Support/ReleaseSurface.swift` — single source for "is feature X reachable?"

## Launch Arguments

| Argument | Effect |
|----------|--------|
| `-enable_full_product_surface` | Lists tab, Paints, StarCraft, Rules Q&A, 40k 10e, cross-pillar links |
| `-enable_combat_patrol` | Combat Patrol game system (10e engine — not included in full surface) |
| `-enable_wh40k11e_combat_resolver` | 11e combat resolver QA (11e engine — separate from Combat Patrol) |

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
| Roll evaluator | ✅ Spearhead | ✅ Spearhead; 11e² |
| AoS Spearhead | ✅ | ✅ |
| 40k 11th Edition | ✅ | ✅ |
| Combat Patrol (10e CP) | ❌ | ❌¹ |
| StarCraft TMG | ❌ | ✅ |
| 40k 10th Edition | ❌ | ✅ |

¹ Requires `-enable_combat_patrol` (separate from full surface — all armies + polish pending).

² 11e uses `Wh40k11eCombatRollEngine` — not Combat Patrol. Requires `-enable_wh40k11e_combat_resolver` until rules pass ships.

## Gated feature testing (future work)

Before ungating any row above, complete the matching checklist in [docs/release/gated-features-testing.md](../docs/release/gated-features-testing.md) (unit gaps, manual QA, UI automation, promotion criteria).

## Verification

| Field | Value |
|-------|-------|
| Target release | 1.0.0 |
| Distribution phase | TestFlight (not App Store production) |
| Last verified | 2026-06-19 |
| Branch | release/1.0.0 |
| Code paths | `Support/ReleaseSurface.swift` |
| Release status doc | `docs/release/status.md` |
| Gated features testing | `docs/release/gated-features-testing.md` |
