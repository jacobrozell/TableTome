# Ongoing work

Plans and projects **in implementation** — approved, specced, and actively being built (not shipped yet).

| Stage | Where it lives |
|-------|----------------|
| Idea / not specced | [`FutureIdeas/`](../FutureIdeas/) |
| **In implementation** | **This folder** |
| Ship blockers / release train | [`docs/release/`](../docs/release/) |
| Shipped behavior | [`specs/`](../specs/) + [`docs/feature-inventory.md`](../docs/feature-inventory.md) |

**Last updated:** 2026-10-28

**Do this:** Spearhead guided play for someone who has the box and has not played. Collection and paints stay as they are. Do not ungate other modes. Visual work follows the UI overhaul.

## Active

| Plan | Doc | Status | Notes |
|------|-----|--------|-------|
| **1.0 UI overhaul** | [`ui-overhaul/README.md`](ui-overhaul/README.md) | **In progress** | Spearhead-only 1.0, Tome & Table design system, battle screen rebuild |
| **1.0.0 review fixes** | [`1.0.0-review-fixes.md`](1.0.0-review-fixes.md) | **Fixes in** | Release-branch blockers are fixed. UI overhaul review is ingested; unit tests never started because the simulator runner hung. |
| **Spearhead flawless Guided Match** | [`spearhead-flawless-guided-match-plan.md`](spearhead-flawless-guided-match-plan.md) | **Active — P0** | Setup, battle, combat, victory, resume. Stay inside Spearhead. |
| Guided Match UI redesign | [`guided-match-ui-redesign.md`](guided-match-ui-redesign.md) | **Superseded by UI overhaul** | Phase 1 complete; further chrome work is in `ui-overhaul/`. |
| SwiftUI view extraction | [`swiftui-view-extraction-plan.md`](swiftui-view-extraction-plan.md) | **Incremental** | Only when already editing those views. Not a feature. |

## Parked — not this release

| Plan | Doc | Status | Notes |
|------|-----|--------|-------|
| Players Hub | [`specs/features/PlayersHubSpec.md`](../specs/features/PlayersHubSpec.md) | **Implemented — gated** | On in Debug; Release via `-enable_players_hub` |
| Combat Patrol catalog | [`combat-patrol-catalog-expansion.md`](combat-patrol-catalog-expansion.md) | **Parked** | Stays gated. Resume after Spearhead is submitted. |
| WH40k 11e launch | [`docs/game-modes/wh40k-11e/launch-plan.md`](../docs/game-modes/wh40k-11e/launch-plan.md) | **Parked** | The launch plan’s “ship 11e” decision is superseded. |
| Unified app port | [`FutureIdeas/UnifiedAppPortLog.md`](../FutureIdeas/UnifiedAppPortLog.md) | **Parked** | MiniMuster port tracker. Not 1.0. |
| Gated features QA | [`docs/release/gated-features-testing.md`](../docs/release/gated-features-testing.md) | **Parked** | 40k, Combat Patrol, StarCraft, Lists, Rules Q&A |

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
