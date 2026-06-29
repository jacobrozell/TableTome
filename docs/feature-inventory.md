# Feature Inventory

What the build exposes today vs planned. Updated when release surface changes.

**Current release:** 1.0.0 TestFlight — see [docs/release/status.md](release/status.md).

| Feature | Status | Release | Notes |
|---------|--------|---------|-------|
| Game system home | **shipped** | 1.0.0 | Spearhead + 40k 11e + Combat Patrol (10e rules) |
| Spearhead Getting Started walkthrough | **shipped** | 1.0.0 | 5-step GW-aligned flow |
| Spearhead Guided Match | **shipped** | 1.0.0 | Army picker + match setup |
| 40k 11e Guided Match | **shipped** | 1.0.0 | Armageddon + four 11e Battleforces (roster-level) |
| Battle phase tracker | **shipped** | 1.0.0 | Phase-filtered unit ability reminders |
| Rules reference browser | **shipped** | 1.0.0 | Filter, search, related links |
| Models (Collection) | **shipped** | 1.0.0 | Miniature tracking |
| Roll evaluator | **shipped** | 1.0.0 | Spearhead (AoS) + 40k 11e + Combat Patrol 10e |
| 40k 11e combat resolver | **shipped** | 1.0.0 | 11e Guided Match + standalone resolver |
| Combat Patrol (10e rules) | **shipped** | 1.0.0 | `wh40k-10e-cp` — not 11e; not full 10e matched play |
| Match history | **shipped** | 1.0.0 | Local match log |
| Settings & legal links | **shipped** | 1.0.0 | GitHub Pages docs |
| Paints inventory | **shipped** | 1.0.0 (build 11) | Models tab segment; catalog swatches + autocomplete |
| Army lists (Muster) | gated | post-1.0 | `-enable_full_product_surface` |
| Full 10e matched play | **not planned** | — | See [PRODUCT_SCOPE.md](game-modes/PRODUCT_SCOPE.md) |
| StarCraft TMG | gated | post-1.0 | `-enable_full_product_surface` |
| Rules Q&A assistant | stub | post-1.0 | Behind release gate |
| Telemetry | **shipped** | 1.0.0 | Firebase Analytics + Crashlytics in Release; see [firebase-analytics.md](release/firebase-analytics.md) |
| Localization (non-en) | planned | v1.x | Files in repo when added |

**Gated feature testing:** [docs/release/gated-features-testing.md](release/gated-features-testing.md) — complete before ungating each item above.

**Game mode documentation:** [docs/game-modes/PRODUCT_SCOPE.md](game-modes/PRODUCT_SCOPE.md) — supported vs planned modes.

**Legend:** shipped = reachable in Release without launch args; gated = hidden unless `-enable_full_product_surface`; stub = code boundary only; planned = spec/backlog only.
