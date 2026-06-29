# Tabletome

Offline-first iOS reference and rules companion for Warhammer tabletop games — guided matches, roll evaluation, rules browser, and miniature collection tracking. No account required; all rules data ships in the bundle.

**Status:** TestFlight 1.0.0 (build 8) · **Branch:** `release/1.0.0` · [Release status](docs/release/status.md)

**Shipped in 1.0:** Age of Sigmar **Spearhead**, Warhammer 40,000 **11th Edition**, and **Combat Patrol (10th Edition rules)**. Gated until post-1.0: Army Lists/Muster, Paints, StarCraft TMG, Rules Q&A — see [release surface spec](specs/ReleaseSurfaceSpec.md).

**Agents:** start at [`AGENTS.md`](AGENTS.md)

---

## What it does

| Feature | Notes |
|---------|-------|
| **Game system home** | Spearhead, 40k 11e, Combat Patrol |
| **Guided Match** | Army picker, match setup, battle phase tracker with ability reminders |
| **Roll evaluator** | Spearhead (AoS) + 40k 11e + Combat Patrol combat resolver |
| **Rules reference** | Offline browser with filter, search, related links |
| **Models (Collection)** | Miniature tracking |
| **Match history** | Local match log |
| **Getting Started** | GW-aligned walkthroughs per game system |
| **Settings & legal** | GitHub Pages privacy/support/accessibility |
| **Telemetry** | Firebase Analytics + Crashlytics (Release, allowlisted events) |

Full inventory: [`docs/feature-inventory.md`](docs/feature-inventory.md)

---

## Build & run

**Requirements:** Xcode 16+, iOS 17+ simulator or device.

```bash
brew install xcodegen   # once
xcodegen generate

xcodebuild build \
  -scheme TabletomeCI \
  -destination 'platform=iOS Simulator,name=Tabletome' \
  -quiet

xcodebuild test \
  -scheme TabletomeCI \
  -destination 'platform=iOS Simulator,name=Tabletome' \
  -quiet
```

Run `Scripts/setup-tabletome-simulator.sh` once to create the **Tabletome** simulator. Signing uses team `7JT2JB89AV`.

Full setup (Firebase plist, launch args): [`docs/development/setup.md`](docs/development/setup.md)

---

## Architecture

| Layer | Role |
|-------|------|
| `Features/` | SwiftUI + MVVM per tab (Play, Rules, Models, Settings) |
| `Domain/` | Combat roll engines, match logic, rules parsing |
| `Data/` | SwiftData + JSON repositories |
| `Resources/Rules/` | Bundled JSON rules content (offline) |

| Doc | Role |
|-----|------|
| [`specs/ArchitectureSpec.md`](specs/ArchitectureSpec.md) | Layers, modules, dependency rules |
| [`docs/development/code-map.md`](docs/development/code-map.md) | Where to change code for common tasks |
| [`Features/README.md`](Features/README.md) | Feature folder guide |
| [`Support/README.md`](Support/README.md) | Logging, navigation, release surface |

System specs: [`specs/README.md`](specs/README.md) · Data schema: [`specs/DataSchemaSpec.md`](specs/DataSchemaSpec.md)

---

## Tests & CI

GitHub Actions: content lint, architecture ratchet, build + unit tests. Details: [`docs/development/ci.md`](docs/development/ci.md)

Gated features require `-enable_full_product_surface` — see [`docs/release/gated-features-testing.md`](docs/release/gated-features-testing.md) before ungating.

---

## Documentation map

**Hub:** [`docs/README.md`](docs/README.md)

| Doc | Purpose |
|-----|---------|
| [`AGENTS.md`](AGENTS.md) | Agent quick start, hard rules, playbooks |
| [`CONTRIBUTING.md`](CONTRIBUTING.md) | Conventions + first PR checklist |
| [Release status](docs/release/status.md) | TestFlight iteration tracker |
| [Release docs](docs/release/README.md) | Checklists, telemetry, screenshots |
| [Feature inventory](docs/feature-inventory.md) | Shipped vs gated vs planned |
| [Firebase analytics](docs/release/firebase-analytics.md) | Events, segmentation, GA4 setup |
| [Development setup](docs/development/setup.md) | Simulator, plist, launch args |
| [Code map](docs/development/code-map.md) | Task → file lookup |
| [Testing](docs/development/testing.md) | Schemes, UI identifiers |
| [Playbooks](docs/development/playbooks/) | Step-by-step recipes |
| [Ongoing work](ongoing/README.md) | Active implementation plans |
| [Game modes](docs/game-modes/) | Per-mode verification and scope |
| [FutureIdeas/](FutureIdeas/) | Post-1.0 backlog |
| [Agent build checklist](docs/agent-build-checklist.md) | Phased delivery progress |

---

## Agent tooling

XcodeBuildMCP and iOS Simulator MCP are configured in [`.cursor/mcp.json`](.cursor/mcp.json). Agents pin the `tabletome` XcodeBuildMCP profile and `Tabletome` simulator so builds do not touch other projects.

---

## Data

Bundled JSON under `Resources/Rules/` powers offline reference content. Validate with `python3 Scripts/validate_content.py`. See [`specs/DataSchemaSpec.md`](specs/DataSchemaSpec.md).

---

## GitHub Pages

Legal pages live in `docs/`. Enable **Settings → Pages → Deploy from branch `main` / `/docs`**.

Published at `https://jacobrozell.github.io/TableTome/`

---

## Support

Bug reports and feature requests: [GitHub Issues](https://github.com/jacobrozell/TableTome/issues).
