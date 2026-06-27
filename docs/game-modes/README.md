# Game mode documentation

Authoritative specs stay in [`specs/`](../../specs/). This folder collects **mode-specific** research, verification audits, launch plans, and scope notes — one directory per play mode.

**Product scope (what we build):** [PRODUCT_SCOPE.md](PRODUCT_SCOPE.md)

| Mode | `GameSystemId` | Rules / format | Status | Folder |
|------|----------------|----------------|--------|--------|
| Age of Sigmar — Spearhead | `aos-spearhead` | AoS 4e Spearhead | **Shipped** | [aos-spearhead/](aos-spearhead/) |
| Age of Sigmar — full / standard | — | Battletomes, matched play | **Planned** | [aos-standard/](aos-standard/) |
| Warhammer 40,000 — 11th Edition | `wh40k-11e` | 11e full game | **Shipped** | [wh40k-11e/](wh40k-11e/) |
| Warhammer 40,000 — Combat Patrol | `wh40k-10e-cp` | **10th Edition** patrol format | **Shipped** | [combat-patrol/](combat-patrol/) |
| Warhammer 40,000 — 10th Edition (full) | — | Matched play, points lists | **Not planned** | [wh40k-10e/](wh40k-10e/) |
| StarCraft: The Miniatures Game | `sc-tmg` | SC TMG | Gated | (spec in `FutureIdeas/`) |

## Cross-mode

| Doc | Topic |
|-----|-------|
| [PRODUCT_SCOPE.md](PRODUCT_SCOPE.md) | Supported vs deferred modes; CP = 10e rules |
| [FutureIdeas/CombatPatrolVsSpearheadFAQ.md](../../FutureIdeas/CombatPatrolVsSpearheadFAQ.md) | CP vs Spearhead expectations |
| [specs/PlayEngineArchitectureSpec.md](../../specs/PlayEngineArchitectureSpec.md) | Shared play-engine registry |

## Local GW reference PDFs (not bundled)

| Mode | Folder |
|------|--------|
| AoS Spearhead | `FutureIdeas/aos-downloads/` |
| 40k 11e / 10e | `FutureIdeas/gw-downloads/` |

## Promotion pipeline

`FutureIdeas/` brainstorm → mode doc here → [`specs/`](../../specs/) when behavior locks → implementation → [`docs/feature-inventory.md`](../feature-inventory.md).
