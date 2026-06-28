# Tabletome — Architecture Refactor Master Plan

**Status:** Proposal / non-authoritative (lives in `FutureIdeas/` until promoted to `specs/`).
**Author intent:** A whole-app, senior-level refactor blueprint to make Tabletome scale cleanly as new GW editions, box sets, and franchises ship — without `switch gameSystemId` sprawl, god objects, or per-system view explosions.
**Scope relationship:** This **absorbs and extends** the in-flight [PlayEngineArchitectureSpec.md](../specs/PlayEngineArchitectureSpec.md) (P1–P3 landed, P4–P5 remain) and the [MultiFranchiseExpansionPlan.md](MultiFranchiseExpansionPlan.md). Where they overlap, this doc is the superset; the play-engine spec stays the authoritative reference for the registry/engine internals.

> **How to read this:** Sections 1–3 are diagnosis and target architecture (read once). Section 4 is the **component teardown** — the "what's wrong / what it should be" per subsystem. Section 5 is the **phased roadmap** — the order of operations with exit gates. Section 6 is the **acid test**: step-by-step cookbooks for adding a new edition / box set / franchise, which is the real measure of whether the refactor worked. Sections 7–9 are cross-cutting concerns, risks, and the definition of done.

---

## 1. Current-state assessment (measured, 2026-06)

This is not a greenfield app — it's a mature, well-layered codebase (4 game systems, ~250 Swift files, ~85 design-system components, ~72 unit tests, a clean Domain/Data/Features split, and an existing `GameSystemRegistry`). The architecture is **good in the large and leaky in the small**. The refactor is about finishing migrations already started and hardening the seams that linear-growth pressure will tear open.

### 1.1 What's already right (do not regress)

| Strength | Evidence |
|----------|----------|
| Layered modules with enforced dependency direction | `TabletomeDomain` (Foundation-only) ← `TabletomeData` ← app target; `TabletomeHobbyData` isolates SwiftData |
| A registry exists and is the seed of the solution | `Domain/Registry/` — `GameSystemRegistry`, `GameSystemDescriptor`, `PlayCapabilities`, `PlayEngineConfig`, `GameSystemCopy` |
| Data-driven copy & featured armies | `GameSystemRulesLabels` is now a thin facade over `registry.copy(for:)`; `FeaturedArmiesConfig` is data |
| Protocol-based data access | `PlayCatalogRepository`, `MatchHistoryRepository`, `RulesRepository`, `SpearheadCatalogRepository` |
| Strong unit-test culture | 72 test files including registry, engine, and catalog-completeness audits |
| Swift 6 / strict concurrency already targeted | `SWIFT_VERSION: 6.0`; `TabletomeHobbyData` runs `SWIFT_STRICT_CONCURRENCY: complete` |

### 1.2 The debt that blocks scaling (measured)

| Symptom | Metric (today) | Why it blocks new editions/box sets |
|---------|----------------|-------------------------------------|
| `switch gameSystemId` blocks | **20** across 11 files | Each new edition adds an arm in N files |
| Files referencing raw `gameSystemId` | **172 files** | Identity threaded as a `String` instead of resolved metadata |
| `BattleRules` / `is*` probe references | **~234** | God facade + boolean identity probes (`isStarCraft`, `isSpearhead`) survive P3 |
| Raw id string-literal comparisons (`== "wh40k-11e"`) | **46** | Compiler can't catch a typo or a missing case |
| `PlayCapabilities` boolean flags | **15**, several system-specific (`usesWh40k10eCombatRollEngine`, `showsScTmgDeploymentChecklist`, `showsCombatPatrolMode`) | The bag grows by 2–4 booleans per system → second god object |
| System-specific DesignSystem cards | **~30** flat files (`FortyKStartHereCard`, `ScActivationBar`, `CombatPatrolTableStateCard`, `Wh40kDeploymentChecklistCard`, …) | UI surface grows linearly per system; no engine grouping |
| God views / view models | `GuidedMatchView.swift` **1273 LOC**, `BattlePhaseTrackerView(+Model)` ~**15 partials**, `AppSearchEngine` **816 LOC** | New system behavior accretes as `+System` extensions and inline branches |
| Surviving god types | `BattleRules.swift`, `SpearheadBattleRules`, `CombatPatrolBattleRules`, `ScTmgBattleRules` still present | P3 "delete `BattleRules`" not finished; engines still fall back to `SpearheadBattleRules` |
| Spearhead naming on generic data | `SpearheadCatalog`, `SpearheadArmy`, `SpearheadCatalogRepository`, `BundledSpearheadCatalogRepository` used for 40k/SC/CP | Cognitive tax; implies Spearhead-shaped assumptions |
| Content pipeline is ad-hoc | `Scripts/*.py` importers + hand-edited JSON in `Resources/Catalogs` and `Resources/Rules`; no schema-versioned validation gate in CI | A new box set = manual JSON authoring with no machine-checked contract |

