# StarCraft: Tabletop Miniatures Game — Launch Plan

Non-authoritative backlog. Promote sections to `specs/` as behavior locks.

**Status:** Research draft (2026-06-17) — partial verification from [official rules article](https://starcraft-tmg.com/news/rules/starcraft-tabletop-miniatures-game-rules) (2026-03-31)

**Context:** Rules PDF and P2P card sheets are free on [starcraft-tmg.com/downloads](https://starcraft-tmg.com/downloads). Archon also ships **Command Center** (web/app) for rules lookup, unit/card browser, map editor, and mission drafting — see [positioning vs Command Center](#positioning-vs-command-center) below. Pre-orders shipping after April 2026; remaining gaps verified against physical box + PDF page refs.

---

## North star

**A guided game for StarCraft TMG with the same polish bar as Age of Sigmar Spearhead** — pick factions, walk setup, fight a full match with the battle tracker, pass the phone between activations. Fine-tuned for SC's RTS DNA (supply, reserves, pass/initiative, minerals/vespene), not a Spearhead reskin.

```
Game Guide → Start Here → Guided Match → Battle Tracker → (optional) Combat Resolver
     ↑              same shell as AoS Spearhead; SC-specific coaching + state throughout
```

**Ship target:** a new player (or SC II veteran) can run their **first full game** from the app without hunting the rulebook mid-battle.

**Not in scope for Tabletome:** Archon [Command Center](https://starcraft-tmg.com/news/rules/starcraft-tabletop-miniatures-game-rules) map editor, mission draft UI, or full card browser — link out in setup steps and Official Resources.

---

## What this is

**StarCraft: Tabletop Miniatures Game** (SC TMG) — skirmish wargame by Archon Studio / Blizzard. Combat Patrol–scale battles (~1–2 hr), three factions with sub-factions, supply/reserve deployment, alternating activations, minerals + vespene, tactical cards. IP and vibe are **StarCraft II**; Tabletome copy can say "StarCraft" per official naming.

---

## Verified mechanics (official rules article, 2026-03-31)

Source: [StarCraft Tabletop Miniatures Game Rules](https://starcraft-tmg.com/news/rules/starcraft-tabletop-miniatures-game-rules)

| Mechanic | Confirmed behavior |
|----------|-------------------|
| **Game length** | Standard game = **5 rounds** |
| **Activations** | Players alternate **one unit at a time** until all eligible units have acted in the phase |
| **Passing** | First player to **Pass** in a phase claims the **First Player Marker** → they choose who activates first in the **next** phase |
| **Supply (dynamic)** | Each unit's **current Supply** = remaining models; drops as casualties are taken; caps how many units / how much presence you can have **on table** |
| **Supply pool** | Scenario sets **starting Supply**; **increases each round**; losses **free pool space** → call reinforcements from reserves immediately |
| **Reserves** | **No units on table at start** — entire army in reserves; deploy during play via entry points / deployment rules |
| **Objectives** | Control = **sum of Current Supply Value** of units within **3"** of marker — **not** model count |
| **Pre-game draft** | **Mission + Deployment card draft** with veto/select before play |
| **List building** | **Minerals** → units only; **Vespene Gas** → tactical cards only |
| **Combat flow** | Build Attack Pool → roll Hits → defender rolls **Armour** (each success removes one attack die) → optional **Evade** → unblocked hits → **Damage** |
| **Surge** | Weapons have **Surge Types** (e.g. Light, Armoured); if target **Combat Tag** matches, roll **S Die** → that many hit dice **bypass Armour** straight to Damage Pool |

**Initiative coaching copy (official framing):** passing during Movement to bait opponent deploy, then taking first strike in Assault — e.g. *"Sometimes pass in Movement so you hold First Player in Assault."*

---

## Positioning vs Command Center

Archon's **Command Center** covers pre-game and reference workflows:

| Module | Archon owns | Tabletome v1 |
|--------|-------------|--------------|
| Rules + unit/card browser | **The Game** | Link out; optional short glossary only |
| Map editor + mission generator | **Tools of War** | Link out; preset map **name** in guided match only |
| Mission/deployment **draft** | Pre-game in app | Coach step: "complete draft in Command Center or physical cards" — no draft UI v1 |
| **Live battle** — activations, pass, supply pool, round/phase, VP tally | Weak / absent at table | **Guided game core** — battle tracker is the product |

**Decision (locked):** Do not build map JSON, card browser, or draft UI in v1. Surface Command Center + PDF links inside guided setup; **own the full play session** like Spearhead.

## Decisions (proposed — lock after first preorder play)

| # | Proposal |
|---|----------|
| 1 | **New `gameSystemId`:** `sc-tmg` — separate catalog, battle rules, and persisted match state |
| 2 | **Guided game = ship criterion** — flip `available` when 2P starter guided match + battle tracker are playable end-to-end |
| 3 | **Spearhead parity** — reuse `GuidedMatchView`, setup steps, battle tracker shell, iPad split, quick actions, match sync patterns; **do not** ship a rules-only stub as "v1" |
| 4 | **SC fine-tuning** — activation/pass/marker UX, supply pool, reserves coach, supply-weighted objectives; dedicated phase guides (no twist/tactic decks) |
| 5 | **Combat resolver Phase 2** — after guided tracker ships; `ScCombatRollEngine` distinct from AoS/40k |
| 6 | **Summaries only** — our words + glossary; link official PDFs; no tactical card body text in v1 |
| 7 | **Living rules** — external link; no mirrored points tables in-app |

---

## Product surfaces

Parity with Spearhead's game guide row; **Guided Match is the hero entry**, not an appendix.

```
Home (Play tab)
├── Age of Sigmar: Spearhead
├── Warhammer 40,000
└── StarCraft: Tabletop Miniatures    NEW badge (optional)

Game Guide — sc-tmg
├── Start Here card (ScStartHereCard)
│     ├── New to wargames? → Getting Started → Guided Match (2P starter)
│     └── Played StarCraft II? → RTS → Tabletop bridge → Guided Match
├── Getting Started
├── Guided Match  ★ primary ship surface
│     → setup steps → Battle Phase Tracker (full game)
├── Rules Reference
└── Official Resources (PDF, Command Center, living rules)

Post guided-game v1:
├── Unit Focus (unit cards from catalog JSON)
└── Combat Resolver (ScCombatRollEngine)
```

### Spearhead polish we reuse

| Spearhead piece | SC TMG use |
|-----------------|------------|
| `GuidedMatchView` + iPad `NavigationSplitView` | Same shell; `gameSystemId: sc-tmg` |
| Match setup steps + progress | SC steps (faction, format, mission name, army confirm, terrain, first player) |
| `BattlePhaseTrackerView` tabs (Setup / Turn / Combat / Army) | Same tab model; **Turn tab** becomes activation-centric |
| Phase dock + quick actions | "What's next" tuned for pass/supply/deploy |
| `RoundChecklistCard` | Round opener: supply pool bump, marker reminder |
| Coin flip / first player | SC-themed picker |
| Match sync (Nearby) | Same snapshot pattern, `sc-tmg` scope |
| `NewPlayerStartHereCard` pattern | `ScStartHereCard` + RTS bridge track |
| Unit Focus + batch combat | After unit JSON; SC combat batch flow |

### Spearhead UI we omit

Twist cards, battle tactics, realm battlefield, regiment abilities, Spearhead enhancements, AoS combat engine, OC/ward/Rend coaching.

### SC-only polish (the fine-tuning)

| Surface | Behavior |
|---------|----------|
| **Activation bar** (sticky) | Whose activation; **Activate** done / **Pass** (claims First Player Marker) |
| **First Player Marker card** | Who holds marker; who picks first activation next phase |
| **Supply dock** | Pool cap / used per player; +round increment button; "freed on loss" coach |
| **Reserves banner** | Round 1 reminder: table empty; deploy from reserves in Movement |
| **Objective chip** | "Control = supply sum within 3\"" in Scoring phase |
| **Phase guides** | `ScPhaseGuides` — pass baiting, assault-after-pass, reinforce timing |
| **Army tab** | Roster from starter/catalog; tap → Unit Focus when JSON exists |
| **RTS bridge copy** | APM = activations; fog of war = reserves; economy = minerals + vespene |

---

## How SC TMG differs from Spearhead (drives UX)

| Mechanic | Spearhead / 40k habit | SC TMG |
|----------|----------------------|--------|
| Turn structure | Full phase, then opponent’s phase | **Alternating activations** — one unit at a time per phase |
| Phase initiative | Fixed IGOUGO | **First to Pass** takes **First Player Marker** → picks first activation next phase |
| Army on table | Deployed at start | **Reserves** — empty table; deploy during play |
| List cap | Points | **Minerals** (units) + **Vespene** (tactical cards only) |
| On-field presence | Model count | **Dynamic Supply** — current supply per unit drops with casualties; caps table presence |
| Objectives | Model count / OC | **Sum of Current Supply** within **3"** of marker |
| Combat | Hit → wound → save | Hit pool → **Armour** (cancel dice) → **Evade** → damage; **Surge** bypasses armour on tag match |
| Pre-game setup | Mission pack | **Mission + Deployment card draft** (veto/select) |
| Scoring | VP (edition-specific) | Mission objectives + map control (supply-weighted) |
| Factions | Army + detachment | Faction → **sub-faction** |
| Cards | Twist / battle tactics | Faction + **tactical** + deployment cards (vespene) |

The guided game's signature UX is the **activation loop** — not a phase picker alone. Every activation ends with a clear "Pass or continue?" moment.

---

## Guided game flow (end-to-end)

Mirrors `specs/GuidedMatchSpec.md` + `specs/BattleTableFlowSpec.md` tableside jobs.

### Pre-battle (Guided Match setup)

1. **Commanders** — player names; faction + sub-faction (Terran / Zerg / Protoss)
2. **Battle format** — skirmish vs standard minerals; 36×36 vs 54×36
3. **Mission** — name from draft (physical cards or Command Center); link to draft how-to
4. **Army** — starter preset (2P Founders) or confirm custom list built
5. **Battlefield** — map name; terrain height tiers noted
6. **First activation** — coin flip; round 1 Movement begins
7. **Fight the battle** → battle tracker (persisted `guided_match_state_sc_tmg` / `battle_tracker_state_sc_tmg`)

### During battle (Battle Phase Tracker)

Organize by **tableside jobs** (same principle as Spearhead playtest fixes):

| Tab | Job | SC TMG focus |
|-----|-----|----------------|
| **Setup** | Match summary, mission, supply pools at scenario start | Collapsed after round 1 |
| **Turn** | Phase, round, **activation**, pass/marker, supply dock | **Primary screen** — sticky activation bar |
| **Combat** | Resolver (later) or surge/armour cheat sheet | Phase 2 of guided game |
| **Army** | Reserves vs on-table; unit list; Unit Focus entry | Supply per unit; deploy status |

**Per-activation loop (Turn tab):**

```
Show active player + phase
  → player acts on table (miniatures)
  → tap "Done" (next player's activation) OR "Pass" (take First Player Marker)
  → if all passed / no eligible units → advance phase
  → Scoring: VP stepper + objective reminder
  → end of round 5 → match complete screen
```

**Pass-the-phone:** VoiceOver and visual emphasis on **active commander** (Terran blue / Zerg purple / Protoss gold accents — semantic colors only, no unlicensed art).

### Post-battle

- Match summary (rounds played, final VP)
- Reset match / rematch (same Spearhead pattern)
- Optional: link to Command Center to share map design

**Starter preset for v1:** 2-player Founders Edition (Terran vs Zerg) — fixed rosters, skips list building.

---

## Battle phases (draft — names verified; detail in PDF)

Four phases per **round** (5 rounds standard):

1. **Movement** — deploy from reserves; ruler movement; alternating activations
2. **Assault** — shoot and charge; alternating activations
3. **Combat** — melee; alternating activations
4. **Scoring & cleanup** — objective VP; casualties

**Coaching hooks (article-backed):**

- **Pass** button → claims First Player Marker for **next** phase (not just "skip unit")
- First Player chooses who activates first next phase
- Supply pool: scenario start value, **+each round**; track **used vs cap** per player
- On casualty: current unit supply drops → **freed pool** → reserves coach ("reinforce now?")
- Objective reminder: control = **supply sum within 3"**, not headcount
- Assault-after-pass primer (Movement pass → Assault initiative)
- Surge / Combat Tag reminder in combat coaching (resolver later)

**Still verify in PDF:** height tiers, exact supply ramp per scenario, charge sequence, consolidation.

---

## Battle tracker — SC-specific state

Extend `BattleTracker` (or SC overlay) with:

| State | Purpose |
|-------|---------|
| `currentPhase` | movement \| assault \| combat \| scoring |
| `activationPlayer` | who activates next *within* the phase |
| `firstPlayerMarkerHolder` | who holds marker after last Pass; picks first activation next phase |
| `supplyPoolCap` / `supplyPoolUsed` | per player — scenario start + per-round increases (manual) |
| `onTableSupply` | sum of current supply on field (for objective coach) |
| `roundNumber` | 1…5 |
| `missionScore` | manual VP tally |

Remove / hide Spearhead-only UI: twist cards, battle tactics, realm picker, regiment abilities, Spearhead enhancements.

**UI components (guided-game v1):**

- `ScActivationBar` — sticky; active player, Done, Pass
- `ScFirstPlayerMarkerCard` — marker holder; next-phase first-pick prompt
- `ScSupplyDock` — pool cap/used, per-round bump, freed-on-loss
- `ScReservesBanner` — deploy coach in Movement
- `ScObjectiveChip` — supply-within-3" in Scoring
- `ScPhaseGuides` — collapsible; pass baiting, reinforce timing
- `ScRoundChecklistCard` — round start: supply increase, 5-round countdown

---

## Content bundle

### `rules-v1.json` entry (`sc-tmg`)

- `availability: "comingSoon"` until verified
- `gettingStartedSteps` — what you need, table size, minerals/vespene, four phases, supply/reserves, winning, first game tips
- Optional `rtsBridgeSteps` — same shape as `editionMigrationSteps` on 40k (schema already exists)
- `ruleSections` (~15–20 launch summaries): turn overview, movement, assault, combat, scoring, supply, reserves, deployment, height tiers, minerals/vespene, tactical cards (concept), sub-factions, glossary
- `externalLinks`: rulebook PDF, [rules article](https://starcraft-tmg.com/news/rules/starcraft-tabletop-miniatures-game-rules), Command Center, living rules, FAQ, downloads

### `sc-tmg-catalog-v1.json` (new)

Mirror `spearhead-catalog-v1.json` shape where it fits:

| Entity | Notes |
|--------|-------|
| `factions` | terran, zerg, protoss |
| `subFactions` | e.g. raynors-raiders, kerrigans-swarm, khalai — mechanics summary in our words |
| `starterArmies` | 2P founders box rosters (unit names, categories, supply — **stats TBD**) |
| `matchSteps` | setup flow above |
| `mainTurnPhases` | movement, assault, combat, scoring |
| `maps` | id, name, table size, link anchor in PDF (no map art) |

### Per-army overlays (later)

`Resources/Rules/ScTmg/armies/{id}.json` — unit summaries for Unit Focus (name, category, size tier, counter tags). **Defer** until card stat schema locked from physical unit cards.

---

## Combat resolver (post-launch)

Separate spec when rulebook combat chapter is verified:

- `ScCombatRollEngine` — attack pool → hits → armour saves (per-die cancellation) → evade → damage; **S Die** surge when Combat Tag matches Surge Type
- Not compatible with `CombatRollEngine` (AoS) or future `Wh40kCombatRollEngine`
- Gate: `ReleaseSurface.showsScCombatResolver`

Until then: link to dice reference in rules section + generic dice roller if useful.

---

## Schema & code touchpoints

| Change | Location |
|--------|----------|
| `GameSystem` entry | `Resources/Rules/rules-v1.json` |
| `sc-tmg-catalog-v1.json` + `ScTmgCatalog` models | Mirror Spearhead catalog pattern |
| `BundledScTmgCatalogRepository` | `Data/JSON/` |
| `ScTmgBattleRules` | Phase list, round boundaries, activation semantics |
| Stores keyed by `gameSystemId` | Already planned for 40k — include `sc-tmg` |
| `ReleaseSurface.isGameSystemVisible` | `sc-tmg` → `comingSoon` until flip |
| `ReleaseSurface.showsGuidedMatch` | add `sc-tmg` when Phase 2 ships |
| Home row copy + optional NEW badge | `HomeView`, `ReleaseSurface.showsNewEditionBadge` or `launchedAt` |
| Phase coach | `PhaseContextCoach` extensions or SC-specific coach type |

---

## Implementation phases

**Milestone:** *Guided Game v1* = setup through round 5 with activation/pass/supply/VP — Spearhead-equivalent completeness for 2P starter.

### Phase 0 — Research (parallel)

- [x] [Official rules article](https://starcraft-tmg.com/news/rules/starcraft-tabletop-miniatures-game-rules)
- [ ] PDF + starter set PDF; fill verification checklist
- [ ] Draft `sc-tmg` getting started + RTS bridge + rule section summaries

### Phase 1 — Guided game foundation

Ship together — not a rules-only interim.

- [ ] `rules-v1.json`: `sc-tmg` + getting started + RTS bridge + rule sections + links
- [ ] `sc-tmg-catalog-v1.json`: factions, 2P starter armies, `matchSteps`, `mainTurnPhases`
- [ ] `ScTmgCatalog` + repository; stores keyed `sc-tmg`
- [ ] `GuidedMatchView` for `sc-tmg`: army pick, setup steps, handoff to tracker
- [ ] `ScStartHereCard` on game guide detail
- [ ] `ReleaseSurface`: visibility + `showsGuidedMatch(for: "sc-tmg")`
- [ ] Tests: decode, guided match persistence, starter preset

### Phase 2 — Battle tracker (SC fine-tuning)

- [ ] `ScTmgBattleRules` — 5 rounds × 4 phases, activation semantics
- [ ] Turn tab: `ScActivationBar`, Pass → First Player Marker, phase advance
- [ ] `ScSupplyDock`, `ScReservesBanner`, `ScRoundChecklistCard`
- [ ] Scoring phase VP stepper + `ScObjectiveChip`
- [ ] `ScPhaseGuides` + phase context coach copy
- [ ] Army tab: starter roster list (no Unit Focus yet)
- [ ] Tests: activation alternation, pass/marker, round/phase boundaries, 5-round end

**User can:** play a full guided 2P starter game start to finish.

### Phase 3 — Spearhead parity polish

- [ ] iPad split + readable width (reuse `GuidedMatchUXPolishPlan` patterns)
- [ ] Quick actions / "what's next" on Turn tab
- [ ] Match sync (Nearby) for `sc-tmg`
- [ ] Home row + optional NEW badge
- [ ] VoiceOver pass on activation loop

### Phase 4 — Depth

- [ ] Unit Focus + `ScTmg/armies/{id}.json` (post-preorder stats)
- [ ] `ScCombatRollEngine` + Combat tab resolver
- [ ] Tactical card metadata on army entries
- [ ] Promote `specs/ScTmgGuidedMatchSpec.md`

---

## Legal & content

- Licensed IP — summaries in our own words; prominent links to Archon downloads
- **Do not** reproduce points tables, tactical card rules text, or unit card stat blocks in v1 without review
- Fandom wiki / press articles for research only — **rulebook PDF is source of truth**
- Blizzard / Archon trademarks in UI: “StarCraft” and assets per standard nominative use; no unofficial logos in app iconography without clearance

---

## Open items (resolve when preorder / PDF deep-read)

1. **S Die** faces and exact surge math (custom dice in box)
2. **Supply cap increase** per round — values per scenario type
3. **Deployment methods** (dropship, nydus, etc.) — tracker state vs rules-only
4. **Engagement / skirmish** tarot cards — reference only in v1
5. Sub-faction mechanical deltas — coach copy only
6. **Living rules** URL and update cadence
7. ~~Command Center overlap~~ → **resolved:** link out; no map/card/draft UI in v1
8. 2v2 / shared point pool — out of scope for v1
9. Mineral skirmish (1000) vs standard (2000) — confirm in PDF points section
10. Height tiers / LOS — FAQ says height tiers at setup; article silent

---

## Phase 0 appendix — verification checklist

| Topic | Source | Verified | Notes |
|-------|--------|----------|-------|
| 5-round standard game | [Rules article](https://starcraft-tmg.com/news/rules/starcraft-tabletop-miniatures-game-rules) | ☑ | |
| Alternating unit activations | Rules article | ☑ | |
| Pass → First Player Marker → next phase first pick | Rules article | ☑ | Replaces "finisher goes first" wiki guess |
| Minerals / vespene split | Rules article | ☑ | Vespene = tactical cards only |
| Dynamic supply + pool frees on loss | Rules article | ☑ | |
| Supply increases each round | Rules article | ☑ | Per-scenario values TBD |
| Reserves-only start | Rules article | ☑ | |
| Objective = supply sum within 3" | Rules article | ☑ | |
| Mission + deployment draft | Rules article | ☑ | Pre-game; defer UI to Command Center |
| Combat: hit → armour → evade → damage | Rules article | ☑ | |
| Surge: tag match → S Die → bypass armour | Rules article | ☑ | Light / Armoured examples |
| Phase names & order | PDF | ☐ | Movement → Assault → Combat → Scoring assumed |
| Mineral 1000 / 2000 defaults | PDF / FAQ | ☐ | |
| Height tiers | FAQ / PDF | ☐ | |
| 2P starter roster | Starter PDF | ☐ | |
| S Die faces | Box dice | ☐ | |

---

## Related docs

- `FutureIdeas/40k11eLaunchPlan.md` — multi-game-system rollout pattern
- `specs/GuidedMatchSpec.md` — shell to clone
- `specs/BattleTableFlowSpec.md` — Unit Focus / table flow (reuse when unit JSON exists)
- `specs/DataSchemaSpec.md` — bundle conventions
- Official: [Rules article](https://starcraft-tmg.com/news/rules/starcraft-tabletop-miniatures-game-rules) · [Downloads](https://starcraft-tmg.com/downloads) · [FAQ](https://starcraft-tmg.com/faq)
