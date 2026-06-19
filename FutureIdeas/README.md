# Future Ideas

Non-authoritative backlog. Promote to `specs/` when behavior locks.

## Unified app (Tabletome + MiniMuster)

Merge hobby tracking (prep), roster building (muster), and guided play into one app. **Canonical repo: Tabletome.** MiniMuster iOS is frozen as port source.

- Phased plan: [UnifiedAppPlan.md](UnifiedAppPlan.md)
- Catalog ID crosswalk: [CatalogKeyAudit.md](CatalogKeyAudit.md)
- Port freeze policy: [MiniMusterPortFreeze.md](MiniMusterPortFreeze.md)

## Monetization (MAYBE)

Subscription-first hobby OS brainstorm — gate depth not hype, free play for all shipped systems: [MonetizationPlan.md](MonetizationPlan.md).

## Beta feedback

Playtest notes and feature options: [BetaFeedback.md](BetaFeedback.md).

## Gated features (post–1.0.0 TestFlight)

Testing backlog before ungating Lists, Paints, Combat Patrol, StarCraft, Rules Q&A, etc.: [../docs/release/gated-features-testing.md](../docs/release/gated-features-testing.md).

## New player first launch

June 2026 audit (shipped checklist): [NewPlayerUXAudit.md](NewPlayerUXAudit.md).  
Next-phase plan — shorter onboarding, continuation state, progressive tabs: [NewPlayerFirstLaunchPlan.md](NewPlayerFirstLaunchPlan.md).

## Match history & log

**Promoted:** [MatchHistorySpec.md](../specs/MatchHistorySpec.md) — v0 ships victory screen + global history. Event log: v1 in [MatchHistoryAndLog.md](MatchHistoryAndLog.md).

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

## Play engine architecture refactor (blocking)

Scalable play layer: registry, unified catalog repo, `PlayEngine` protocol, capability-driven UI, tracker split by engine. **Prerequisite for multi-franchise.** [PlayEngineArchitectureRefactor.md](PlayEngineArchitectureRefactor.md)

## Multi-franchise expansion (Blood Bowl, Star Wars, Middle-earth, …)

Play-engine taxonomy and phased roadmap for franchises beyond Warhammer — **after architecture refactor.** [MultiFranchiseExpansionPlan.md](MultiFranchiseExpansionPlan.md)

## StarCraft: Tabletop Miniatures Game

Skirmish companion for Archon/Blizzard’s SC TMG — supply/reserves, alternating activations, guided match clone. Research draft: [StarCraftTMGLaunchPlan.md](StarCraftTMGLaunchPlan.md). Rules PDF free at [starcraft-tmg.com/downloads](https://starcraft-tmg.com/downloads).

## 40k Combat Patrol (10th Edition)

**Promoted to spec:** [40k10eCombatPatrolSpec.md](../specs/40k10eCombatPatrolSpec.md) — guided play for CP box sets; separate home row from 11e.

## 40k 11th Edition launch

Ship plan, guided-play clone of Spearhead, home row + NEW badge: [40k11eLaunchPlan.md](40k11eLaunchPlan.md).

Rules research + draft JSON: [40k11eRulesContent.md](40k11eRulesContent.md) → `Resources/Rules/wh40k-11e-content-draft.json`.

Separate `gameSystems` entries with edition-specific combat engines (10e vs 11e may diverge).

## Battle Tactic Card Browser

Requires licensing review for card text. Consider user-entered notes only in v1.
