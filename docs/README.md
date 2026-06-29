# Documentation index

Hub for humans and agents. Repo entry point: [`README.md`](../README.md) · Agent quick start: [`AGENTS.md`](../AGENTS.md).

**Last updated:** 2026-06-29

---

## Product state

| Doc | Purpose |
|-----|---------|
| [feature-inventory.md](feature-inventory.md) | Shipped vs gated vs planned features |
| [release/status.md](release/status.md) | TestFlight version, build, branch |
| [../ongoing/README.md](../ongoing/README.md) | Plans actively in implementation |
| [../FutureIdeas/](../FutureIdeas/) | Post-1.0 backlog (not specced or not started) |
| [brainstorm.md](brainstorm.md) | Non-authoritative ideas |
| [game-modes/PRODUCT_SCOPE.md](game-modes/PRODUCT_SCOPE.md) | AoS vs 40k vs CP vs TMG scope |

---

## Behavior (authoritative specs)

| Doc | Purpose |
|-----|---------|
| [../specs/README.md](../specs/README.md) | Full spec index + governance |
| [../specs/ArchitectureSpec.md](../specs/ArchitectureSpec.md) | Layers, modules, dependency rules |
| [../specs/ReleaseSurfaceSpec.md](../specs/ReleaseSurfaceSpec.md) | Feature gating contract |
| [game-modes/](game-modes/) | Per-mode verification, content, launch plans |

**Conflict order:** ArchitectureSpec → system specs → feature specs → feature-inventory → brainstorm.

---

## Release train

| Doc | Purpose |
|-----|---------|
| [release/README.md](release/README.md) | Release folder index |
| [release/release_checklist.md](release/release_checklist.md) | Pre-submit gate |
| [release/todo.md](release/todo.md) | Open ship blockers |
| [release/gated-features-testing.md](release/gated-features-testing.md) | QA before ungating |
| [release/firebase-analytics.md](release/firebase-analytics.md) | Analytics, Crashlytics, segmentation |
| [release/screenshot-script.md](release/screenshot-script.md) | App Store screenshot workflow |
| [../marketing-screenshots/README.md](../marketing-screenshots/README.md) | Capture scripts output |

---

## Development

| Doc | Purpose |
|-----|---------|
| [development/setup.md](development/setup.md) | Xcode, simulator, Firebase plist, launch args |
| [development/code-map.md](development/code-map.md) | **Where is the code for X?** |
| [development/testing.md](development/testing.md) | Schemes, unit/UI tests, identifiers |
| [development/ci.md](development/ci.md) | GitHub Actions gates |
| [development/playbooks/](development/playbooks/) | Step-by-step task recipes |
| [../CONTRIBUTING.md](../CONTRIBUTING.md) | Conventions + first PR checklist |
| [agent-build-checklist.md](agent-build-checklist.md) | Phased delivery progress |

---

## Code structure

| Doc | Purpose |
|-----|---------|
| [../Features/README.md](../Features/README.md) | Feature folders by tab / flow |
| [../Support/README.md](../Support/README.md) | Logging, navigation, release surface, flags |
| [../DesignSystem/README.md](../DesignSystem/README.md) | Tokens and shared UI |
| [../specs/DataSchemaSpec.md](../specs/DataSchemaSpec.md) | Bundled JSON + SwiftData schema |

---

## Hosted (GitHub Pages)

Legal and support HTML in this folder (`privacy.html`, `support.html`, `accessibility.html`). Published at `https://jacobrozell.github.io/TableTome/`.
