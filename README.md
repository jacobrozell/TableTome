# Tabletome

Offline-first iOS reference and rules companion for Warhammer tabletop games — guided matches, roll evaluation, rules browser, and miniature collection tracking. No account required; all rules data ships in the bundle.

**Status:** TestFlight 1.0.0 (build 4) · **Branch:** `release/1.0.0` · [Release status](docs/release/status.md)

**Shipped in 1.0:** Age of Sigmar **Spearhead** and Warhammer 40,000 **11th Edition**. Gated until post-1.0: Army Lists/Muster, Paints, Combat Patrol, StarCraft TMG, Rules Q&A — see [release surface spec](specs/ReleaseSurfaceSpec.md).

---

## What it does

| Feature | Notes |
|---------|-------|
| **Game system home** | Spearhead + 40k 11e entry points |
| **Guided Match** | Army picker, match setup, battle phase tracker with ability reminders |
| **Roll evaluator** | Spearhead (AoS) + 40k 11e combat resolver |
| **Rules reference** | Offline browser with filter, search, related links |
| **Models (Collection)** | Miniature tracking |
| **Match history** | Local match log |
| **Getting Started** | 5-step GW-aligned Spearhead walkthrough |
| **Settings & legal** | GitHub Pages privacy/support/accessibility |

Full inventory: [`docs/feature-inventory.md`](docs/feature-inventory.md)

---

## Build & run

**Requirements:** Xcode 16+, iOS 17+ simulator or device.

```bash
brew install xcodegen   # once
xcodegen generate

# Build (dedicated Tabletome simulator — avoids clashing with other projects)
xcodebuild build \
  -scheme TabletomeCI \
  -destination 'platform=iOS Simulator,name=Tabletome' \
  -quiet

# Unit tests
xcodebuild test \
  -scheme TabletomeCI \
  -destination 'platform=iOS Simulator,name=Tabletome' \
  -quiet
```

Run `Scripts/setup-tabletome-simulator.sh` once to create the **Tabletome** simulator (iPhone 17, iOS 26.4). Signing uses team `7JT2JB89AV`.

---

## Architecture

| Layer | Role |
|-------|------|
| `Features/` | SwiftUI + MVVM per tab (Play, Rules, Models, Settings) |
| `Domain/` | Combat roll engines, match logic, rules parsing |
| `Data/` | SwiftData repositories |
| `Resources/Rules/` | Bundled JSON rules content (offline) |

System specs: [`specs/README.md`](specs/README.md) · Data schema: [`specs/DataSchemaSpec.md`](specs/DataSchemaSpec.md)

---

## Tests & CI

GitHub Actions runs SwiftLint, build, and unit tests on push/PR. Gated features require launch args — see [`docs/release/gated-features-testing.md`](docs/release/gated-features-testing.md) before ungating.

---

## Documentation map

| Doc | Purpose |
|-----|---------|
| [Release status](docs/release/status.md) | TestFlight iteration tracker |
| [Feature inventory](docs/feature-inventory.md) | Shipped vs gated vs planned |
| [Release checklist](docs/release/release_checklist.md) | Pre-submit gate |
| [Agent build checklist](docs/agent-build-checklist.md) | Phased 0→ship progress |
| [Game modes](docs/game-modes/) | Per-mode verification and scope |
| [FutureIdeas/](FutureIdeas/) | Post-1.0 backlog (Rules AI, MiniMuster port, …) |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Conventions and PR expectations |

---

## Agent tooling

XcodeBuildMCP and iOS Simulator MCP are configured in [`.cursor/mcp.json`](.cursor/mcp.json). Agents pin the `tabletome` XcodeBuildMCP profile and `Tabletome` simulator so builds do not touch other projects.

---

## Data

Bundled JSON under `Resources/Rules/` powers offline reference content. See [`specs/DataSchemaSpec.md`](specs/DataSchemaSpec.md).

---

## GitHub Pages

Legal pages live in `docs/`. Enable **Settings → Pages → Deploy from branch `main` / `/docs`**.

Published at `https://jacobrozell.github.io/TableTome/`

---

## Support

Bug reports and feature requests: [GitHub Issues](https://github.com/jacobrozell/TableTome/issues). In-app tips are not linked from the App Store build (Apple requires StoreKit IAP for optional tips on digital apps).
