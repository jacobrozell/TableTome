# Game mode documentation

Authoritative specs stay in [`specs/`](../../specs/). This folder collects **mode-specific** research, verification audits, launch plans, and scope notes — one directory per play mode.

| Mode | `GameSystemId` | Status | Folder |
|------|----------------|--------|--------|
| Age of Sigmar — Spearhead | `aos-spearhead` | **Shipped** (default) | [aos-spearhead/](aos-spearhead/) |
| Age of Sigmar — standard | — | Not supported | [aos-standard/](aos-standard/) |
| Warhammer 40,000 — 11th Edition | `wh40k-11e` | **Shipped** | [wh40k-11e/](wh40k-11e/) |
| Warhammer 40,000 — 10th Edition | — | Not supported (legacy id only) | [wh40k-10e/](wh40k-10e/) |
| Warhammer 40,000 — Combat Patrol | `wh40k-10e-cp` | Gated | [combat-patrol/](combat-patrol/) |

## Cross-mode

| Doc | Topic |
|-----|-------|
| [FutureIdeas/CombatPatrolVsSpearheadFAQ.md](../../FutureIdeas/CombatPatrolVsSpearheadFAQ.md) | CP vs Spearhead expectations for players switching modes |
| [specs/PlayEngineArchitectureSpec.md](../../specs/PlayEngineArchitectureSpec.md) | Shared play-engine registry and capabilities |

## Local GW reference PDFs (not bundled)

| Mode | Folder |
|------|--------|
| AoS Spearhead | `FutureIdeas/aos-downloads/` |
| 40k 11e / 10e | `FutureIdeas/gw-downloads/` |

## Promotion pipeline

`FutureIdeas/` brainstorm → mode doc here → [`specs/`](../../specs/) when behavior locks → implementation → [`docs/feature-inventory.md`](../feature-inventory.md).
