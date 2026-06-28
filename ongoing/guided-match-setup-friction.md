# Guided Match setup friction — plan

**Status:** Implemented (2026-06-28)  
**Source:** Simulator walkthrough (fresh install) + Jacob feedback on back-button / “where do I go?” confusion.

## Goal

A new player with a Spearhead (or similar starter) box should reach **Use Starter Matchup → Setup → Up Next** without detours, contradictory copy, or scrolling past finished steps.

## Principles

1. **One obvious next action** per screen — Up Next above the fold on Setup.
2. **Status matches tab** — header/footer copy reflects Armies vs Setup vs Battle.
3. **Inline over push** for setup controls; **Done** when a pushed screen is unavoidable.
4. **Explain auto-fill** after starter matchup so 4/6 progress makes sense.

## Phases

| # | Change | Files | Status |
|---|--------|-------|--------|
| 1 | Onboarding game pick → **Guided Match** (not game guide) for starter-box games | `OnboardingContent.swift` | ☑ |
| 2 | Hide **At the table** roll picker once roll step is complete | `GuidedMatchView.swift` | ☑ |
| 3 | Status bar + Armies footer reflect **active hub tab** and army state | `GuidedMatchHubChrome.swift`, `GuidedMatchView.swift` | ☑ |
| 4 | **Starter matchup handoff** explains auto-filled steps | `GuidedMatchCoachingBanners.swift` | ☑ |
| 5 | **Compact inline** battlefield/deployment (one checklist row + shorter board-side card) | `DeploymentChecklistCard.swift`, `RealmSideCoinFlipCard.swift`, `MatchStepDetailView+InlineCompact.swift` | ☑ |
| 6 | Show **full setup step list** until setup complete (not collapsed by default) | `GuidedMatchView.swift` | ☑ |
| 7 | Battle gate: **single** “Continue on Setup” CTA | `GuidedMatchView.swift` | ☑ |
| 8 | **GuideStepCard** inline hint; army picker **Done** button | `GuideStepCard.swift`, `ArmySelectionView.swift` | ☑ |

## Out of scope (later)

- Army selection as sheet instead of push
- Onboarding + home chooser deduplication on first launch
- Battle tab hard-lock when setup incomplete
- Wizard sheet for full battlefield with explicit Done

## Verification

1. Fresh install → pick Spearhead → lands in **Guided Match** (Armies).
2. Use Starter Matchup → handoff banner → **Setup** tab → **Up Next** visible without scrolling past roll picker.
3. Armies tab footer does not say “unlock setup” when armies are chosen.
4. Status bar on Armies says armies-ready; on Setup shows step progress.
