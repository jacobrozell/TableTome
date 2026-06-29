# Release documentation

Index for TestFlight and App Store delivery. Current state: [`status.md`](status.md).

**Last updated:** 2026-06-29

---

## Quick links

| Doc | When to use |
|-----|-------------|
| [status.md](status.md) | Version, build, branch, 1.0 scope |
| [release_checklist.md](release_checklist.md) | Pre-submit smoke gate |
| [todo.md](todo.md) | Open ship blockers |
| [gated-features-testing.md](gated-features-testing.md) | QA before ungating Lists, Paints, TMG, Rules Q&A |
| [firebase-analytics.md](firebase-analytics.md) | Telemetry setup, GA4 dimensions, TestFlight smoke |
| [screenshot-script.md](screenshot-script.md) | App Store screenshot capture |
| [testflight-1.0.0-build-8.md](testflight-1.0.0-build-8.md) | Current TestFlight tester notes (build 8) |
| [app-store-listing.md](app-store-listing.md) | App Store Connect copy + privacy labels |

---

## 1.0.0 scope (summary)

**Ships without launch arguments:**

- Tabs: Models (Collection), Play, Rules, Settings
- Game systems: AoS Spearhead, 40k 11e, Combat Patrol (10e rules)
- Play: Guided Match, battle tracker, match history, combat resolver

**Gated** until post-1.0 sign-off: Lists, Paints, StarCraft TMG, Rules Q&A.

Dogfood everything gated: `-enable_full_product_surface` in Run scheme.

Full product scope: [`../game-modes/PRODUCT_SCOPE.md`](../game-modes/PRODUCT_SCOPE.md).

---

## Release workflow

1. Confirm scope in [`status.md`](status.md) and [`../feature-inventory.md`](../feature-inventory.md)
2. Walk [`release_checklist.md`](release_checklist.md)
3. Bump `CURRENT_PROJECT_VERSION` in `project.yml` → `xcodegen generate`
4. Archive + upload TestFlight
5. Telemetry smoke per [`firebase-analytics.md`](firebase-analytics.md)
6. Update `status.md` and workspace project-status docs when stage changes

---

## Related

- Spec gates: [`../../specs/ReleaseSurfaceSpec.md`](../../specs/ReleaseSurfaceSpec.md)
- Active implementation: [`../../ongoing/README.md`](../../ongoing/README.md)
- Marketing assets: [`../../marketing-screenshots/README.md`](../../marketing-screenshots/README.md)
