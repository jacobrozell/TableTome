# Release Surface Spec

## Module

`Support/ReleaseSurface.swift` — single source for "is feature X reachable?"

## Launch Arguments

| Argument | Effect |
|----------|--------|
| `-enable_full_product_surface` | Show gated features (Lists tab, Paints, Combat Patrol, StarCraft, Rules Q&A, etc.) |
| `-enable_wh40k_combat_resolver` | Enable 11e combat resolver (QA) |

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
| Roll evaluator | ✅ | ✅ |
| AoS Spearhead | ✅ | ✅ |
| 40k 11th Edition | ✅ | ✅ |
| Combat Patrol (10e CP) | ❌ | ✅ |
| StarCraft TMG | ❌ | ✅ |
| 40k 10th Edition | ❌ | ✅ |

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