**Root cause (unchanged from the team's own diagnosis, and correct):** three concepts are conflated — `gameSystemId` (catalog/rules namespace), `playEngine` (runtime turn model), and `gameSystem metadata` (copy/flags). Code branches on **identity** where it should branch on **engine** or read **capabilities/data**.

**This plan adds a fourth conflation the existing spec under-weights:** **content** (catalogs, rules, box-set definitions) is conflated with **code**. Adding a box set should be a *data* operation gated by a *schema*, never a Swift edit. That is the single most important property for "new GW editions / box sets come out."

---

## 2. Architectural north star

### 2.1 Principles

1. **Identity is resolved once, at the edge.** A `GameSystemId` enters a feature exactly once (navigation/DI), is immediately resolved to a `GameSystemDescriptor` + `any PlayEngine`, and the raw id is never branched on again downstream.
2. **Branch on engine or capability, never on identity.** `switch playEngine` (closed, small set) or `if capabilities.showsX` — never `switch gameSystemId` (open, unbounded set).
3. **Capabilities are typed and grouped, not a flat boolean bag.** Feature-area structs, not 30 loose `Bool`s.
4. **Content is data, gated by a schema.** New editions/box sets = JSON authored against a versioned schema + a CI validation gate. Zero Swift changes for a same-engine release.
5. **Views compose; they don't conditionally morph.** A shell + engine-specific content views, not one mega-view with 40 branches and `+System` extensions.
6. **The Domain stays pure and Sendable.** No SwiftUI/UIKit in `Domain`; everything `Sendable`; Swift 6 strict concurrency everywhere by the end.
7. **Every migration ships green CI (strangler fig).** No big-bang rewrite; old and new coexist behind typealiases/adapters until call sites are migrated, then the old type is deleted in one final commit.

### 2.2 Target layering (refined)

```
┌──────────────────────────────────────────────────────────────────────┐
│ Resources/  rules-v1.json · game-systems-manifest-v1.json ·            │
│             <system>-catalog-v1.json · <system>-boxsets-v1.json        │
│             (schema-versioned content, CI-validated)                   │
└───────────────────────────────┬──────────────────────────────────────┘
                                │  load + validate at launch
                                ▼
┌──────────────────────────────────────────────────────────────────────┐
│ TabletomeDomain (Foundation-only, Sendable)                            │
│  Registry:  GameSystemRegistry → GameSystemDescriptor                  │
│  Engine:    any PlayEngine (phasedRound | alternatingActivation | …)   │
│  Caps:      PlayCapabilities (grouped: setup/round/combat/scoring/ui)  │
│  Models:    PlayCatalog, PlayArmy, PlayUnit, BattleTracker, MatchLog   │
│  UseCases:  registry-driven (search, coaching, scoring, archive)       │
└───────────────────────────────┬──────────────────────────────────────┘
        ┌───────────────────────┼───────────────────────┐
        ▼                       ▼                       ▼
┌────────────────┐   ┌────────────────────┐   ┌────────────────────────┐
│ TabletomeData  │   │ TabletomeHobbyData │   │ (future) Engine packs  │
│ catalog/rules/ │   │ SwiftData: Bench/  │   │ as SPM modules if app  │
│ match repos    │   │ Muster persistence │   │ target grows too large │
└───────┬────────┘   └─────────┬──────────┘   └───────────┬────────────┘
        └──────────────────────┴───────────────────────────┘
                                ▼
┌──────────────────────────────────────────────────────────────────────┐
│ App target:  Features/ + DesignSystem/ + Support/                      │
│  Features/Play/ ← engine-routed shell + per-engine content views       │
│  DesignSystem/{Shared, PhasedRound, AltActivation, …}/ grouped cards   │
│  ReleaseSurface = capability/availability gate (data-driven)           │
└──────────────────────────────────────────────────────────────────────┘
```

---

## 3. Component teardown

Twelve components. Each: **current state → problem → target → concrete work**. The phased roadmap (§5) sequences these; this section is the reference for *what each one should become*.

### Component A — Game System Registry & Descriptor

- **Current:** `GameSystemRegistry` built from `GameSystemId.allCases.map(\.bundledDescriptor)`; descriptors are hand-coded Swift in `GameSystemId+Bundled.swift` (one giant `switch self`).
- **Problem:** Descriptors are *code*, not *data*. Adding a system edits a Swift `switch`. The registry is `static let .bundled` — a hidden global, instantiated in `BattleRules`, `GameSystemRulesLabels`, etc. (testability + multiple-source-of-truth risk).
- **Target:**
  - Descriptors load from `game-systems-manifest-v1.json` (sidecar), merged with `rules-v1.json` availability, via `GameSystemsManifestLoader` in `TabletomeData`. `GameSystemId+Bundled.swift` becomes a *fallback*/seed for tests only, or is deleted once the manifest is authoritative.
  - `GameSystemRegistry` is injected (it already is in `AppDependencies`) — remove every `GameSystemRegistry.bundled` static reference inside Domain types (`BattleRules`, `GameSystemRulesLabels`) so there is one instance per process, owned by `AppDependencies`.
  - `GameSystemId` stays a `CaseIterable` enum **only while** the set is bundled-and-known; the manifest approach is compatible because ids remain a closed set per release. (Do **not** prematurely convert to an open `RawRepresentable struct` — keep compile-time exhaustiveness until a true plugin/remote-content story exists. Revisit in Phase 9.)
- **Work:** manifest JSON + loader + schema; delete static registry references; registry validation test (every manifest id resolves a catalog bundle, engine, copy).

### Component B — Capabilities (de-bag the boolean soup)

- **Current:** `PlayCapabilities` = 15 flat `Bool`s, several system-named: `usesWh40k10eCombatRollEngine`, `usesWh40k11eCombatRollEngine`, `showsScTmgDeploymentChecklist`, `showsWh40kDeploymentChecklist`, `showsCombatPatrolMode`, `showsSupplyPool`, `showsActivationBar`.
- **Problem:** Every new system adds 2–4 booleans → a second god object. System-named flags (`usesWh40k11e…`) re-introduce identity branching through the back door.
- **Target — grouped, intent-named capability structs:**

  ```swift
  public struct PlayCapabilities: Sendable, Equatable {
      public let setup: SetupCapabilities        // deployment checklist style, what-you-need cards
      public let round: RoundCapabilities        // round checklist, battle-tactic decks, activation bar, supply pool
      public let combat: CombatCapabilities      // resolver presence + which roll engine (by enum, not bool)
      public let scoring: ScoringCapabilities     // VP scoring model + scoring rule section id
      public let surface: SurfaceCapabilities    // home row, new-edition badge, full-surface gate
  }

  public enum CombatRollEngineKind: String, Sendable {  // replaces 3 uses* bools
      case none, classicWargame, wh40k10eCombatPatrol, wh40k11e
  }
  public enum DeploymentChecklistStyle: String, Sendable { // replaces 3 shows*DeploymentChecklist bools
      case none, spearhead, wh40k, scTmg
  }
  ```

  Deployment-checklist *style* and combat-engine *kind* become **enums keyed off engine + system config**, so a new system selects an existing style or adds one case (closed set, compiler-checked) instead of a new `Bool` that every call site must learn about.
- **Work:** introduce grouped structs with the existing booleans mapped 1:1 (no behavior change), migrate call sites, then collapse the system-named booleans into the two enums above. Capability parity test vs today's `ReleaseSurface`/descriptor output.

### Component C — Play Engine (finish P3–P5; delete `BattleRules`)

- **Current:** `PlayEngineConfig` enum (`phasedRound`/`alternatingActivation`) holds config; `BattleRules` enum is a facade that reads `registry.playEngine(for:)` but **still falls back to `SpearheadBattleRules`** and still exposes `isStarCraft`/`isSpearhead` probes. `SpearheadBattleRules`, `CombatPatrolBattleRules`, `ScTmgBattleRules` still exist as separate types.
- **Problem:** `BattleRules` is the god switch the spec said to delete in P3 — it's still here with ~234 references. Identity probes survive.
- **Target:**
  - Promote `PlayEngineConfig` into a real `protocol PlayEngine: Sendable` (or keep the enum but make it the *only* source — kill the `SpearheadBattleRules` fallback). The engine answers: round count, phases, initial/turn-start phase, round label, clamp, **phase advancement**, and **coaching hooks**.
  - `registry.engine(for:)` returns the configured engine. Delete `BattleRules`, `SpearheadBattleRules`, `CombatPatrolBattleRules`, `ScTmgBattleRules`; fold their data into engine config in the manifest. CP is `phasedRound` + a phase set + capability flags — not its own type.
  - `isSpearhead`/`isStarCraft` → replaced by `engine.id == .phasedRound` (rare, legitimate engine branch) or a capability read (preferred).
- **Work:** this is the largest Domain change. Do it behind the existing registry API so Features don't move yet. Full engine parity tests (every existing `BattleTrackerEngineTests`/`ScTmgActivationTests` must pass against the unified engine).

### Component D — Content & Catalog pipeline (the box-set engine)

This is the component the existing specs under-specify and the one that most directly serves "new GW editions / box sets."

- **Current:** Catalogs are JSON under `Resources/Catalogs/40k/*.json` + `Resources/Rules/<System>/armies/*.json`; box-set/featured-army definitions are hardcoded in `FeaturedArmiesConfig` inside `GameSystemId+Bundled.swift`. Import is via hand-run `Scripts/*.py` (`import_combat_patrol_from_wahapedia.py`, `import_spearhead_warscrolls.py`, etc.). Validation exists only as Swift unit tests (`SpearheadCatalogCompletenessTests`, `*CatalogRosterAuditTests`).
- **Problem:** A new box set requires: hand-authoring JSON in an implicit schema, editing Swift (`FeaturedArmiesConfig`), and hoping a Swift test catches gaps. No machine-readable schema, no pre-commit/CI validation gate, no single "box set" content type.
- **Target — a content plane with a contract:**
  1. **Versioned JSON Schemas** (`Resources/Schemas/catalog-v1.schema.json`, `boxset-v1.schema.json`, `game-systems-manifest-v1.schema.json`). Every content file declares `schemaVersion`.
  2. **A first-class `BoxSet` content type** (data, not code): `<system>-boxsets-v1.json` lists box sets with their featured matchups, starter rosters, mission defaults, and badge copy — replacing the hardcoded `FeaturedArmiesConfig` in Swift. A box set release = add one JSON object.
  3. **A validation CLI** (`Scripts/validate_content.py` or a tiny SwiftPM executable `tabletome-content-lint`) run in **pre-commit** and **CI**: schema-validate, cross-reference (every `armyId` resolves, every `factionId` exists, every `missionId` exists, points totals within battle-size bounds, no orphaned units). This converts today's Swift audit tests into a fast, content-author-facing gate.
  4. **Importer normalization:** the `Scripts/*.py` family emits schema-valid v1 JSON and is documented as the only sanctioned authoring path. One importer interface, per-publisher adapters.
  5. **Catalog rename** (Component K) so the content type names (`PlayCatalog`, `PlayArmy`) match the multi-system reality.
- **Work:** author schemas from existing JSON shapes (reverse-engineer the current files); build `BoxSet` model + loader; port `FeaturedArmiesConfig` data to `*-boxsets-v1.json`; write the validator; wire pre-commit (`Scripts/pre-commit` already exists) + CI. **Outcome:** adding the next 40k/AoS box set is a reviewed JSON PR with a green content-lint check — no Swift.

### Component E — Navigation & Routing

- **Current:** Two navigation systems coexist: `RootTabView` with manual `selectedTab`/`learnPath: NavigationPath` juggling + `AppRouter`/`HobbyRouter` (`@Environment`) for the Hobby side + `LearnNavigationCoordinator` + `ActiveGameContextStore` (static) + `AppDeepLink`. `RootTabView` has ~10 `onChange`/`onReceive` handlers reconciling tab state.
- **Problem:** Navigation state is spread across static stores, multiple routers, and view-local `@State`. Deep-link and tab reconciliation logic lives in the view. Hard to test, easy to desync.
- **Target:** A single `AppRouter` (Observable) owning `selectedTab`, per-tab `NavigationPath`, and pending deep-link/learn actions. `ActiveGameContextStore` static becomes router state. `RootTabView` becomes declarative (`router.path(for:)`), with reconciliation logic moved into the router and unit-tested. Keep the Hobby router merged or clearly bridged.
- **Work:** consolidate routers; move `ActiveGameContextStore` and `LearnNavigationCoordinator` logic into the unified router; add router unit tests; thin `RootTabView`.

### Component F — DesignSystem (group by engine, share by capability)

- **Current:** ~85 flat files; ~30 are system-specific (`FortyKStartHereCard`, `ScStartHereCard`, `ScTmgDeploymentChecklistCard`, `Wh40kDeploymentChecklistCard`, `CombatPatrolTableStateCard`, `SpearheadRulesComparisonCard`, `CombatPatrolRulesComparisonCard`, …).
- **Problem:** Per-system cards grow linearly. A "StartHereCard" per system means N cards that are 80% identical. No grouping signals which engine owns what.
- **Target:**
  - Folder structure: `DesignSystem/Shared/` (truly generic: `SurfaceCard`, `PrimaryButton`, `PhaseChip`, `DiceRollButton`, `MatchVictoryScreen`, `ArmyTrackerCard`), `DesignSystem/PhasedRound/`, `DesignSystem/AltActivation/`, plus `DesignSystem/Hobby/` (exists).
  - Collapse the N `*StartHereCard` / `*DeploymentChecklistCard` / `*WhatYouNeedCard` / `*RulesComparisonCard` into **one parameterized card each**, driven by `GameSystemCopy` + capability/style enum. A `StartHereCard(descriptor:)` renders from data; a `DeploymentChecklistCard(style:)` switches on the (closed) `DeploymentChecklistStyle` enum.
  - System-only cards that genuinely differ (`ScActivationBar`, `CombatPatrolTableStateCard`) live under their engine folder and render only when the engine's content view includes them — not gated by a global boolean in shared chrome.
- **Work:** reorganize into folders (XcodeGen `createIntermediateGroups: true` makes this cheap); parameterize the 4 families of near-duplicate cards; snapshot tests on the consolidated cards across descriptors.

### Component G — View decomposition (kill the god views)

- **Current:** `GuidedMatchView.swift` 1273 LOC; `BattlePhaseTrackerView` + 15 `+` partials; `BattlePhaseTrackerViewModel` 546 LOC + `+CombatPatrol`/`+GuideFlow`/`+MatchLog`/`+PlayContext` extensions; `MatchStepDetailView` 644 LOC; `UnitFocusSheet` 505 LOC.
- **Problem:** The `+System` extension pattern means new systems append behavior to a shared monolith → merge contention, untestable units, and the exact linear growth the registry was supposed to stop.
- **Target (this is P5, expanded):**
  - `Features/Play/` package. `PlayShell` owns engine-agnostic chrome (army cards, nav, sync, history, victory). It selects content by `descriptor.playEngine`:
    - `PhasedRoundTrackerView` + `PhasedRoundTrackerViewModel` (Spearhead, 40k 11e, 40k CP — CP is config, not a `+` extension)
    - `AlternatingActivationTrackerView` + `…ViewModel` (SC TMG; future Warcry/Shatterpoint)
  - Each engine view model is a small, testable unit. `+System` extensions are deleted; CP logic moves into phased-engine config.
  - Break `GuidedMatchView` into the hub (`GuidedMatchView+HubTabs` already exists) + extracted setup/army-selection/history subviews, each < ~250 LOC.
- **Work:** extract per-engine VMs with parity tests vs the monolith (golden-master on tracker state transitions), then delete the monolith in one commit once parity holds. Sequence: SC TMG first (smallest), then phased, then delete `BattlePhaseTrackerViewModel`.

### Component H — Combat resolver routing

- **Current:** `Domain/Engines/` has `CombatRollEngineRouter`, `Wh40k10eCombatRollEngine`, `Wh40k11eCombatRollEngine`, plus classic; routing keyed off capability booleans `usesWh40k10e/11eCombatRollEngine`.
- **Problem:** Identity-shaped booleans select the engine.
- **Target:** `capabilities.combat.engineKind: CombatRollEngineKind` (Component B). `CombatRollEngineRouter` switches on the enum (closed set). A new system's resolver is either an existing kind or one new enum case + one engine type.
- **Work:** fold the booleans into `CombatRollEngineKind`; router switches on it; keep existing engine implementations and their tests untouched.

### Component I — Persistence (Hobby / SwiftData) & match state

- **Current:** `TabletomeHobbyData` wraps SwiftData (`Army`, `Roster`, `RosterEntry`, `ArmyUnit`, `SquadMember`, `HobbyPaint`, `ModelPhoto`, …) with backup/CSV/photo IO; `MatchHistory` persists via `JSONMatchHistoryRepository`; live match state via `MatchSessionStore`/`MatchSyncSnapshot`. `SWIFT_STRICT_CONCURRENCY: complete` here.
- **Problem:** Two persistence stacks (SwiftData for Hobby, JSON for match history/catalogs). No declared schema-migration policy for SwiftData as models evolve per edition. `MatchSyncSnapshot` versioning vs new engines is "partially there" (per spec).
- **Target:**
  - Document and enforce a **SwiftData schema-migration policy** (versioned `SchemaMigrationPlan`) so new-edition fields (e.g. per-edition unit attributes) don't risk user-data loss. Add a migration test harness.
  - **Version `MatchSyncSnapshot` per engine** so a phased-round snapshot and an alternating-activation snapshot evolve independently; add round-trip codec tests per engine (Component C's engine kinds).
  - Keep catalogs/rules as bundled read-only JSON (correct as-is) — only *user* data needs migration rigor.
- **Work:** add `SchemaMigrationPlan` scaffold + tests; version the sync snapshot; codec round-trip tests.

### Component J — Feature flags / ReleaseSurface (gate readiness, not identity)

- **Current:** `Support/ReleaseSurface.swift` contains `switch gameSystemId` and per-system visibility (`showsBenchTab`, `isGameSystemVisible`, `showsRulesAssistant`, …). Each new id = ~3 edits (per the spec's own note).
- **Problem:** Identity-gated release surface; edits required per system.
- **Target:** `ReleaseSurface` reads `descriptor.capabilities.surface` + `descriptor.availability` (`available` / `comingSoon` / `hidden`) from the manifest. A system's launch readiness is a **data flag**, not code. Global tab toggles (`showsBenchTab`) stay as build-config flags; per-system gating becomes manifest `availability`.
- **Work:** move per-system visibility into manifest `availability`; `ReleaseSurface` becomes a thin reader + global build flags; parity test that visible set is unchanged at migration time.

### Component K — Naming normalization (Spearhead → Play)

- **Current:** `SpearheadCatalog`, `SpearheadArmy`, `SpearheadUnit`, `SpearheadCatalogRepository`, `BundledSpearheadCatalogRepository`, `Domain/Models/SpearheadCatalog.swift` — used for all four systems.
- **Problem:** Names imply Spearhead-specific data; onboarding tax for new-franchise contributors; implies assumptions that aren't there.
- **Target:** `PlayCatalog`, `PlayArmy`, `PlayUnit`, `PlayCatalogRepository` (the protocol already exists in `Domain/Protocols/PlayCatalogRepository.swift` alongside the Spearhead one — converge them). Use `typealias SpearheadCatalog = PlayCatalog` during migration; delete typealiases last.
- **Work:** purely mechanical, behind typealiases; do it **incrementally and last** so it never blocks behavioral work. (Per the spec's own "what NOT to do": don't block features on rename.)

### Component L — Concurrency & module boundaries (Swift 6 hardening)

- **Current:** `SWIFT_VERSION: 6.0`; `TabletomeData` = `SWIFT_STRICT_CONCURRENCY: minimal`, `TabletomeHobbyData` = `complete`, Domain unspecified (defaults). View models are `@MainActor` `ObservableObject`.
- **Problem:** Mixed strictness hides data-race risk in `TabletomeData`; the registry/engines must be provably `Sendable` before they're shared across actors (sync, background catalog loads).
- **Target:** raise `TabletomeData` and Domain to `SWIFT_STRICT_CONCURRENCY: complete`; confirm all Domain types `Sendable` (registry/descriptor/engine already are); standardize VMs on `@MainActor @Observable` (migrate off `ObservableObject` where cheap). Evaluate splitting the app target into SPM modules **only if** build times or boundary leakage demand it (Component A note) — not a goal in itself.
- **Work:** flip strict-concurrency flags one target at a time, fix fallout, lock with CI.

---

## 4. Definition of "scalable" (acceptance, measurable)

The refactor is done when these hold (extends the play-engine spec's metrics):

| Metric | Today | Target |
|--------|-------|--------|
| `switch gameSystemId` in non-registry code | 20 | **0** |
| Raw id string-literal comparisons | 46 | **0** |
| `BattleRules` / `is*` identity probes | ~234 | **0** (`BattleRules` deleted) |
| `PlayCapabilities` flat booleans | 15 | **grouped structs + 2 enums; 0 system-named flags** |
| System-specific DesignSystem cards | ~30 | **≤ ~8** (genuinely unique, engine-foldered) |
| Largest view file | 1273 LOC | **< ~400 LOC** |
| Add a same-engine **box set** | Swift + JSON + test | **JSON PR + green content-lint, 0 Swift** |
| Add a same-engine **system/edition** | ~25 files | **manifest row + catalog/boxset JSON + copy (0–1 Swift)** |
| Add a **new engine archetype** | n/a | **1 engine type + 1 content view + 1 VM; shell/chrome reused** |
| Strict concurrency | mixed | **`complete` on all targets** |
| Content has a machine-checked schema | no | **yes (CI gate)** |

---

## 5. Phased execution roadmap

Each phase is independently shippable, ends green, and has an explicit exit gate. Phases 1–3 *finish work already started*; 4–6 are the new structural wins; 7–9 are hardening and polish. Rough sizing is relative effort, not calendar.

### Phase 0 — Guardrails & baseline (small) — ✅ LANDED
**Objective:** make regressions impossible to merge silently.
- ✅ `Scripts/check_architecture_debt.sh` — grep ratchet that **fails on new** `switch gameSystemId`, raw id string literals, `BattleRules`/`is*` probes, and system-named capability flags. Budgets = measured baseline; ratchet down per phase.
- ✅ Baseline counts recorded as budgets (switch 20 · raw-id 46 · BattleRules/probes 225 · system-caps 26).
- ✅ Content-lint plane stood up: `Resources/Schemas/{game-systems-manifest,catalog,boxset}-v1.schema.json` + `Scripts/validate_content.py` (schema + cross-reference invariants; passes clean on current content, catches dangling box-set refs).
- ✅ Both gates wired into `Scripts/pre-commit` (path-scoped) and `.github/workflows/ci.yml` (`guardrails` job, plus a `build-test` macOS/Xcode job).
**Components:** D (scaffold), guardrails. **Exit:** ✅ CI prints debt counts and blocks new debt; content changes are schema/cross-ref validated.

### Phase 1 — Finish the registry as source of truth (medium)
**Objective:** descriptors and release surface become data; remove static registry globals.
- Author `game-systems-manifest-v1.json` + `GameSystemsManifestLoader`; make it authoritative; reduce `GameSystemId+Bundled.swift` to a test seed.
- Remove `GameSystemRegistry.bundled` static references inside `BattleRules`/`GameSystemRulesLabels`; inject the registry instance.
- Migrate `ReleaseSurface` per-system gates → manifest `availability` (Component J).
**Components:** A, J. **Exit:** zero `GameSystemRegistry.bundled` inside Domain types; visibility parity test green.

### Phase 2 — Capability de-bagging (medium)
**Objective:** kill system-named booleans before they multiply.
- Introduce grouped capability structs (Component B), map existing booleans 1:1 (no behavior change), migrate readers.
- Collapse `usesWh40k10e/11eCombatRollEngine` → `CombatRollEngineKind`; `shows*DeploymentChecklist` → `DeploymentChecklistStyle`.
- Route `CombatRollEngineRouter` off the new enum (Component H).
**Components:** B, H. **Exit:** no system-named flags in `PlayCapabilities`; capability parity test green.

### Phase 3 — Delete `BattleRules`; unify the engine (large)
**Objective:** finish P3 — one engine path, no god facade, no Spearhead fallback.
- Promote `PlayEngineConfig` to the single engine source; fold `SpearheadBattleRules`/`CombatPatrolBattleRules`/`ScTmgBattleRules` into engine config/manifest.
- Migrate `BattleFlowGuide`, `PhaseContextCoach`, `BattleTrackerStore`, `MatchSetupCompletionEvaluator`, `BattleChecklistCompletionEvaluator` to `registry.engine(for:)`.
- Delete `BattleRules` and the three `*BattleRules` types. Replace `isSpearhead`/`isStarCraft` with engine/capability reads.
**Components:** C. **Exit:** `BattleRules` deleted; engine parity tests green; `is*` probe count = 0 in Domain.

### Phase 4 — Content plane & box-set engine (large)
**Objective:** new editions/box sets become pure data.
- Finalize JSON Schemas (catalog, boxset, manifest) reverse-engineered from current files.
- Add `BoxSet` Domain model + loader; port `FeaturedArmiesConfig` Swift data → `<system>-boxsets-v1.json`.
- Promote `Scripts/validate_content.py` (or `tabletome-content-lint`) to a **blocking** CI + pre-commit gate; convert the Swift catalog-audit tests' invariants into the linter.
- Document the importer → schema → lint authoring path.
**Components:** D. **Exit:** a sample "add a box set" PR touches only JSON and passes lint; `FeaturedArmiesConfig` no longer hand-coded per system in Swift.

### Phase 5 — Split Play UI by engine (large)
**Objective:** finish P5 — no god views, no `+System` extensions.
- Create `Features/Play/PlayShell` (engine-agnostic chrome) selecting content by `descriptor.playEngine`.
- Extract `AlternatingActivationTrackerView(+VM)` (SC TMG) first; parity-test; then `PhasedRoundTrackerView(+VM)` (Spearhead/40k/CP); fold CP `+` logic into phased config.
- Delete `BattlePhaseTrackerViewModel` + `+System` extensions once golden-master parity holds. Break up `GuidedMatchView` (1273 LOC) into ≤250-LOC subviews.
**Components:** G. **Exit:** largest Play file < ~400 LOC; adding a phased system needs no new VM file.

### Phase 6 — DesignSystem regrouping & card consolidation (medium)
**Objective:** UI surface stops growing per system.
- Folder by engine (`Shared`/`PhasedRound`/`AltActivation`/`Hobby`).
- Collapse the `*StartHereCard` / `*DeploymentChecklistCard` / `*WhatYouNeedCard` / `*RulesComparisonCard` families into parameterized, descriptor/style-driven cards; snapshot-test across descriptors.
**Components:** F. **Exit:** system-specific card count ≤ ~8; no global-boolean gating of shared chrome.

### Phase 7 — Navigation consolidation (medium)
**Objective:** one router, testable, declarative root.
- Unify `AppRouter`/`LearnNavigationCoordinator`/`ActiveGameContextStore` into one `@Observable` router owning tabs + paths + pending actions; thin `RootTabView`; router unit tests.
**Components:** E. **Exit:** `RootTabView` reconciliation logic moved to router with tests; static `ActiveGameContextStore` removed.

### Phase 8 — Persistence & concurrency hardening (medium)
**Objective:** safe data evolution + Swift 6 strictness everywhere.
- SwiftData `SchemaMigrationPlan` + migration tests; version `MatchSyncSnapshot` per engine with round-trip codec tests.
- Raise `TabletomeData` + Domain to `SWIFT_STRICT_CONCURRENCY: complete`; standardize VMs on `@MainActor @Observable`.
**Components:** I, L. **Exit:** all targets `complete`; migration + codec tests green.

### Phase 9 — Naming normalization & spec promotion (small–medium, can trail)
**Objective:** converge names; lock the architecture in `specs/`.
- `Spearhead*` → `Play*` behind typealiases, then delete typealiases.
- Reassess whether `GameSystemId` should become an open `RawRepresentable` struct (only if a remote/plugin content story is now real).
- Promote this plan to `specs/` with Verification blocks; update `ArchitectureSpec.md`, `DataSchemaSpec.md`, `PlayEngineArchitectureSpec.md`.
**Components:** A (revisit), K. **Exit:** no `Spearhead`-named generic types; specs updated.

**Sequencing notes:** Phases 1→2→3 are a dependency chain (registry → capabilities → engine). Phase 4 (content) can run **in parallel** with 2–3 (different files). Phase 5 depends on 2–3 (needs grouped caps + unified engine). Phases 6–8 are largely independent and can interleave. Phase 9 trails everything.

---

## 6. The acid test — cookbooks for new content

The whole plan exists to make these three flows cheap. After the refactor:

### 6.1 New **box set** for an existing edition (e.g. next 40k Combat Patrol box)
1. Author/extend `<system>-catalog-v1.json` with the new units (or reuse existing datasheets) — via the sanctioned importer.
2. Add one object to `wh40k-10e-cp-boxsets-v1.json`: box id, featured matchup, the two starter rosters (army ids), default mission, badge copy.
3. Run content-lint locally → green. Open PR → CI content-lint green.
4. **Swift changed: none.** Ships in a content-only release.

### 6.2 New **edition** on an existing engine (e.g. 40k 12e, AoS 5th — phased round)
1. Add a manifest row in `game-systems-manifest-v1.json`: new `GameSystemId` case (one enum line), `playEngine: phasedRound`, engine config (phases, round count), `capabilities` (existing enums/structs), `copy`, `availability: comingSoon`.
2. Add `<system>-catalog-v1.json` + `<system>-boxsets-v1.json`.
3. If a phase set or checklist style is genuinely new → add one `DeploymentChecklistStyle`/phase enum case + render arm (compiler-guided, closed set).
4. Flip `availability` to `available` when the featured matchup is playable end-to-end.
5. **Swift changed: 1 enum case + at most one closed-enum arm.** No new VM, no new repo, no `switch gameSystemId`.

### 6.3 New **engine archetype** (e.g. Blood Bowl grid-sport, Legion command-card)
1. Add `PlayEngineId` case + an engine type conforming to `PlayEngine`.
2. Add one content view + one view model under `Features/Play/<Engine>/`; `PlayShell` routes to it by `descriptor.playEngine`.
3. Reuse shared chrome (army cards, victory, history, sync) from `DesignSystem/Shared/`; add only the genuinely new cards under `DesignSystem/<Engine>/`.
4. Manifest + catalog + boxset JSON as in 6.2.
**Budget: one engine, one view, one VM — the shell and content plane are reused.** This matches the MultiFranchiseExpansionPlan's "one new engine per year max; many systems share an engine."

---

## 7. Cross-cutting concerns

- **Testing strategy:** Every phase that touches behavior ships a **parity test** (golden-master) before the old path is deleted — engine state transitions (Phase 3), tracker VM state (Phase 5), capability/visibility output (Phases 1–2), codec round-trips (Phase 8). Content invariants move from Swift audits into the content-linter (Phase 4) so they run pre-merge and are author-facing. Add snapshot tests for the consolidated DesignSystem cards (Phase 6).
- **CI guardrails:** the Phase 0 grep-ratchet + content-lint are the backbone — they make the refactor *stick* by blocking re-introduction of the patterns being removed.
- **Performance:** keep engine routing as `switch` over a small enum (the spec's "no reflection / type-erasure everywhere" rule). Catalog loads stay off the main actor (needs Component L's `Sendable` guarantees). Watch SwiftUI body churn when `RootTabView` slims down — measure with Instruments before/after Phase 7.
- **Accessibility/localization:** unchanged contracts — consolidated cards must preserve existing `accessibilityIdentifier`s (`screen.element.action`) and `String(localized:)` copy; snapshot + a11y-id tests guard this during Phase 6.
- **Backwards compatibility:** persisted `gameSystemId` strings and match-history JSON must keep resolving — `GameSystemId(resolving:)` already provides a fallback; keep it. Legacy ids (e.g. `wh40k-10e`) must continue to map.

---

## 8. Risks & mitigations

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| Big-bang temptation on Phase 3/5 (largest) | Med | Strangler fig + parity tests; delete old type only after green golden-master |
| Capability enums leak identity again (a `case wh40kOnly`) | Med | Name capability cases by *behavior* (`spearhead`-style checklist describes a layout, not a brand); review gate |
| Content schema churn breaks authored JSON | Med | `schemaVersion` field + additive-only v1; v2 only with a migration note |
| SwiftData migration data loss | Low/High-impact | `SchemaMigrationPlan` + migration tests before any model field change ships |
| Rename pass (Phase 9) creates merge churn | Low | Pure typealias mechanics, done last, ideally in a quiet window |
| Refactor stalls mid-flight, leaving two patterns | Med | Each phase independently shippable + valuable; the grep-ratchet prevents backsliding even if later phases slip |
| Scope creep into Hobby/Bench/Muster | Med | This plan touches Hobby only in Component I (migration policy); Bench/Muster feature work is out of scope |

---

## 9. Open decisions (lock before promoting to specs/)

1. **Engine representation:** keep `PlayEngineConfig` enum vs promote to `protocol PlayEngine`? (Enum is simpler/Sendable-trivial; protocol is more extensible for exotic engines. Recommendation: **enum now, protocol when the 3rd archetype lands**.)
2. **Content-lint host:** Python (`Scripts/`, matches existing importers) vs a SwiftPM `tabletome-content-lint` executable (one language, reuses Domain models). Recommendation: **SwiftPM executable** so the schema *is* the Domain `Codable` types — single source of truth.
3. **Manifest vs codegen:** hand-authored manifest (fine < ~20 systems) vs generated from JSON at build time. Recommendation: **hand-authored** until > ~15 systems.
4. **Module split:** stay single app target (faster, simpler) vs SPM-modularize `Features/Play`. Recommendation: **defer** — only split if build time or boundary leakage forces it.
5. **`GameSystemId` openness:** keep closed `CaseIterable` enum (compile-time exhaustiveness, current) vs open `RawRepresentable` struct (remote/plugin content). Recommendation: **stay closed** until a remote-content product requirement is real.

---

## Verification

| Field | Value |
|-------|-------|
| Status | Proposal — not yet implemented |
| Baseline metrics | `switch gameSystemId`: 20 · raw id literals: 46 · `BattleRules`/`is*` refs: ~234 · `PlayCapabilities` flags: 15 · system-specific DS cards: ~30 · largest view: 1273 LOC |
| Code paths in scope | `Domain/Registry/`, `Domain/Models/BattleRules.swift` (delete), `Domain/Engines/`, `Domain/UseCases/`, `Data/JSON/`, `Resources/Catalogs/`, `Resources/Rules/`, `Resources/Schemas/` (new), `Features/GuidedMatch/` → `Features/Play/`, `DesignSystem/`, `Support/ReleaseSurface.swift`, `Support/Navigation/`, `App/` |
| Supersedes/extends | `specs/PlayEngineArchitectureSpec.md` (P4–P5), `FutureIdeas/MultiFranchiseExpansionPlan.md` (M0) |
| Last updated | 2026-06-28 |
