# Spearhead Helper Roadmap

Tabletome should be the best at-the-table helper for Age of Sigmar Spearhead — not a rules replacement, but the thing you reach for when you forget what happens next.

## Product principles

1. **Remind** — what step comes next in setup, round openers, and phases
2. **Track** — VP, wounds, once-per-battle abilities, loadouts
3. **Resolve** — dice evaluation without rules arguments
4. **Orient** — plain-language hints for pre-game picks and army-specific gotchas

## Current foundation (shipped)

| Area | Status |
|------|--------|
| Starter matchup (Vigilant vs Gnawfeast) | ✅ |
| Guided match setup checklist | ✅ |
| Warscrolls, weapons, abilities | ✅ (2 armies) |
| Battle phase tracker + ability reminders | ✅ |
| Roll evaluator | ✅ |
| Unit matchup + toggleable buffs | ✅ |
| iPad layout, accessibility | ✅ |

---

## Tier 1 — First game essentials ✅

### Round opener checklist ✅
Per battle round, walk through Spearhead’s pre-turn sequence:

- Round 1: attacker picks first turn
- Round 2+: priority roll → winner picks first turn
- Identify underdog (fewer VP)
- Draw twist card
- Draw battle tactic cards (tactic **or** command, not both)
- Start of battle round abilities

**Code:** `BattleRoundChecklist`, `RoundChecklistCard`, persisted in `BattleTrackerState`

### Victory point tracker ✅
- Player 1 / Player 2 VP totals
- Quick buttons: +1 objective, +2 objectives, +1 more objectives than opponent, +1 battle tactic
- Manual adjust for corrections
- Link to `spearhead-scoring` rule section

**Code:** `VictoryPointsCard`, `BattleTrackerState.playerOneVictoryPoints` / `playerTwoVictoryPoints`

### Wound counters ✅
- Per-unit wounds remaining for featured armies
- Initialized from `health × modelCount`
- Stepper on battle tracker + warscroll cards

**Code:** `UnitWoundCapacity`, `UnitWoundTrackerRow`, `modelCount` on `SpearheadUnit`

### Regiment & enhancement hints ✅
Optional `newPlayerHint` on catalog options — one sentence “good when…” for beginners.

**Code:** `ArmyRuleOption.newPlayerHint`, enriched `spearhead-catalog-v1.json` for starter armies

---

## Tier 2 — Starter-set depth

### Army gotcha cards ✅
Contextual reminders for rules that trip up first-timers:

| Army | Gotchas |
|------|---------|
| Vigilant Brotherhood | Storm Charge, Shield of Azyr, Liberator reinforcements |
| Gnawfeast Clawpack | Tunnels / Gnawhole Ambush, Call for Reinforcements synergy |

**Code:** `SpearheadGotchaCatalog`, `ArmyGotchaCard` in battle tracker

### Both loadouts visible ✅
Collapsible strip showing both players’ regiment ability + enhancement during battle.

### Ability → roll tool deep links ✅
From ability cards: open Roll Evaluator or Unit Matchup when relevant.

---

## Tier 3 — Combat depth ✅

- Multi-attack helper (sequential rolls, running damage total) — embedded in Unit Matchup
- Crit (Mortal), variable damage (D3/D6), Shoot in Combat toggles — Roll Evaluator + Unit Matchup
- Glossary chips: contest, wholly within, visible — ability cards + Rules Glossary screen

## Tier 3.5 — Roll simulator (planned)

For players without enough physical dice — see [DiceRollerSpec.md](DiceRollerSpec.md):

- **v1 (ship):** Roll buttons in combat resolver; d6 hit/wound/save/ward + D3/D6/2D6 damage; verified RNG
- **Future:** Dice tray — animations, roll log, standalone polyhedral roller (interactive / fun)

## Tier 4 — Reference & setup ✅

- Realm side coin flip — fair Aqshy/Ghyran picker on realm setup + battle tracker deployment
- Deployment / terrain checklist — Battle Tracker (round 1) + realm setup step
- Battle tactic card reference — Battle Tactics & Twists screen
- Twist deck reminder copy — included in battle tactics reference
- Share/print cheat sheet — *later*
- Additional Spearhead armies at warscroll tier — *later*

---

## “First game mode” bundle

Target flow for a new player with the Skaventide / Ultimate Starter Set:

```
Learn → Starter armies (warscroll reference)
  → Guided Match → Use Starter Matchup
  → Setup steps (hints on regiment / enhancement)
  → Battle Tracker
      → Round checklist
      → VP tracker
      → Wound counters
      → Gotcha cards
      → Phase abilities
  → Roll Evaluator / Unit Matchup
```

---

## Verification

| Field | Value |
|-------|-------|
| Target release | v0.3 |
| Last updated | 2026-06-17 |
| Code paths | `Domain/Models/BattleRoundChecklist.swift`, `Domain/Models/SpearheadGotcha.swift`, `Features/GuidedMatch/BattlePhaseTracker*`, `DesignSystem/RoundChecklistCard.swift`, `DesignSystem/VictoryPointsCard.swift` |
