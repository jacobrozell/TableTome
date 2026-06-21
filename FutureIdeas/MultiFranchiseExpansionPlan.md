# Multi-Franchise Expansion — Blood Bowl, Star Wars, Middle-earth, and Beyond

**Status:** Future work (non-authoritative until promoted to `specs/`)  
**Parent:** [UnifiedAppPlan.md](UnifiedAppPlan.md)  
**Related:** [StarCraftTMGLaunchPlan.md](StarCraftTMGLaunchPlan.md) · [MonetizationPlan.md](MonetizationPlan.md) · [CatalogKeyAudit.md](CatalogKeyAudit.md) · `specs/DataSchemaSpec.md`

---

## North star

Tabletome stays **one offline-first hobby OS** (Bench → Muster → Play). The Play pillar wins when a new player can run a **real game at the table** without hunting a PDF mid-turn.

That bar is **not the same** for every franchise. Some games are a guided-match clone away from shipping; others need a new play engine or should ship as **Rules-only** stubs until demand proves out.

This doc catalogs candidate franchises, groups them by **play engine archetype**, and defines the architecture work required before `gameSystemId` switch sprawl becomes unmaintainable.

---

## What “support” means (tiered)

| Tier | User promise | Tabletome surfaces |
|------|--------------|-------------------|
| **A — Guided play** | Full setup → battle tracker → victory screen; pass-the-phone workflow | Game Guide, Guided Match, Battle Tracker, match history |
| **B — Rules companion** | Getting started + offline reference + search; link official PDFs | Game Guide, Rules Reference, glossary |
| **C — Coming soon** | Visible on home row; sets expectations; captures interest | `availability: comingSoon` in `rules-v1.json`, no guided match |
| **D — Out of scope** | Different product (list builder only, VTT, campaign manager, CCG) | Link out or ignore |

**Ship criterion for Tier A:** same bar as Spearhead / SC TMG — two featured starter lists playable end-to-end on one phone.

**Monetization alignment:** per [MonetizationPlan.md](MonetizationPlan.md), **do not paywall by franchise**. Featured starters free; full roster catalog = Plus when Muster ships.

---

## Candidate franchises

### Summary matrix

| Franchise / game | Publisher | Tier target | Engine archetype | Fit vs today | Notes |
|------------------|-----------|-------------|------------------|--------------|-------|
| **Blood Bowl** | GW | A (v1: Tier B → A) | Grid sport / drive | **Low** — new UX | Half-based, grid adjacency, turnover cascade; not a wargame phase dock |
| **Middle-earth SBG** | GW | A | Hero-led skirmish | **Medium** | Might/Will/Fate, courage, hero vs warrior split; fixed warband lists |
| **Kill Team** | GW | A | Phased skirmish (40k-adjacent) | **High** | Closest to 40k CP engine; operatives, TP, firefight terrain |
| **Warcry** | GW | B → A | Alternating activation warband | **Medium** | SC-like activations; simpler than full 40k |
| **Warhammer Underworlds** | GW | B | Hex grid + deck | **Low** | Deck/hand state dominates; hybrid board game |
| **Star Wars: Legion** | AMG | A | Command-card activation | **Medium** | Orders, activation tokens, range bands, surge/defense/evade |
| **Star Wars: Shatterpoint** | AMG | A | Strike-team activation groups | **Medium–High** | Smaller squads; closer to SC TMG activation UX |
| **Star Wars: X-Wing / Armada** | AMG | B | Ship combat / mission | **Low** for guided | List + dial/maneuver tools; different table scale |
| **Marvel Crisis Protocol** | AMG | A | Alternating activation + power | **Medium** | Similar activation/pass patterns to SC |
| **Infinity** | Corvus Belli | B → A | Order pool / ARO | **Low–Medium** | Reactive play; state-heavy |
| **Malifaux** | Wyrd | B → A | Alternating crew activation | **Medium** | Small model count; fate deck |
| **Kings of War** | Mantic | B → A | I-GO mass battle | **Medium–High** | Simpler than AoS; regiments not individuals |
| **Warmachine** | Privateer | B | Squad + focus | **Medium** | CP + battlegroup; smaller community post-2024 |

**Priority recommendation (after SC TMG + 11e stabilize):**

1. **Kill Team** or **Shatterpoint** — highest reuse of existing guided-match shell  
2. **Legion** — strong brand, moderate engine work (command cards + activation bar)  
3. **Blood Bowl** — high demand, **requires dedicated grid sport engine** — plan as its own pillar UX, not Spearhead reskin  
4. **Middle-earth SBG** — GW synergy with Bench/Muster; hero mechanics need custom tracker cards  
5. **X-Wing / Armada** — Tier B rules companion unless user research demands ship-specific tools  

---

## Play engine archetypes

Today’s code implicitly assumes **wargame skirmish**. Four shipped/near-shipped systems map to three archetypes:

