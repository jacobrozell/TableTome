# Ongoing work

Plans and projects **in implementation** — approved, specced, and actively being built (not shipped yet).

| Stage | Where it lives |
|-------|----------------|
| Idea / not specced | [`FutureIdeas/`](../FutureIdeas/) |
| **In implementation** | **This folder** |
| Ship blockers / release train | [`docs/release/`](../docs/release/) |
| Shipped behavior | [`specs/`](../specs/) + [`docs/feature-inventory.md`](../docs/feature-inventory.md) |

**Last updated:** 2026-10-27

## Active

| Plan | Doc | Status | Notes |
|------|-----|--------|-------|
| **Spearhead flawless Guided Match** | [`spearhead-flawless-guided-match-plan.md`](spearhead-flawless-guided-match-plan.md) | **Active — P0** | Master plan: Spearhead-owned GM module, setup + battle + combat for new players |
| Players Hub | [`specs/features/PlayersHubSpec.md`](../specs/features/PlayersHubSpec.md) | **Implemented — gated** | On in Debug; Release via `-enable_players_hub`. Manual Jacob/Chris playtest before ungating |
| Combat Patrol catalog | [`combat-patrol-catalog-expansion.md`](combat-patrol-catalog-expansion.md) | **In progress** | 6/23 patrols in picker; P1 rosters added, unit JSON next |
| Guided Match UI redesign | [`guided-match-ui-redesign.md`](guided-match-ui-redesign.md) | **In progress** | Phase 1 complete; single-surface battle |
| SwiftUI view extraction | [`swiftui-view-extraction-plan.md`](swiftui-view-extraction-plan.md) | **Incremental** | Phases 0–7 named targets done; remaining `@ViewBuilder`s (mostly Spearhead battle UI) on touch via the Cursor rule |
| WH40k 11e launch | [`docs/game-modes/wh40k-11e/launch-plan.md`](../docs/game-modes/wh40k-11e/launch-plan.md) | In progress | Phase 1 rules shipped; Phase 2 guided match in flight |
| Unified app port | [`FutureIdeas/UnifiedAppPortLog.md`](../FutureIdeas/UnifiedAppPortLog.md) | In progress | Living MiniMuster→Tabletome port tracker |
| Gated features QA | [`docs/release/gated-features-testing.md`](../docs/release/gated-features-testing.md) | CP shipped — manual QA pending | StarCraft, Rules Q&A before ungate |

## See also

- TestFlight status: [`docs/release/status.md`](../docs/release/status.md)
- Ship blockers: [`docs/release/todo.md`](../docs/release/todo.md)
- Post-1.0 expansion: [`FutureIdeas/MultiFranchiseExpansionPlan.md`](../FutureIdeas/MultiFranchiseExpansionPlan.md)

## Finished (archive)

_Move rows here when shipped._

| Plan | Doc | Status | Notes |
|------|-----|--------|-------|
| App audit + Guided Match UX supplement | Cursor plans (`tabletome_app_audit`, `guided_match_ux_supplement`) | **Complete — manual QA pending** | Deep links (`tabletome://` now registered), play-from-roster, landscape chrome, a11y/copy fixes, `GuidedMatchResumeUITests`. 40k 11e resolver copy + iPad tracker columns cancelled |
| Guided Match setup friction | [`guided-match-setup-friction.md`](guided-match-setup-friction.md) | **Complete** | Onboarding→Guided Match, inline setup UX, status copy |
| Beginner UI polish | [`beginner-ui-polish-plan.md`](beginner-ui-polish-plan.md) | **Complete** | Glossary sheets, Play tab badge, path dedupe |
| New player first launch | [`FutureIdeas/NewPlayerFirstLaunchPlan.md`](../FutureIdeas/NewPlayerFirstLaunchPlan.md) | **Complete** | P0–P2 checklist done |
| New player UX fixes | [`FutureIdeas/NewPlayerUXAudit.md`](../FutureIdeas/NewPlayerUXAudit.md) | **Complete** | P0–P2 checklist shipped |
| Unit info and loadout | [`unit-info-and-loadout-fix-plan.md`](unit-info-and-loadout-fix-plan.md) | **Complete** | Keywords, detail popup, loadout confirm, enhancement auto-apply (2026-07-01). Cosmetic lock + keyword glossary left open |
| Pre-battle loadout UI | [`pre-battle-loadout-ui-design.md`](pre-battle-loadout-ui-design.md) | **Superseded** | Design notes; implementation landed in the unit-info plan |
| Collection / Models new-player UX | — | **Complete** | Intro sheet, coach, starter-box unit prefill, import/export tests, `CollectionFlowUITests` |
