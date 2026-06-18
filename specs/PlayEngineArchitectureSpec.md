# Play Engine Architecture Spec

**Status:** Authoritative — Phase P1–P3 implemented (2026-06-17)  
**Parent:** [UnifiedAppPlan.md](../FutureIdeas/UnifiedAppPlan.md) · [MultiFranchiseExpansionPlan.md](../FutureIdeas/MultiFranchiseExpansionPlan.md)  
**Brainstorm archive:** [PlayEngineArchitectureRefactor.md](../FutureIdeas/PlayEngineArchitectureRefactor.md)

---

## Problem statement

Adding a fifth game system today requires editing **35+ Swift files** with copy-pasted `switch gameSystemId` blocks. Four systems already exceed maintainability; Blood Bowl or Legion would make the codebase unmigratable.

The app does not have a scalable **play engine** abstraction — it has a Spearhead-shaped core with conditional branches for 40k and SC TMG bolted on.

---

## Symptom inventory (2026-06-17)

| Anti-pattern | Where | Scale |
|--------------|-------|-------|
| Raw `gameSystemId: String` threading | Domain + Features + DesignSystem | **~100 files**, 500+ references |
| Identical 4-case `switch gameSystemId` | `GameSystemRulesLabels`, `AppDependencies`, `BattleRules`, views | **35 files** |
| Per-system repository properties | `AppDependencies` | 4 repos + 2 duplicate switches |
| God-object facade | `BattleRules` → delegates to 4 enums | 24 methods, all switch on id |
| Boolean capability probes | `BattleRules.isSpearhead/isWh40k/isStarCraft/isCombatPatrol` | **40+ call sites** |
| ViewModel extensions per system | `+CombatPatrol`, `+GuideFlow`, `+MatchLog` | grows linearly per system |
| Per-system featured-army types | `SpearheadFeaturedArmies`, `FortyKFeaturedArmies`, … + switch in `GuidedMatchFeaturedArmies` | 4 types + 1 switch |
| Spearhead naming on non-Spearhead data | `SpearheadCatalog`, `SpearheadArmy`, `SpearheadCatalogRepository` | used for 40k, SC, CP |
| Hardcoded release gates | `ReleaseSurface` | every new id = 3 edits |
| Labels not in data | `GameSystemRulesLabels` | 10 switch methods, ~190 lines |

**Adding `blood-bowl` today would touch:** `AppDependencies`, `ReleaseSurface`, `BattleRules`, `GameSystemRulesLabels`, `GuidedMatchFeaturedArmies`, `BattlePhaseTrackerViewModel`, `BattleTrackerSections`, `VictoryPointsCard`, `BattleFlowGuide`, `PhaseContextCoach`, `AppSearchEngine`, `GameSystemDetailView`, `ArmySelectionView`, new repository class, new `+BloodBowl` ViewModel extension, new DesignSystem cards, tests — minimum **~25 files**, most with new switch arms.

That is not sustainable.

---

## Root cause

Three concepts are conflated:

```
gameSystemId     — catalog + rules namespace ("wh40k-11e", "sc-tmg")
playEngine       — runtime turn/phase model (phased rounds vs alternating activation)
gameSystem meta  — display copy, publisher, feature flags
```

Code switches on **gameSystemId** when it should switch on **playEngine** or read **metadata**.

---

## Target architecture

### Conceptual model

```
┌─────────────────────────────────────────────────────────────┐
│  rules-v1.json + game-systems-manifest.json                 │
│  (metadata: id, name, playEngine, catalogBundle, caps)      │
└──────────────────────────┬──────────────────────────────────┘
                           │ load at launch
                           ▼
┌─────────────────────────────────────────────────────────────┐
│  GameSystemRegistry (Domain, Sendable)                      │
│  descriptor(for: GameSystemId) → GameSystemDescriptor       │
│  engine(for: GameSystemId) → any PlayEngine                 │
└──────────────────────────┬──────────────────────────────────┘
                           │
         ┌─────────────────┼─────────────────┐
         ▼                 ▼                 ▼
  PlayCatalogRepo    PlayEngine         PlayCapabilities
  (one protocol)     (behavior)         (feature flags)
         │                 │                 │
         └─────────────────┴─────────────────┘
                           │
                           ▼
              Features / DesignSystem
              (switch on engine or read caps — never on raw id)
```

### Core types (Domain)