```
Archetype 1: I-GO phased rounds     → aos-spearhead, wh40k-10e-cp, wh40k-11e
Archetype 2: Alternating activation → sc-tmg
Archetype 3: (not yet built) Grid sport / drive   → blood-bowl
Archetype 4: (not yet built) Command-card pool    → sw-legion, sw-shatterpoint
```

### Archetype 1 — I-GO phased rounds (current default)

- Fixed battle rounds; active player runs **phase dock** (Hero → Move → Shoot → Charge → Fight → End).  
- VP scoring, deployment checklist, round checklist.  
- **Reuse:** `BattlePhaseTrackerView`, `PhaseChip`, `RoundChecklistCard`, `VictoryPointsCard`.

### Archetype 2 — Alternating activation

- No full “your turn / my turn”; **one unit at a time** until phase exhausted; pass claims initiative marker.  
- **Reuse:** SC TMG work — `ScActivationBar`, supply pool, reserves coach.  
- **Also fits:** Warcry, parts of MCP, simplified Legion scenarios.

### Archetype 3 — Grid sport / drive (Blood Bowl)

| Dimension | Wargame (today) | Blood Bowl |
|-----------|-----------------|------------|
| Time structure | Battle rounds | **Two halves**, turns per half |
| Turn unit | Player turn (all phases) | **Drive** — one team on offense until turnover |
| Space | Open table + coherency | **Grid squares**, tackle zones, adjacency |
| Scoring | VP objectives | **Touchdowns**, casualties, fame |
| Failure mode | Phase ends | **Turnover cascade** — immediate possession swap |
| List shape | Fixed box roster | **11–16 roster**, 11 on pitch, inducements, star players |

**Implication:** do not force Blood Bowl into `BattleTurnPhase`. Ship a **`BloodBowlDriveTracker`** (or generic `GridSportTracker`) with:

- Half / turn / drive clock  
- Drive phase steps (setup → move → block → blitz → handoff → foul → end drive)  
- Turnover reason picker + coaching (“you forgot to mark — turnover”)  
- Scoreboard: TD, CAS, rerolls remaining, inducements  
- Optional **grid notation helper** (square labels) — not a VTT  

Tier B v0: rules reference + getting started + link GW PDF. Tier A when drive tracker + one featured league roster (e.g. Humans vs Orcs starter) is playable.

### Archetype 4 — Command-card activation pool (Legion, Shatterpoint)

| Dimension | SC TMG | Legion |
|-----------|--------|--------|
| Activation | Unit activates once per phase | **Order token** spent per unit; some orders restrict actions |
| Resources | Minerals / vespene / supply | **Command cards** in hand, pip count |
| Combat | Surge / armour / evade | **Cover**, **surge**, **defense**, **critical** |
| List | Box-fixed | **Standard / Strike / Skirmish** — start with box-fixed like Spearhead |

**Reuse from SC:** activation bar, pass/initiative patterns, alternating flow.  
**New:** command card **hand summary** (names only — no card text), order token state per unit, range band glossary (not a range ruler).

Shatterpoint is **archetype 2 + objective tokens** with smaller squads — likely faster to ship than full Legion.

### Archetype 5 — Hero-led skirmish (Middle-earth SBG)

- Warband fixed list; **hero** vs **warrior** model split on tracker.  
- **Courage / Might / Will / Fate** — track hero resources, not army-wide CP.  
- Fight sequence differs (heroic combat vs group fight).  
- **Reuse:** unit focus sheet, army tracker cards; **new:** hero resource chips, courage break coaching.

Tier B acceptable for launch if Tier A slips — MESBG players often want warband quick reference at table.

---

## Architecture: stop switch sprawl before adding franchises

### Problem (today)

`BattleRules`, `ReleaseSurface`, `AppDependencies.catalogRepository`, `BattlePhaseTrackerViewModel`, and dozens of feature switches key off raw `gameSystemId` strings. Adding Blood Bowl as another `case` in ten files does not scale.

### Target shape

Introduce a **play engine id** separate from **game system id**:

```swift
/// Stable catalog + rules namespace (e.g. "blood-bowl-2020", "sw-legion").
struct GameSystemId: RawRepresentable, Hashable, Sendable { let rawValue: String }

/// Which guided-match runtime drives UI (may be shared across editions).
enum PlayEngineId: String, Sendable {
    case spearheadPhased      // aos-spearhead
    case wh40kPhased          // wh40k-10e-cp, wh40k-11e, kill-team (future)
    case alternatingActivation // sc-tmg, warcry (future)
    case gridSportDrive       // blood-bowl (future)
    case commandCardActivation // sw-legion (future)
    case heroSkirmish         // mesbg (future)
    case rulesOnly            // reference-only systems
}

struct GameSystemDescriptor: Sendable {
    let id: GameSystemId
    let displayName: String
    let publisher: GamePublisher
    let playEngine: PlayEngineId
    let availability: GameSystemAvailability
    let rulesSectionPrefix: String  // per DataSchemaSpec
    let catalogBundleName: String?  // nil = rules-only
}
```

