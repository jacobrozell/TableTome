# Warhammer 40,000 — 11th Edition Launch Plan

Non-authoritative backlog. Promote sections to `specs/` as behavior locks.

**Status:** Approved direction (2026-06-17)

**Launch:** Armageddon in stores Saturday **June 20, 2026**. Core rules PDF already published on Warhammer Community.

---

## Decisions (locked)

| # | Decision |
|---|----------|
| 1 | **Ship 11e in production** — not behind `-enable_full_product_surface` |
| 2 | **Clone Spearhead guided play** — same engine patterns and similar UI for newcomers *and* returning 10e players |
| 3 | **New home row** — 40k 11e equally prominent as Spearhead; show a **NEW** badge while the edition is fresh |
| 4 | **Combat Resolver hidden** for 40k at launch; plan a dedicated **11e combat resolver** later (do not reuse Spearhead/AoS engine) |

---

## Product surfaces

Two audiences, one game system (`wh40k-11e`), two entry paths on the game guide home:

```
Home (Play tab)
├── Age of Sigmar: Spearhead          (existing)
└── Warhammer 40,000                  NEW badge
      └── 11th Edition

Game Guide — wh40k-11e
├── Start Here card
│     ├── New to 40k? → Getting Started + Guided Match (Armageddon starter)
│     └── Played 10e? → What's New in 11e → Guided Match (same tracker, migration tips)
├── What's New in 11e          (returning players)
├── Getting Started            (new players, 5–7 steps)
├── Guided Match               (clone of Spearhead flow)
├── Rules Reference            (11e sections + glossary)
└── Official Resources         (core rules PDF, WHC links)

Hidden at launch:
└── Combat Resolver            (future: wh40k-11e engine)
```

`wh40k-10e` stays `comingSoon` and hidden — edition isolation preserved.

---

## Home row — equal weight + NEW badge

**Layout:** Remove single-system welcome card bias when both systems are available. Show `HomeWelcomeCard` only when one system, or replace with a neutral dual-game welcome.

**40k row copy:**

| Field | Value |
|-------|-------|
| Name | Warhammer 40,000 |
| Tagline | New to 40k or upgrading from 10th? Guided setup and table play |
| Edition | 11th Edition |

**NEW badge:**

- Small capsule label on the row (e.g. `NEW` in accent color), same pattern as phase chips
- Gated by a simple release window — e.g. show through **September 2026** or until manually cleared in `ReleaseSurface` / content bundle `launchedAt`
- VoiceOver: "Warhammer 40,000. New edition. …"
- Accessibility id: `home.gameSystem.wh40k-11e`

**ReleaseSurface change:**

```swift
// wh40k-11e → visible in production
// wh40k-10e → still hidden
case "wh40k-11e": return true
case "wh40k-10e": return fullSurfaceEnabled
```

---

## Content pages

### What's New in 11e (returning players)

Multi-step guide (~10 cards). Reuse `GettingStartedView` / `GuideStepDetailView` via new optional JSON field `editionMigrationSteps: [GuideStep]` on `GameSystem` (same shape as `gettingStartedSteps`).

Topics (verify against core rules PDF before ship):

1. Codexes still valid
2. Modular detachments + detachment points
3. Missions follow army / force disposition
4. Terrain as objectives
5. Cover & concealment (−1 BS, Hidden)
6. Charge: roll first, pick target after
7. Fight phase order + fast rolling
8. Sticky battle-shock
9. Coherency, ingress, list-building attachments
10. One stratagem per unit per phase
11. What's not in core yet (Legends app, Crusade in codexes)

Cross-link from Guided Match setup and battle tracker phase coaching for 10e veterans.

### Getting Started (new players)

Standard `gettingStartedSteps` — what you need, army size, battlefield, turn flow, combat sequence, winning, first game tips.

### Start Here card

Fork `NewPlayerStartHereCard` → `FortyKStartHereCard` with two tracks:

| Track | Steps |
|-------|-------|
| **New to 40k** | Preview a Turn (40k) → Getting Started → Guided Match (Armageddon) → Battle tracker |
| **From 10th Edition** | What's New → Guided Match → Battle tracker |

Optional: `SampleTurnWalkthroughView` fork for 40k phases (Command → Move → Shoot → Charge → Fight).

