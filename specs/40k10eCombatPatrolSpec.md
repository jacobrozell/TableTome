# Warhammer 40,000 — Combat Patrol (10th Edition)

## User Story

As a Combat Patrol player at the table, I pick my patrol box, walk through mission setup, and use the battle tracker to coach 10th Edition turns, scoring, secondaries, and stratagems — offline, without list building.

## Locked Decisions (2026-06-17)

| # | Decision |
|---|----------|
| 1 | Game system id: **`wh40k-10e-cp`** (display: *Warhammer 40,000: Combat Patrol*, edition: *10th Edition*). Deprecate bare `wh40k-10e` stub — do not surface in UI. |
| 2 | **Two home rows** — Combat Patrol (10e) and Warhammer 40,000 (11e Armageddon) as separate entries. CP is explicitly 10th Edition. |
| 3 | **Track all table state needed to play** — selected secondary (one per player from two options), stratagem usage, Battle Ready (+10 VP), VP tally, secured objectives, mission-specific flags (razed markers, claimed sites, intel recovered, etc.). |
| 4 | **Bundle rules in-app** — full 10e core + Combat Patrol format in `rules-v1.json`. Section ids **must use mode-specific prefixes** (`10e-*`, `cp-*`, `glossary-cp-*`) — never reuse AoS or 11e ids. See `DataSchemaSpec.md` naming table. Import via `Scripts/import_combat_patrol_from_wahapedia.py`. |
| 5 | Clone Spearhead guided-play engine; separate catalog `combat-patrol-catalog-v1.json`. |
| 6 | Combat resolver ships for CP (10e engine); 11e stays behind `-enable_wh40k_combat_resolver` until ready. |
| 7 | Featured launch: Leviathan **Space Marines CP vs Tyranids CP**. |