**Registry:** single `GameSystemRegistry` in Domain (loaded from `rules-v1.json` metadata extension or sidecar `game-systems-v1.json`). Features ask the registry for behavior — not `switch gameSystemId`.

### Protocol boundaries

| Protocol | Responsibility |
|----------|----------------|
| `PlayCatalogRepository` | Armies / rosters / unit profiles (generalize `SpearheadCatalogRepository`) |
| `PlayEngineRules` | Round count, phases, initial phase, labels |
| `PlayEngineCoach` | Phase/drive/activation coaching copy (`PhaseContextCoach` generalization) |
| `MatchStateCodec` | Persist + sync snapshot per engine |
| `CombatRollEngine` | Optional; per-system dice resolution |

### Data layout (reference plane)

```
Resources/Rules/
├── rules-v1.json                    # GameSystem entries (all franchises)
├── aos-spearhead-catalog-v1.json
├── sc-tmg-catalog-v1.json
├── blood-bowl-catalog-v1.json       # future
├── sw-legion-catalog-v1.json        # future
├── mesbg-catalog-v1.json            # future
├── BloodBowl/
│   └── teams/human-team.json
├── Legion/
│   └── starters/rebel-strike-force.json
└── MiddleEarth/
    └── warbands/mordor-assault.json
```

Extend `specs/DataSchemaSpec.md` with **publisher** and **playEngine** fields when promoting.

### UI routing

```
GuidedMatchDestinationView
    → registry.playEngine(for: gameSystemId)
        → .spearheadPhased      → existing BattlePhaseTrackerView
        → .alternatingActivation → Sc-style tracker (shared shell)
        → .gridSportDrive       → BloodBowlDriveTrackerView (new)
        → .commandCardActivation → LegionTrackerView (new)
        → .rulesOnly            → RulesReferenceView only
```

Shared chrome stays in DesignSystem: `ArmyTrackerCard`, `MatchVictoryScreen`, setup checklists — engine-specific cards live in `DesignSystem/{Engine}/`.

---

## Content & licensing strategy

| Publisher | Policy sketch | Tabletome approach |
|-----------|---------------|-------------------|
| **Games Workshop** | Fan content / IP guidelines; no competitive points mirroring | Our words + glossary; link official PDFs; warscroll **summaries** not verbatim stat blocks where restricted |
| **Atomic Mass (Star Wars)** | Disney IP; stricter | Same as SC TMG — summaries, link AMG app/PDF; **no card text** in v1 |
| **Mantic / Wyrd / CB** | Varies | Rules companion first; negotiate or user-entered notes if needed |

**Never ship:** verbatim copyrighted card text, points/meta spreadsheets marketed as competitive authority, or assets scraped from official apps.

**Bench / Muster cross-link:** use `CatalogUnitKey` + `PlayUnitRef` from [CatalogKeyAudit.md](CatalogKeyAudit.md). Franchise slug in catalog key:

```text
blood-bowl:human:thrower
legion:rebel:luke-skywalker
mesbg:mordor:orc-tracker
```

---

## `ReleaseSurface` expansion

```swift
// Existing
static func showsGuidedMatch(for gameSystemId: String) -> Bool

// Proposed
static func playTier(for gameSystemId: String) -> PlaySupportTier  // guided | rulesOnly | hidden
static func showsGuidedMatch(for engine: PlayEngineId) -> Bool

// Home row grouping (optional)
static var homeRowSections: [HomeGameSection]  // Warhammer | Star Wars | Other
```

Gate **readiness**, not **franchise**. A shipped Blood Bowl guided mode is free for featured teams; full team catalog = Plus.

---

## Phased roadmap

### Phase M0 — Engine registry refactor (prerequisite) — **see dedicated plan**

**Do not add franchises until this completes.** Full diagnosis, target types, and phased migration (P1–P7): [PlayEngineArchitectureRefactor.md](PlayEngineArchitectureRefactor.md).

Summary exit criteria:

- [ ] `GameSystemRegistry` + manifest JSON — metadata, capabilities, copy, featured armies  
- [ ] Single `PlayCatalogRepository` — no per-system repos in `AppDependencies`  
- [ ] `PlayEngine` protocol replaces `BattleRules` god switch  
- [ ] UI reads `PlayCapabilities`, not `BattleRules.isSpearhead` / raw id switches  
- [ ] Battle tracker split by `PlayEngineId` (phased vs alternating activation shells)  

**Exit:** adding a 5th system = manifest row + catalog JSON (+ engine view only if new archetype).