---

## Guided Match — clone Spearhead engine

**Goal:** Same mental model as Spearhead — pick armies, walk setup steps, open battle phase tracker, pass the phone each turn — but powered by 40k-specific JSON and domain rules.

### What we reuse (patterns, not copy-paste)

| Spearhead piece | 40k 11e approach |
|-----------------|------------------|
| `GuidedMatchView` + split nav | Parameterize by `gameSystemId` or thin wrapper `FortyKGuidedMatchView` |
| `MatchSetupStep` + step detail | Same model; steps from `wh40k-catalog-v1.json` |
| `GuidedMatchState` / `PlayerArmySelection` | Generalize store keys: `guided_match_state_{gameSystemId}` |
| `MatchSetupStore` / `BattleTrackerStore` | Keyed by `gameSystemId` |
| `BattlePhaseTrackerView` + tabs | Same UI shell; phase list + coaching from catalog |
| `BattleFlowGuide` | Per-game-system guide steps |
| `PhaseContextCoach` | 11e phase tips (terrain objectives, charge order, etc.) |
| `RoundChecklistCard` | 40k battle round opener (command phase, battle-shock clear, etc.) |
| `UnitFocusSheet` | Later — needs dataslate/unit JSON |
| Coin flip / attacker picker | Reuse for first turn |
| Match sync (Nearby) | Same snapshot pattern, separate notification scope per game system |

### What we build new

| Piece | Notes |
|-------|-------|
| `wh40k-catalog-v1.json` | Factions, detachments metadata, **starter armies** (Armageddon launch), `matchSteps` |
| `Wh40kCatalog` domain models | Mirror `SpearheadCatalog` structure; detachments replace regiment abilities |
| `BundledWh40kCatalogRepository` | Mirror `BundledSpearheadCatalogRepository` |
| `Wh40kBattleRules` | Round count (5), phase list, scoring hooks |
| `Wh40kTurnPhase` or configured `mainTurnPhases` | **Command** not Hero; no Spearhead twist/tactic decks |
| Army detail overlays | `Resources/Rules/Wh40k/armies/{id}.json` — units, abilities (our summaries) |
| `FortyKPhaseGuides` | Replace Spearhead-specific banners (no twist cards, no battle tactics) |
| `Wh40kRulesGlossary` | OC, Concealment, Detachment Points, etc. |
| Migration coaching | Inject "changed from 10e" hints in phase coach when player chose migration path |

### 40k match setup steps (draft)

1. **Choose armies** — faction + detachment(s) or starter matchup (Armageddon)
2. **Build / confirm lists** — points, detachment points spent, enhancements (high level)
3. **Generate mission** — explain force disposition outcome (no card text)
4. **Deploy** — deployment checklist (terrain, objectives-as-terrain, reserves)
5. **Roll for first turn**
6. **Fight the battle** → battle tracker

Returning players: steps 2–3 emphasize detachment modularity and terrain objectives.

### Battle tracker — 40k phases

Main turn phases for 11e (config-driven):

```
Command → Movement → Shooting → Charge → Fight → End of Turn
```

Remove Spearhead-only UI:

- Twist card / battle tactic decks
- Realm battlefield picker
- Regiment ability / Spearhead enhancement pickers
- VP underdog / priority roll Spearhead scoring

Add 40k-specific UI:

- Battle-shock reminder in Command phase
- Terrain objective / OC coaching
- Charge-order reminder (roll then target)
- Concealment / cover coaching in Shooting
- Stratagem cap reminder (one per unit per phase) — no stratagem text, coaching only
- Primary / secondary scoring prompts (concept level until mission JSON exists)

### Starter content for launch weekend

**Minimum viable catalog:**

- **Armageddon** starter matchup (both sides) — fixed rosters, no list building
- 2–4 faction stubs if GW publishes free index/detachment names only (metadata, no card text)
- Generic "custom army" path: faction name + detachment names typed/selected from list without full dataslate

Defer full faction warscroll import to post-launch (same pipeline as Spearhead `armies/{id}.json`).

---

## Rules reference bundle

Populate `wh40k-11e` in `rules-v1.json`:

- `availability: "available"`
- `gettingStartedSteps` (7 steps)
- `editionMigrationSteps` (10–11 steps) — **schema addition**
- `ruleSections` (~20 launch sections): turn overview, command, movement, shooting, charges, fight, battle-shock, scoring, detachments overview, terrain, glossary
- `externalLinks`: 11e core rules PDF, WHC hub, Armageddon product page

Combat sequence section is the anchor for the future 11e `CombatRollEngine`.

---

## Combat resolver (post-launch)

**Hidden** in `GameSystemDetailView` when `gameSystemId == "wh40k-11e"`.

Future work (separate spec):

- `Wh40kCombatRollEngine` — 11e hit/wound/save/damage rules (cover as BS mod, mortal wounds, FNP, etc.)
- `Wh40kCombatResolverPanel` — do not fork Spearhead evaluator; 10e/11e share more with each other than with AoS
- Unit profiles from `Wh40k` army JSON
- Gate via `ReleaseSurface.shows40kCombatResolver`

---

## Schema changes

| Change | File |
|--------|------|
| `editionMigrationSteps: [GuideStep]?` on `GameSystem` | `Domain/Models/RulesContent.swift` — **shipped** (optional decode, default `[]`) |
| `wh40k-catalog-v1.json` + catalog types | New domain + `Resources/Rules/` |
| `gameSystemId` on stores | `MatchSetupStore`, `BattleTrackerStore`, `GuideProgressStore` |
| `showsNewEditionBadge` or date gate | `ReleaseSurface.swift` |
| Optional `launchedAt` on `GameSystem` | For NEW badge expiry without code deploy |

Bump `schemaVersion` only on breaking decoder changes; document in `DataSchemaSpec.md`.

---

## Implementation phases

### Phase 1 — Ship this weekend (guide + visibility)

- [x] `ReleaseSurface`: show `wh40k-11e`
- [x] `rules-v1.json`: content + `availability: available`
- [x] Home row + NEW badge
- [x] `GameSystemDetailView`: 40k Start Here, What's New, Getting Started, Rules; **hide** Combat Resolver & Guided Match
- [x] `EditionMigrationView` (What's New in 11e)
- [x] Tests: decode, visibility, step order

**User can:** discover 40k, read both guides, browse rules. **Cannot:** run guided match yet.

### Phase 2 — Guided match shell (week 1)

- [ ] Generalize stores by `gameSystemId`
- [ ] `wh40k-catalog-v1.json` with Armageddon starter + match steps
- [ ] `GuidedMatchView` works for `wh40k-11e` (army pick + setup steps)
- [ ] Hide Spearhead-only steps via catalog metadata
- [ ] Tests: catalog decode, match state persistence keyed by game system

### Phase 3 — Battle tracker (week 2–3)

- [ ] `Wh40kBattleRules` + phase configuration
- [ ] `BattlePhaseTrackerView` 40k coaching (no Spearhead decks)
- [ ] `BattleFlowGuide` + `PhaseContextCoach` for 11e
- [ ] Migration hints for returning players
- [ ] Tests: phase progression, round boundaries, coach copy

### Phase 4 — Depth (ongoing)

- [ ] Army detail JSON + Unit Focus for Armageddon units
- [ ] Detachment browser (metadata)
- [ ] `Wh40kCombatRollEngine` + resolver UI
- [ ] Match sync for 40k
- [ ] Promote `specs/40k11eGuidedMatchSpec.md` from this doc

---

## Legal & content

- Summaries in our own words; link to official PDFs
- No detachment ability text, mission cards, or dataslate stat blocks in v1 unless cleared
- Wahapedia for research only
- "Last reviewed against 11e core rules" in spec Verification blocks

---

## Open items (minor)

1. NEW badge expiry date — default **2026-09-30**?
2. Dual welcome card on home vs neutral "Pick a game" header
3. Onboarding advertises both Spearhead and 40k 11e equally — dual game cards + dual start buttons on final page
4. Armageddon faction IDs — lock when box contents confirmed pre-order

---

## Related docs

- `specs/GuidedMatchSpec.md` — Spearhead reference implementation
- `specs/GameGuideSpec.md` — getting started pattern
- `FutureIdeas/CombatPatrolVsSpearheadFAQ.md` — FAQ pattern for cross-edition confusion (consider **10e → 11e FAQ** sibling)
- `docs/brainstorm.md` — product vision