```swift
public struct GameSystemId: RawRepresentable, Hashable, Codable, Sendable {
    public let rawValue: String
}

public enum PlayEngineId: String, Codable, Sendable {
    case phasedRound       // Spearhead, 40k, Kill Team (future)
    case alternatingActivation  // SC TMG, Warcry (future)
    case gridSportDrive    // Blood Bowl (future)
    case commandCardPool   // Legion (future)
    case heroSkirmish      // MESBG (future)
    case rulesOnly
}

public struct PlayCapabilities: Sendable, Equatable {
    public let showsGuidedMatch: Bool
    public let showsCombatResolver: Bool
    public let showsVictoryPoints: Bool
    public let showsDeploymentChecklist: Bool
    public let showsRoundChecklist: Bool
    public let showsBattleTacticDecks: Bool
    public let showsActivationBar: Bool
    public let showsSupplyPool: Bool
    public let scoringRuleSectionId: String?
    // … extend as needed; replaces isSpearhead / isStarCraft checks
}

public struct GameSystemDescriptor: Sendable, Equatable {
    public let id: GameSystemId
    public let displayName: String
    public let shortLabel: String           // "AoS", "40k", "SC"
    public let publisher: String            // "gw", "amg", …
    public let playEngine: PlayEngineId
    public let availability: GameSystemAvailability
    public let catalogBundleName: String?   // nil = rules-only
    public let capabilities: PlayCapabilities
    public let copy: GameSystemCopy         // labels presently in GameSystemRulesLabels
    public let featuredArmies: FeaturedArmiesConfig?
}

public protocol PlayEngine: Sendable {
    var id: PlayEngineId { get }
    func battleRoundCount(for descriptor: GameSystemDescriptor) -> Int
    func mainPhases(for descriptor: GameSystemDescriptor) -> [BattleTurnPhase]
    func initialPhase(for descriptor: GameSystemDescriptor) -> BattleTurnPhase
    func roundLabel(round: Int, descriptor: GameSystemDescriptor) -> String
    func clampBattleRound(_ round: Int, descriptor: GameSystemDescriptor) -> Int
}

public protocol PlayCatalogRepository: Sendable {
    func loadCatalog(for descriptor: GameSystemDescriptor) async throws -> PlayCatalog
}
```

**Key rule:** Features receive `GameSystemDescriptor` (or resolve once at VM init). They call `registry.engine(for:)` and read `descriptor.capabilities` — **never** `switch gameSystemId`.

### Data manifest

Extend bundled JSON (prefer sidecar to avoid bloating `rules-v1.json`):

```json
// Resources/Rules/game-systems-manifest-v1.json
{
  "schemaVersion": 1,
  "systems": [
    {
      "id": "aos-spearhead",
      "playEngine": "phasedRound",
      "publisher": "gw",
      "catalogBundleName": "spearhead-catalog-v1",
      "capabilities": {
        "showsGuidedMatch": true,
        "showsCombatResolver": true,
        "showsVictoryPoints": true,
        "showsBattleTacticDecks": true,
        "scoringRuleSectionId": "spearhead-scoring"
      },
      "copy": {
        "shortLabel": "AoS",
        "rulesTitle": "AoS Rules",
        "glossaryTitle": "AoS Glossary",
        "searchPlaceholder": "Search AoS rules"
      },
      "featuredArmies": {
        "armyIds": ["vigilant-brotherhood", "gnawfeast-clawpack"],
        "starterMatchupTitle": "…",
        "defaultPlayerOneArmyId": "vigilant-brotherhood",
        "defaultPlayerTwoArmyId": "gnawfeast-clawpack"
      }
    }
  ]
}
```

`GameSystem` in `rules-v1.json` stays the rules/guide content source. Manifest holds **runtime wiring** only. `GameSystemRegistry` merges both at load time.

### DI simplification

**Before** (`AppDependencies`):

```swift
let spearheadCatalogRepository: any SpearheadCatalogRepository
let wh40kCatalogRepository: any SpearheadCatalogRepository
let combatPatrolCatalogRepository: any SpearheadCatalogRepository
let scTmgCatalogRepository: any SpearheadCatalogRepository

func catalogRepository(for gameSystemId: String) -> any SpearheadCatalogRepository {
    switch gameSystemId { … }  // duplicated twice
}
```

**After:**

```swift
let gameSystemRegistry: GameSystemRegistry
let playCatalogRepository: any PlayCatalogRepository  // BundledPlayCatalogRepository

func catalog(for id: GameSystemId) async throws -> PlayCatalog {
    let descriptor = try gameSystemRegistry.descriptor(for: id)
    return try await playCatalogRepository.loadCatalog(for: descriptor)
}
```

Adding Blood Bowl = **one manifest row** + catalog JSON. No new Swift repository class, no `AppDependencies` edit.

### Play engine implementations

| `PlayEngineId` | Type | Replaces |
|----------------|------|----------|
| `phasedRound` | `PhasedRoundPlayEngine` | `SpearheadBattleRules`, `Wh40kBattleRules`, `CombatPatrolBattleRules` (parameterized or sub-config) |
| `alternatingActivation` | `AlternatingActivationPlayEngine` | `ScTmgBattleRules` |
| `gridSportDrive` | `GridSportPlayEngine` | (new) |
| `commandCardPool` | `CommandCardPlayEngine` | (new) |

