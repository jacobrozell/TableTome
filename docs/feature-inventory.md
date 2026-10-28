# Feature Inventory

What the build exposes today vs planned. Updated when release surface changes.

**Current release:** 1.0.0 (build 11) — **Spearhead play, collection, and paints.** Locked 28 Oct 2026. See [release/status.md](release/status.md). Active work is the Spearhead guided path only. Do not ungate the rows marked gated.

| Feature | Status | Release | Notes |
|---------|--------|---------|-------|
| Game system home (Play) | **shipped** | 1.0.0 | Spearhead only |
| Spearhead Getting Started walkthrough | **shipped** | 1.0.0 | 5-step GW-aligned flow |
| Spearhead Guided Match | **shipped** | 1.0.0 | Army picker, setup, battle, victory, resume |
| Battle phase tracker | **shipped** | 1.0.0 | Spearhead phase playbook |
| Rules reference browser | **shipped** | 1.0.0 | Spearhead rules + glossary only |
| Models (Collection) | **shipped** | 1.0.0 | Miniature tracking. Not game-system gated. Do not expand for 1.0. |
| Paints inventory | **shipped** | 1.0.0 | Models tab. Catalog swatches + autocomplete. Do not grow for 1.0. |
| Roll evaluator / combat resolver | **shipped** | 1.0.0 | Spearhead (AoS) only in release |
| Match history | **shipped** | 1.0.0 | Spearhead matches, local log |
| Settings & legal links | **shipped** | 1.0.0 | Spearhead guide shortcut |
| Telemetry | **shipped** | 1.0.0 | Firebase Analytics + Crashlytics in Release; see [firebase-analytics.md](release/firebase-analytics.md) |
| 40k 11e Guided Match | gated | post-1.0 | `-enable_full_product_surface` |
| 40k 11e combat resolver | gated | post-1.0 | With 40k visibility |
| Combat Patrol (10e rules) | gated | post-1.0 | `-enable_full_product_surface` or `-enable_combat_patrol` |
| Army lists (Muster) | gated | post-1.0 | `-enable_full_product_surface` |
| StarCraft TMG | gated | post-1.0 | `-enable_full_product_surface` |
| Rules Q&A assistant | stub | post-1.0 | Behind release gate |
| Players Hub | gated | post-1.0 | On in Debug; Release needs `-enable_players_hub` |
| Full 10e matched play | **not planned** | — | See [PRODUCT_SCOPE.md](game-modes/PRODUCT_SCOPE.md) |
| Localization (non-en) | planned | v1.x | Files in repo when added |

**Gated feature testing:** [docs/release/gated-features-testing.md](release/gated-features-testing.md) — complete before ungating each item above.

**Game mode documentation:** [docs/game-modes/PRODUCT_SCOPE.md](game-modes/PRODUCT_SCOPE.md) — supported vs planned modes.

**Legend:** shipped = reachable in Release without launch args; gated = hidden unless `-enable_full_product_surface`; stub = code boundary only; planned = spec/backlog only.