### Phase M1 — Near-fit skirmish (Kill Team *or* Shatterpoint)

Pick **one** to validate archetype reuse:

| If Kill Team | If Shatterpoint |
|--------------|-----------------|
| Extend `wh40kPhased` engine | Extend `alternatingActivation` engine |
| 4-round firefight, TP, operatives | Strike teams, activation groups, struggle cards |
| Reuse 40k deployment checklist patterns | Reuse SC activation bar |

- [ ] `gameSystemId` + catalog JSON + featured armies  
- [ ] Guided match + battle tracker  
- [ ] `comingSoon` → `available` when end-to-end playable  

### Phase M2 — Star Wars: Legion (command-card engine)

- [ ] `PlayEngineId.commandCardActivation`  
- [ ] Legion tracker: activation bar + order tokens + pip reminder  
- [ ] Box-fixed Rebel / Empire starters  
- [ ] Tier B glossary for range bands, cover, surge  

See also [StarCraftTMGLaunchPlan.md](StarCraftTMGLaunchPlan.md) for activation UX patterns to reuse.

### Phase M3 — Blood Bowl (grid sport engine)

- [ ] `PlayEngineId.gridSportDrive`  
- [ ] `BloodBowlDriveTrackerView` — half/turn/drive, turnover coach  
- [ ] Tier B rules reference first (can ship independently)  
- [ ] Featured starter: Humans vs Orcs (or current GW starter box)  
- [ ] **No** full roster builder in Play — link Team Builder tools  

### Phase M4 — Middle-earth SBG (hero skirmish)

- [ ] `PlayEngineId.heroSkirmish`  
- [ ] Hero resource tracking on unit focus  
- [ ] Warband catalog from free GW downloads  
- [ ] Courage / fight sequence coaching  

### Phase M5 — Rules-only expansions

Add Tier B entries (home visible, `comingSoon` or rules-only) for demand signals:

- X-Wing / Armada  
- Infinity, Malifaux  
- Underworlds (if deck tracker scope is rejected, stay Tier B)  

Collect analytics / feedback before committing engine work.

---

## Home row & information architecture

Today: flat list of game systems filtered by `ReleaseSurface`.

**Future (optional):** grouped sections to avoid a 12-row scroll:

```
Play
├── Warhammer
│   ├── Age of Sigmar: Spearhead
│   ├── Warhammer 40,000
│   └── Kill Team (future)
├── Star Wars
│   ├── Legion
│   └── Shatterpoint
├── Other
│   ├── Blood Bowl
│   └── Middle-earth Strategy Battle Game
└── StarCraft: TMG
```

Onboarding: “What do you play?” multi-select → pin favorites to top. Persist in UserDefaults / SwiftData.

---

## Risks

| Risk | Mitigation |
|------|------------|
| **Switch sprawl** | Phase M0 registry before any new franchise |
| **Blood Bowl forced into wargame UI** | Dedicated grid sport engine; explicit “not a reskin” in spec |
| **Disney / GW IP** | Summaries + links; legal review before card text |
| **Scope explosion** | One new **engine** per year max; multiple **systems** can share an engine |
| **Muster catalog explosion** | Franchise slug in `CatalogUnitKey`; import pipelines per publisher |
| **Combat resolver lag** | Guided play ships without resolver; engine-specific resolver is Phase 2 per system |

---

## Open questions (lock before promote to `specs/`)

1. **Product name:** stay “Tabletome” for multi-IP, or sub-brand per pillar (“Tabletome Play”)?
2. **Kill Team vs Shatterpoint first** after M0 — which community overlap is stronger for beta?
3. **Blood Bowl:** drive tracker only, or invest in square grid UI (higher build cost)?
4. **Home grouping:** flat list vs publisher sections — user test on 6+ systems.
5. **Cross-franchise match history:** single list with filters, or per-franchise tabs?

---

## Promotion path

When an engine + first franchise lock behavior:

1. `FutureIdeas/MultiFranchiseExpansionPlan.md` → `specs/MultiFranchisePlaySpec.md`  
2. Per-franchise launch plans (e.g. `specs/BloodBowlPlaySpec.md`) split from this doc  
3. Update `specs/DataSchemaSpec.md` with `playEngine`, `publisher`, prefix tables  
4. Verification blocks per shipped franchise  

---

## Related docs to split out when work starts

| Franchise | Future dedicated plan |
|-----------|----------------------|
| Blood Bowl | `FutureIdeas/BloodBowlLaunchPlan.md` |
| Star Wars Legion | `FutureIdeas/StarWarsLegionLaunchPlan.md` |
| Middle-earth SBG | `FutureIdeas/MiddleEarthSBGLaunchPlan.md` |
| Kill Team | Extend [wh40k-11e launch plan](../docs/game-modes/wh40k-11e/launch-plan.md) or separate KT doc |
