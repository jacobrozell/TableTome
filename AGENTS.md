# Agent guide — Tabletome

Start here for Cursor agents and automated contributors. Human onboarding: [`CONTRIBUTING.md`](CONTRIBUTING.md) + [`docs/development/setup.md`](docs/development/setup.md).

**Last updated:** 2026-10-28

---

## Where we are

**TestFlight, not the App Store.** Branch `release/1.0.0`. Repo version **1.0.0 (11)** in `project.yml`. Upload of build 11 is still an open item in [`docs/release/todo.md`](docs/release/todo.md).

**1.0 promise:** Age of Sigmar **Spearhead** guided play — box, setup, battle, victory, resume — plus **Models** (collection and paints). The Rules tab is Spearhead only. Settings stays.

**Work on this:** the Spearhead path in [`ongoing/spearhead-flawless-guided-match-plan.md`](ongoing/spearhead-flawless-guided-match-plan.md). A stranger should finish a Spearhead game with the box and the app, without the core rules for turn order.

**Do not do this in 1.0:**

- Ungate 40k 11e, Combat Patrol, StarCraft, Lists (Muster), or Rules Q&A
- Grow paints, add a list builder, or start another game mode
- Treat Players Hub as shipped — it is on in Debug only (`-enable_players_hub` in Release)

Code already hides the gated modes. [`Support/ReleaseSurface.swift`](Support/ReleaseSurface.swift) is the switch. Dogfood with `-enable_full_product_surface`. Hide unfinished UI there. Do not delete bundled JSON.

**When docs disagree, trust this order:** `ReleaseSurface.swift`, then [`docs/release/status.md`](docs/release/status.md), then [`docs/feature-inventory.md`](docs/feature-inventory.md). Older TestFlight notes (builds 6–10, and parts of build 11), [`FutureIdeas/`](FutureIdeas/), and the 40k launch plan describe earlier scope. They are not the current surface. Parked rows in [`ongoing/README.md`](ongoing/README.md) are not tasks.

## 1.0.0 release surface (read first)

**Shipped:** Spearhead play, rules, and settings guides, plus Models (collection and paints). **Gated for 1.0:** 40k, Combat Patrol, StarCraft, Lists, Rules Q&A. Do not ungate them in this release.

| Doc | Purpose |
|-----|---------|
| [`docs/release/1.0.0-release-surface.md`](docs/release/1.0.0-release-surface.md) | Verbose agent map — APIs, files, launch args |
| [`specs/ReleaseSurfaceSpec.md`](specs/ReleaseSurfaceSpec.md) | Spec + verification table |
| [`Support/ReleaseSurface.swift`](Support/ReleaseSurface.swift) | Code (with inline agent comments) |

Dogfood other modes: `-enable_full_product_surface` in Run scheme.

---

## Read order (new task)

1. [`docs/feature-inventory.md`](docs/feature-inventory.md) — what ships vs gated vs planned
2. [`ongoing/README.md`](ongoing/README.md) — active implementation work
3. Matching spec in [`specs/README.md`](specs/README.md)
4. [`docs/development/code-map.md`](docs/development/code-map.md) — where code lives
5. Playbook (if applicable): [`docs/development/playbooks/`](docs/development/playbooks/)

---

## Hard rules

| Rule | Detail |
|------|--------|
| **Spec-first** | User-visible behavior needs a spec in `specs/` with an updated Verification block |
| **No secrets** | Never commit `GoogleService-Info.plist`, credentials, or signing files |
| **No `.xcodeproj`** | Regenerate with `xcodegen generate` after `project.yml` changes |
| **Domain purity** | `TabletomeDomain` must not import SwiftUI/UIKit |
| **Release surface** | Gate unfinished UI in `Support/ReleaseSurface.swift` — hide, don't delete |
| **PII in logs** | Never log army names, roster names, player names — see `AnalyticsMetadataKeys` |
| **Git push** | Do not push unless the user explicitly asks |
| **Apple team** | `DEVELOPMENT_TEAM = 7JT2JB89AV` in `project.yml` |

---

## Build & test (quick)

```bash
xcodegen generate
xcodebuild test -scheme TabletomeCI \
  -destination 'platform=iOS Simulator,name=Tabletome' \
  -quiet
```

Use the dedicated **Tabletome** simulator (`Scripts/setup-tabletome-simulator.sh`). XcodeBuildMCP profile: `tabletome` — see [`.cursor/mcp.json`](.cursor/mcp.json).

---

## Common tasks → playbook

| Task | Doc |
|------|-----|
| Add a Firebase / GA4 event | [`docs/development/playbooks/add-analytics-event.md`](docs/development/playbooks/add-analytics-event.md) |
| Add a game system | [`docs/development/playbooks/add-game-system.md`](docs/development/playbooks/add-game-system.md) |
| Ungate a feature for release | [`docs/development/playbooks/ungate-feature.md`](docs/development/playbooks/ungate-feature.md) |
| Add a guided match step | [`docs/development/playbooks/add-guided-match-step.md`](docs/development/playbooks/add-guided-match-step.md) |

---

## Documentation hub

Full index: [`docs/README.md`](docs/README.md)

| Need | Path |
|------|------|
| Code locations | [`docs/development/code-map.md`](docs/development/code-map.md) |
| Local setup + launch args | [`docs/development/setup.md`](docs/development/setup.md) |
| Testing | [`docs/development/testing.md`](docs/development/testing.md) |
| CI | [`docs/development/ci.md`](docs/development/ci.md) |
| Release train | [`docs/release/README.md`](docs/release/README.md) |
| Firebase analytics | [`docs/release/firebase-analytics.md`](docs/release/firebase-analytics.md) |
| Spec index | [`specs/README.md`](specs/README.md) |
| Cross-cutting infra | [`Support/README.md`](Support/README.md) |

---

## Architecture (one screen)

```
Features/ (SwiftUI + ViewModels)
    ↓ protocols
Data/ (Repositories, SwiftData, JSON loaders)
    ↓ types
Domain/ (Engines, models, GameSystemId) — no SwiftUI
```

- **App shell:** `App/TabletomeApp.swift`, `App/RootTabView.swift`, `App/AppDependencies.swift`
- **Navigation:** `Support/Navigation/AppRouter.swift`, `AppTab.swift`
- **Logging:** `Support/Logging/` → Firebase sinks in Release
- **Data layer analytics:** use callbacks (`NearbyMatchSyncService.analyticsHandler`) — Data targets cannot import app logging types

---

## When you change scope

Update **all that apply**:

- Spec Verification block
- [`docs/feature-inventory.md`](docs/feature-inventory.md)
- [`ongoing/README.md`](ongoing/README.md) (active / finished)
- [`docs/release/status.md`](docs/release/status.md) if release stage changes

---

## Cursor rules

Project-specific rules: [`.cursor/rules/ios-agent.mdc`](.cursor/rules/ios-agent.mdc)