**Source rules:** [GW Combat Patrol rules PDF](https://assets.warhammer-community.com/warhammer40000_combatpatrol_rules_eng.24.09-rbtns7zwbh.pdf) (Sept 2024), [WHC Combat Patrol hub](https://www.warhammer-community.com/en-gb/articles/TDeIzUX3/combat-patrol-rules-and-missions-everything-you-need-to-play-this-fresh-new-mode/), per-faction CP PDFs on Warhammer Community downloads.

---

## Product Surfaces

```
Home (Play tab)
├── Age of Sigmar: Spearhead
├── Warhammer 40,000: Combat Patrol     (10th Edition)
└── Warhammer 40,000                    (11th Edition — Armageddon)

Game Guide — wh40k-10e-cp
├── Start Here card
├── Getting Started (7 steps)
├── Guided Match
├── Rules Reference (bundled 10e core + CP format)
├── Missions Reference (6 missions + securing rules)
├── Combat Resolver (embedded in battle tracker + practice tool)
└── Official Resources (PDF links)
```

### Home row — Combat Patrol

| Field | Value |
|-------|-------|
| Name | Warhammer 40,000: Combat Patrol |
| Tagline | Quick box-set battles — guided setup and table play |
| Edition | 10th Edition |
| Accessibility id | `home.gameSystem.wh40k-10e-cp` |

No NEW badge (reserved for 11e freshness window).

---

## Format Rules (GW Combat Patrol 10e)

| Topic | Rule |
|-------|------|
| Army | Fixed CP box roster + CP datasheets |
| List building | None — patrol + enhancement + secondary |
| Board | 44" × 30" |
| Duration | ~1 hour, **5 battle rounds** |
| Phases | Command → Movement → Shooting → Charge → Fight |
| Victory | Most VP; tie = draw |
| Army wipe | No models at start of turn → opponent may finish turns, then compare VP |
| Battle Ready | Fully painted army = **+10 VP** |

### Securing objectives (CP missions)

At end of **your** Command phase: if you control an objective and one or more **Battleline** units (not Battle-shocked) are in range → objective is **secured**. Secured markers stay under your control without models in range until opponent controls at end of a later Command phase.

### Reserves (CP missions)

No arrivals in battle round 1. Units not on board by end of battle round 3 = destroyed (including embarked).

### Pre-battle sequence (11 GW steps → 8 app steps)

| Step ID | Title | GW steps |
|---------|-------|----------|
| `choose-armies` | Choose Combat Patrols | 1 |
| `pick-enhancement` | Pick Enhancement | 1 |
| `determine-mission` | Pick Mission | 2 |
| `setup-battlefield` | Set Up Battlefield | 3, 4 |
| `declare-formations` | Declare Formations | 5 |
| `deploy-armies` | Deploy Armies | 6 |
| `roll-first-turn` | Roll for First Turn | 7, 8 |
| `fight-battle` | Fight the Battle | 9–11 |

Formations step covers: Patrol Squads splits, Leader attachments, Transport embarkation, Reserves.

---

## Six Missions

| D6 | ID | Mission rule | Primary |
|----|-----|--------------|---------|
| 1 | `clash-of-patrols` | Retrieve Intelligence (R2+, +1CP per objective once; Warlord on field) | Take and Hold |
| 2 | `archeotech-recovery` | Irradiated Power Cells (remove NML markers R3–R5) | Recover Archeotech |
| 3 | `forward-outpost` | Sabotage Enemy Comms (block Command Re-roll) | Vital Ground |
| 4 | `scorched-earth` | Raze and Ruin | Raze and Ruin |
| 5 | `sweeping-raid` | Supply Lines (D6 4+ = 1CP) | Priority Targets |
| 6 | `display-of-might` | Break Their Spirit + Claim Sites | Symbolic Sites |

Round 5 (most missions): second-turn player scores VP at **end of turn**, not end of Command phase.

Missions ship inline in `combat-patrol-catalog-v1.json` `missions[]` with deployment map notes and objective positions.

---

## Guided Match Flow

```
Game Guide → Guided Match
  → Player 1: name + faction + Combat Patrol army
  → Player 2: name + faction + Combat Patrol army
  → Match setup (8 steps)
  → Battle Phase Tracker
```

### Featured starter

| Field | Value |
|-------|-------|
| Armies | `space-marines-combat-patrol` vs `tyranids-combat-patrol` |
| Title | Space Marines vs Tyranids |
| Badge | Leviathan Combat Patrol |
| Defaults | Clash of Patrols; default enhancements |

### Persistence

- Setup: `guided_match_state_wh40k-10e-cp`
- Battle: `battle_tracker_state_wh40k-10e-cp`

---

## Battle Tracker State to Track

| State | When set | Notes |
|-------|----------|-------|
| Selected mission | Setup | D6 or manual pick |
| Attacker / defender | Setup | Deployment zones |
| Enhancement per player | Setup | Default or optional |
| **Secondary objective per player** | Setup | Pick **one** of two army options |
| Battle formations | Setup | Patrol splits, leader attachments, transports, reserves |
| First turn player | Setup | Roll off |
| Battle Ready per player | Setup or tracker | +10 VP at end |
| Secured objectives | Each Command phase | Which markers locked by Battleline |
| VP tally | Scoring windows | Primary + secondary + Battle Ready |
| Mission flags | Per mission | e.g. razed markers, claimed sites, intel recovered per objective |
| Stratagem used | During battle | Track uses of 3 bespoke stratagems per army |
| Reserves arrived | R2–R3 | Warn before auto-destroy at end R3 |

### Phase flow

```
Deployment (R1) → Command → Movement → Shooting → Charge → Fight → End of Turn
```

### Coaching (CP-specific)

- Command: battle-shock, secure objectives, mission actions, primary scoring (R2+)
- End of turn R5: second-player scoring reminder
- Mission rule banner by round
- Stratagem cap reminders (reactive timing)
- Patrol Squads / leader attachment display

### Hide for CP

Spearhead twist/tactic decks, realm picker, underdog VP, 11e Force Disposition / Chapter Approved copy.

---

## Content

### Catalog (24 factions)

`Resources/Rules/combat-patrol-catalog-v1.json` — factions, armies, missions, matchSteps.

`Resources/Rules/CombatPatrol/armies/{id}.json` — optional detail overlay.

Per army (from GW CP PDF):

| Field | Count |
|-------|-------|
| Roster + CP datasheets | Box contents |
| Enhancements | 2 (`isDefault` on catalog entry) |
| Secondary objectives | 2 (player picks one) |
| Stratagems | 3 (coaching summaries; one reactive) |
| Patrol Squads | Where applicable |

**Catalog depth phases:**

| Phase | Armies |
|-------|--------|
| P0 | Space Marines CP, Tyranids CP — full datasheets |
| P1 | Orks, Necrons, Custodes, Guard — roster + options |
| P2 | Remaining 18 — stubs + `officialRulesURL` |

### Rules bundle (`rules-v1.json` → `wh40k-10e-cp`)

**Naming:** Each section id is prefixed by layer. Do not share ids with `aos-spearhead` or `wh40k-11e`.

| Category | Id prefix | Section ids (authoritative) |
|----------|-----------|----------------------------|
| `core` | `10e-` | `10e-overview`, `10e-turn-overview`, `10e-command-phase`, `10e-attack-sequence`, `10e-shooting`, `10e-charge-fight`, `10e-movement`, `10e-battle-shock`, `10e-oc`, `10e-cover-concealment` |
| `combatPatrol` | `cp-` | `cp-overview`, `cp-pre-battle`, `cp-securing`, `cp-reserves`, `cp-battle-ready`, `cp-missions`, `cp-scoring` |
| `glossary` | `glossary-cp-*`, `glossary-*-10e` | `glossary-cp-secure`, `glossary-cp-patrol-squads`, `glossary-cp-battle-ready`, `glossary-cp-leaders`, `glossary-cp-reserves`, `glossary-oc-10e` |

**Guide steps** use `relatedRuleSectionId` from this table only (e.g. getting started step 1 → `cp-overview`, step 6 → `10e-turn-overview`).

**Catalog `matchSteps`** same rule — e.g. `determine-mission` → `cp-missions`, `fight-battle` → `cp-scoring`.

Content authored in JSON; import script validates id prefixes per game system. External PDF links in `externalLinks`.

### Schema extensions

Optional on `SpearheadArmy` / catalog (backward compatible):

```json
{
  "secondaryObjectives": [{ "id", "name", "summary", "scoringHint" }],
  "stratagems": [{ "id", "name", "summary", "cpCost", "phase", "isReactive" }],
  "enhancements": [{ "id", "name", "summary", "isDefault", "timing" }],
  "warlordUnitId": "string"
}
```

Catalog top-level: `missions[]`.

Add `combatPatrol` to `RuleSectionCategory` in `RulesContent.swift`. Category picker filters via `GameSystemRulesLabels.availableCategories(gameSystemId:)` — CP shows Core | Combat Patrol | Glossary only.

---

## Architecture

| Spearhead | Combat Patrol |
|-----------|---------------|
| `aos-spearhead` | `wh40k-10e-cp` |
| `BundledSpearheadCatalogRepository` | `BundledCombatPatrolCatalogRepository` |
| `DeploymentChecklist` | `CombatPatrolDeploymentChecklist` |
| `SpearheadBattleRules` (4 rounds) | `CombatPatrolBattleRules` (5 rounds, Command-first) |
| Card Decks Guide | Missions Guide |

Shared: `GuidedMatchView`, `SpearheadCatalog` types, `SpearheadArmyMerger`, stores keyed by `gameSystemId`.

New domain/UI files listed in implementation checklist below.

---

## Implementation Phases

### Phase 0 — Spec & content

- [x] Lock game system id: `wh40k-10e-cp`
- [x] Promote spec
- [ ] Verify Leviathan CP rosters vs GW PDFs
- [x] Author `combat-patrol-catalog-v1.json` missions array

### Phase 1 — Guide + visibility

- [x] `RuleSectionCategory.combatPatrol` + game-system-scoped category labels
- [x] `rules-v1.json`: `wh40k-10e-cp` with prefixed section ids (`10e-*`, `cp-*`, `glossary-cp-*`)
- [x] `ReleaseSurface`: show CP; hide `wh40k-10e` stub
- [x] Home row (second 40k row)
- [x] `GameSystemRulesLabels` — tab/search copy for `wh40k-10e-cp`
- [x] Getting Started + Rules Reference + Missions reference
- [x] Tests: decode, section id prefix lint, category filter per system

### Phase 2 — Guided match

- [x] Catalog + Leviathan armies
- [x] `BundledCombatPatrolCatalogRepository`
- [x] `CombatPatrolFeaturedArmies`
- [x] 8 setup steps, mission picker, formations
- [x] Secondary + enhancement picks persisted on `PlayerArmySelection`
- [x] Tests: catalog merge, persistence

### Phase 3 — Battle tracker

- [x] `CombatPatrolBattleRules` in `BattleRules`
- [x] Branch flow guide, deployment, round checklist
- [x] Mission-aware scoring + secure objectives + VP / Battle Ready
- [x] Secondary progress + stratagem tracking
- [x] Tests: phase progression, tracked state

### Phase 4 — Depth

- [x] Full Leviathan detail JSON
- [x] Unit Focus, gotchas, search index
- [x] `import_combat_patrol_from_wahapedia.py`
- [x] Sample turn walkthrough (10e Command phase)
- [x] Match sync

### Phase 5 — Combat resolver (post-launch)

- [x] `Wh40k10eCombatRollEngine` + `ReleaseSurface` gate

---

## Legal

Summaries in our words; link to official PDFs. No verbatim stratagem/secondary card text unless cleared. Wahapedia for research only.

---

## Related

- `specs/GuidedMatchSpec.md` — Spearhead reference
- `specs/SpearheadContentSpec.md` — army JSON pipeline
- `specs/RulesReferenceSpec.md` — v0.3 CP scope
- `FutureIdeas/40k11eLaunchPlan.md` — parallel 11e track
- `FutureIdeas/CombatPatrolVsSpearheadFAQ.md` — cross-format FAQ

---

## Verification

| Field | Value |
|-------|-------|
| Target release | v0.3 |
| Last verified | 2026-06-17 |
| Commit | (spec promoted; implementation not started) |
| Code paths | `Features/GuidedMatch/`, `Features/GameGuide/`, `Resources/Rules/combat-patrol-catalog-v1.json`, `Resources/Rules/rules-v1.json`, `Support/ReleaseSurface.swift`, `Domain/Models/BattleRules.swift` |
