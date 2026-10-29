# Release status

| Field | Value |
|-------|-------|
| **Version** | 1.0.0 (`MARKETING_VERSION` in `project.yml`) |
| **Phase** | **TestFlight** — not App Store production |
| **Branch** | `feature/uioverhaul` |
| **Build** | **11** (`CURRENT_PROJECT_VERSION` in `project.yml`) — [TestFlight notes](testflight-1.0.0-build-11.md) |

## 1.0.0 scope

Locked 28 Oct 2026. Code is [`Support/ReleaseSurface.swift`](../../Support/ReleaseSurface.swift).

Shipped **without launch arguments**:

- **Play:** Age of Sigmar Spearhead only — Guided Match, battle tracker, victory, resume, match history, Spearhead combat resolver
- **Rules:** Spearhead rules and glossary
- **Models:** Collection and paints (not game-system gated)
- **Tabs:** Models, Play, Rules, Settings

Gated until a later release (dogfood with `-enable_full_product_surface`):

- Warhammer 40,000 11th Edition, Combat Patrol, StarCraft TMG
- Lists (Muster), Rules Q&A, Players Hub (on in Debug only)

**Not planned:** Full 10th Edition matched play — see [PRODUCT_SCOPE.md](../game-modes/PRODUCT_SCOPE.md). Combat Patrol is a later Tabletome release, not 1.0.

**Work now:** the UI overhaul in [`ongoing/ui-overhaul/README.md`](../../ongoing/ui-overhaul/README.md). The next TestFlight is a new build after that tracker. Stay inside Spearhead. Do not ungate other modes. Do not grow paints. Agent entry: [`AGENTS.md`](../../AGENTS.md).

**QA:** Spearhead path only for this submit. Gated modes stay in [gated-features-testing.md](gated-features-testing.md).

**Telemetry:** Firebase Analytics + Crashlytics in Release/TestFlight (allowlisted events; privacy policy updated 2026-06-29). See [firebase-analytics.md](firebase-analytics.md).

## Dogfood / internal builds

Add `-enable_full_product_surface` in **Edit Scheme → Run → Arguments** to unlock 40k, Combat Patrol, StarCraft, Lists, and Rules Q&A. Paints already ship.

## Related docs

- [Release checklist (1.0.0 TestFlight)](release_checklist.md)
- [TestFlight build 11 notes](testflight-1.0.0-build-11.md)
- [App Store listing copy](app-store-listing.md)
- [Firebase analytics](firebase-analytics.md)
- [Product scope](../game-modes/PRODUCT_SCOPE.md)
- [Gated features testing backlog](gated-features-testing.md)
- [Feature inventory](../feature-inventory.md)
- [Release surface gates](../../specs/ReleaseSurfaceSpec.md)
