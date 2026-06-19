# Guided Match Spec — Spearhead Army Selection & Setup

## User Story

As a Spearhead player setting up a game, I pick the specific Spearhead army each player is using (e.g. Vigilant Brotherhood vs. Gnawfeast Clawpack), then follow a guided match setup tailored to those armies.

## Flow

```
Spearhead detail
  → Guided Match
  → Player 1: name + faction + army
  → Player 2: name + faction + army
  → Match setup steps (6)
      → Choose armies (summary)
      → Roll attacker/defender
      → Regiment abilities (army-specific when available)
      → Enhancements (army-specific when available)
      → Realm battlefield
      → Fight the battle
```

## Content

- `Resources/Rules/spearhead-catalog-v1.json` — factions, armies, match steps
- 23 factions; multiple Spearhead armies per faction where GW has released them
- Full regiment ability and enhancement options for armies covered by official GW Spearhead PDFs (Stormcast Eternals, Skaven)

## During the Battle

```
Guided Match (armies selected)
  → Battle Phase Tracker
  → Roll Evaluator (hit / wound / save wizard)
  → Pick round, active player, current phase
  → See abilities available now (Declare / Effect cards)
  → Mark once-per-battle abilities as used
```

Unit ability content is loaded from optional per-army detail files. See `SpearheadContentSpec.md`.

## Behavior

- Match state persisted in UserDefaults (`guided_match_state_aos_spearhead`)
- Changing a player's army clears their regiment/enhancement picks
- Match setup steps disabled until both armies are chosen (except step 1)
- Step completion tracked per step id
- Reset match clears all state
- Battle tracker state persisted in UserDefaults (`battle_tracker_state_aos_spearhead`)
- Phase picker filters abilities; "Show all" lists every ability for learning
- Once-per-battle abilities can be marked used

## Accessibility

- Screen: `guidedMatch.screen`
- Battle tracker: `battleTracker.screen` (iPhone hub embed: `guidedMatch.embeddedBattleTracker`), `battleTracker.phase.{phaseId}`, `battleTracker.ability.{abilityId}`
- Deployment checklist: `deployment.check.{stepId}`, `deployment.done.{stepId}`
- New-player milestone: `newPlayer.milestone.models`, `milestone.openModels`, `milestone.dismiss`
- Launch automation: `-open_battle_tracker` (with `-open_guided_match`, `-skip_onboarding`, `-enable_full_product_surface`)
- Player rows: `guidedMatch.playerOne`, `guidedMatch.playerTwo`
- Army options: `guidedMatch.army.{armyId}`
- Steps: `guidedMatch.step.{stepId}`

## iPad & Layout Polish

See `GuidedMatchUXPolishPlan.md`. Implemented:

- Readable content width (680pt) on scroll views and forms
- `NavigationSplitView` on regular horizontal size class
- Battle Tracker two-column layout on iPad
- Setup progress indicator
- Player-facing coverage badges and richer VoiceOver on ability cards

## Verification

| Field | Value |
|-------|-------|
| Target release | v0.2 |
| Last verified | 2026-06-17 |
| Commit | (guided match) |
| Code paths | `Features/GuidedMatch/`, `Domain/Models/SpearheadCatalog.swift`, `Domain/Models/BattleTracker.swift`, `Resources/Rules/spearhead-catalog-v1.json`, `Tests/Unit/BundledSpearheadCatalogRepositoryTests.swift`, `Tests/Unit/MatchSetupStoreTests.swift`, `Tests/Unit/BattleTrackerTests.swift` |
