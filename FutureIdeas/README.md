# Future Ideas

Non-authoritative backlog. Promote to `specs/` when behavior locks.

## Beta feedback

Playtest notes and feature options: [BetaFeedback.md](BetaFeedback.md).

## Board state tracking

Per-board objective control, active twist card, and battle tactic hands — with end-of-turn VP coaching. Phased plan: [BoardStateTracking.md](BoardStateTracking.md).

## Combat Patrol vs Spearhead FAQ

Players coming from Combat Patrol expect grouped units, leader attachments, and cross-unit cohesion — Spearhead uses standalone roster entries instead. Draft FAQ + placement plan: [CombatPatrolVsSpearheadFAQ.md](CombatPatrolVsSpearheadFAQ.md).

## Roll Evaluator UI

Guided wizard: weapon profile → dice entered → step-by-step evaluation using `CombatRollEngine`. Cite rule section IDs.

## Rules AI assistant (Core AI)

Natural-language Warhammer / Spearhead Q&A grounded on bundled rules, glossary, and warscrolls — on-device via Apple Core AI (Foundation Models). Phased plan: [RulesAIAssistant.md](RulesAIAssistant.md). Gated by `ReleaseSurface.showsRulesAssistant`.

## Faction Content

Import Spearhead warscrolls per faction from GW free downloads. Pipeline: JSON schema extension + content review.

## StarCraft: Tabletop Miniatures Game

Skirmish companion for Archon/Blizzard’s SC TMG — supply/reserves, alternating activations, guided match clone. Research draft: [StarCraftTMGLaunchPlan.md](StarCraftTMGLaunchPlan.md). Rules PDF free at [starcraft-tmg.com/downloads](https://starcraft-tmg.com/downloads).

## 40k 11th Edition launch

Ship plan, guided-play clone of Spearhead, home row + NEW badge: [40k11eLaunchPlan.md](40k11eLaunchPlan.md).

Rules research + draft JSON: [40k11eRulesContent.md](40k11eRulesContent.md) → `Resources/Rules/wh40k-11e-content-draft.json`.

Separate `gameSystems` entries with edition-specific combat engines (10e vs 11e may diverge).

## Battle Tactic Card Browser

Requires licensing review for card text. Consider user-entered notes only in v1.
