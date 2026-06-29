# Release status

| Field | Value |
|-------|-------|
| **Version** | 1.0.0 (`MARKETING_VERSION` in `project.yml`) |
| **Phase** | **TestFlight** — not App Store production |
| **Branch** | `release/1.0.0` |
| **Build** | **11** (`CURRENT_PROJECT_VERSION` in `project.yml`) — [TestFlight notes](testflight-1.0.0-build-11.md) |

## 1.0.0 scope

Shipped in TestFlight **without launch arguments**:

- **Tabs:** Models (Collection only), Play, Rules, Settings
- **Game systems:** Age of Sigmar Spearhead, Warhammer 40,000 11th Edition, **Combat Patrol (10th Edition rules)**
- **Play:** Guided Match, battle tracker, match history, combat resolver (Spearhead + 11e + CP 10e)

Gated until after 1.0.0 polish (see [ReleaseSurfaceSpec.md](../../specs/ReleaseSurfaceSpec.md)):

- Lists (Muster), Paints, StarCraft TMG, Rules Q&A assistant

**Not planned:** Full 10th Edition matched play — see [PRODUCT_SCOPE.md](../game-modes/PRODUCT_SCOPE.md).

**QA:** Combat Patrol manual pass — [gated-features-testing.md](gated-features-testing.md) §3 (content ships; sign-off pending).

**Telemetry:** Firebase Analytics + Crashlytics in Release/TestFlight (allowlisted events; privacy policy updated 2026-06-29). See [firebase-analytics.md](firebase-analytics.md).

## Dogfood / internal builds

Add `-enable_full_product_surface` in **Edit Scheme → Run → Arguments** to unlock Lists, Paints, StarCraft, Rules Q&A, etc.

`-enable_combat_patrol` is a no-op when CP is already in release defaults (kept for older test schemes).

## Related docs

- [Release checklist (1.0.0 TestFlight)](release_checklist.md)
- [TestFlight build 11 notes](testflight-1.0.0-build-11.md)
- [App Store listing copy](app-store-listing.md)
- [Firebase analytics](firebase-analytics.md)
- [Product scope](../game-modes/PRODUCT_SCOPE.md)
- [Gated features testing backlog](gated-features-testing.md)
- [Feature inventory](../feature-inventory.md)
- [Release surface gates](../../specs/ReleaseSurfaceSpec.md)