`BattleRules` enum **deleted** after migration. Call sites use `registry.engine(for: id)` or injected `PlayEngine`.

### UI composition

**Before:** `BattlePhaseTrackerView` + `BattlePhaseTrackerViewModel` with 40 `gameSystemId` branches and `+CombatPatrol` extensions.

**After:**

```
BattlePhaseTrackerShell (shared chrome: army cards, nav, sync, history)
    └── engineContent(for: PlayEngineId)
            ├── PhasedRoundTrackerView + PhasedRoundTrackerViewModel
            ├── AlternatingActivationTrackerView + …ViewModel
            └── (future engines)
```

Shared subviews (`ArmyTrackerCard`, `MatchVictoryScreen`) take `PlayCapabilities`, not `gameSystemId`.

System-specific cards (`CombatPatrolTableStateCard`, `ScActivationBar`) render when `capabilities.showsSupplyPool` etc. — or live inside engine-specific tracker views only.

### Rename pass (non-blocking, can trail)

| Current | Target |
|---------|--------|
| `SpearheadCatalog` | `PlayCatalog` (+ typealias during migration) |
| `SpearheadArmy` | `PlayRoster` or `PlayArmy` |
| `SpearheadCatalogRepository` | `PlayCatalogRepository` |
| `SpearheadUnit` | `PlayUnit` |

Rename is cosmetic but reduces cognitive load when onboarding Legion/Blood Bowl contributors.

---

## Migration phases (strangler fig)

Each phase ships green CI. No big-bang rewrite.

### Phase P0 — Inventory lock ✅

- [x] Document anti-patterns (this doc)
- [ ] Grep baseline: `rg 'switch gameSystemId|BattleRules\.is' --count` checked into spec Verification

### Phase P1 — Registry + manifest (behavior unchanged)

**Goal:** single source of truth for system metadata; delete duplicate label switches.

- [ ] Add `game-systems-manifest-v1.json` with all 4 current systems
- [ ] `GameSystemRegistry` in Domain — loads manifest + merges `rules-v1.json` availability
- [ ] `GameSystemDescriptor`, `PlayEngineId`, `PlayCapabilities`, `GameSystemCopy`
- [ ] `BundledGameSystemRegistry` in Data
- [ ] Wire into `AppDependencies`; inject registry
- [ ] Migrate `GameSystemRulesLabels` → read from `descriptor.copy` (delete file)
- [ ] Migrate `GuidedMatchFeaturedArmies.forGameSystem` → `descriptor.featuredArmies`
- [ ] Migrate `ReleaseSurface.isGameSystemVisible` / `showsGuidedMatch` → manifest capabilities (+ dev override flags)
- [ ] Unit tests: registry loads 4 systems; capabilities match today's `ReleaseSurface`

**Exit:** zero production use of `GameSystemRulesLabels`; featured armies data-driven.

**Touch ~8 files, add ~6.**

### Phase P2 — Unified catalog repository

**Goal:** one repository; no per-system repo properties in DI.

- [ ] `PlayCatalogRepository` protocol (rename from `SpearheadCatalogRepository` via typealias)
- [ ] `BundledPlayCatalogRepository` — resolves bundle path from `descriptor.catalogBundleName`
- [ ] Delete `BundledWh40kCatalogRepository`, `BundledScTmgCatalogRepository`, `BundledCombatPatrolCatalogRepository` (thin wrappers today)
- [ ] `AppDependencies`: single `playCatalogRepository`
- [ ] Existing catalog JSON paths unchanged

**Exit:** `AppDependencies` has no `switch gameSystemId` for catalogs.

### Phase P3 — PlayEngine protocol

**Goal:** delete `BattleRules` god switch.

- [ ] `PlayEngine` protocol + `PhasedRoundPlayEngine`, `AlternatingActivationPlayEngine`
- [ ] `GameSystemRegistry.engine(for:)` returns configured engine
- [ ] Migrate `BattleFlowGuide`, `PhaseContextCoach`, `BattleTrackerStore`, `MatchSetupCompletionEvaluator`
- [ ] Delete `BattleRules`; update tests
- [ ] `CombatRollEngineRouter` keys off `descriptor.capabilities.showsCombatResolver` + engine config, not `isWh40k`

**Exit:** no `BattleRules.is*` in Domain use cases.

### Phase P4 — Capabilities in UI

**Goal:** DesignSystem + Features stop probing game identity.

- [ ] Replace `BattleRules.isSpearhead(gameSystemId)` with `capabilities.showsBattleTacticDecks` (etc.)
- [ ] Priority files: `BattleTrackerSections`, `VictoryPointsCard`, `BattleTrackerSectionTab`, `ArmyTrackerCard`, `BattlePhaseTrackerView`, `UnitFocusSheet`, `GameSystemDetailView`
- [ ] Pass `GameSystemDescriptor` into tracker shell instead of raw `String`

**Exit:** `rg 'BattleRules\.is'` returns 0 in Features/ and DesignSystem/.

### Phase P5 — Split battle tracker by engine

**Goal:** ViewModel/view stop accumulating `+System` extensions.

- [ ] Extract `PhasedRoundTrackerViewModel` from `BattlePhaseTrackerViewModel` (Spearhead + 40k + CP logic)
- [ ] Extract `AlternatingActivationTrackerViewModel` (SC TMG logic from `+GuideFlow`, supply, pass)
- [ ] `BattlePhaseTrackerShell` selects VM by `descriptor.playEngine`
- [ ] Move `+CombatPatrol` logic into phased engine config (CP is phasedRound + capability flags)
- [ ] Delete monolithic `BattlePhaseTrackerViewModel` when parity tests pass

**Exit:** adding a new **phasedRound** system (Kill Team) = manifest + catalog + optional engine config — no new ViewModel extension file.

### Phase P6 — Search + match log generalization

- [ ] `AppSearchEngine` — index by registry, not hardcoded id list
- [ ] `MatchLogRecorder` / export — engine-aware formatters via registry
- [ ] `MatchSyncSnapshot` — versioned per engine (already partially there)

### Phase P7 — Promote spec

- [ ] `specs/PlayEngineArchitectureSpec.md` with Verification block
- [ ] Update `specs/DataSchemaSpec.md` (manifest schema)
- [ ] Update `specs/ArchitectureSpec.md` (DI shape)

---

## What NOT to do

| Temptation | Why avoid |
|------------|-----------|
| Add `case "blood-bowl"` to existing switches | Defeats the refactor |
| One mega `PlayEngine` with 50 optional properties | Becomes second god object |
| Generic `@ViewBuilder` reflection / type erasure everywhere | SwiftUI performance + debug pain |
| Block Play features until rename completes | Typealiases let you migrate incrementally |
| Put engine logic in Features | Stays in Domain; Features compose |

---

## Success metrics

| Metric | Today | After P7 |
|--------|-------|----------|
| Files with `switch gameSystemId` | ~35 | **0** (registry + engine only) |
| `AppDependencies` catalog repos | 4 | **1** |
| New system Swift touch count | ~25 files | **manifest + catalog JSON + engine view (if new engine)** |
| `BattleRules.is*` call sites | ~40 | **0** |
| Time to add Kill Team (phased reuse) | ~2 weeks guess | **~2–3 days** content + manifest |

---

## Sequencing vs Unified App Plan

Insert **before Phase 7 (Play pillar consolidation)** in [UnifiedAppPlan.md](UnifiedAppPlan.md):

| Unified phase | Play engine phase |
|---------------|-------------------|
| Phase 2 Domain kernel | P1 registry types align with `GameSystemId` / `CatalogUnitKey` |
| Phase 7 Play consolidation | **P1–P5 complete first** — consolidate into `Features/Play/` with engine routing |
| Multi-franchise expansion | P7 complete — then per-franchise launch plans |

**Recommendation:** run **P1–P3** alongside current 11e / SC TMG ship work. It pays down debt before Kill Team or Blood Bowl. **P5** (tracker split) can trail slightly if SC TMG is stable.

---

## Open decisions

1. **Manifest location:** sidecar JSON vs fields on `GameSystem` in `rules-v1.json` — sidecar keeps rules content separate from wiring.
2. **40k 10e CP vs 11e:** one `phasedRound` engine with per-system `EngineConfig` JSON, or two engine instances?
3. **Tracker split (P5):** one PR or phased extraction (SC first, then CP, then delete monolith)?
4. **Generated registry:** hand-maintained manifest vs codegen from JSON at build time — hand-maintained fine at &lt;20 systems.

---

## Verification

| Field | Value |
|-------|-------|
| Target release | Pre–Kill Team / Blood Bowl |
| Last verified | 2026-06-18 |
| Code paths | `Domain/Registry/`, `Data/JSON/BundledPlayCatalogRepository.swift`, `Data/Registry/GameSystemsManifestLoader.swift`, `App/AppDependencies.swift` |
| Tests | `GameSystemRegistryTests` (manifest validation), full `TabletomeTests` green |
| Completed | P1–P3 registry/engine; P4 partial (Domain migrated, VM context, VP scoring, manifest validation, key DesignSystem) |
| Remaining | P4 Features view migration; P5 tracker split by engine |
