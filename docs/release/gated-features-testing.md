# Gated features — testing backlog

**Status:** Future work · **Target:** complete before each gated feature ships to production  
**Context:** [1.0.0 TestFlight status](status.md) · [Release surface gates](../../specs/ReleaseSurfaceSpec.md)

1.0.0 TestFlight validates the **default release surface** only (Spearhead + 40k 11e, four tabs, no Paints/Lists). Everything behind `-enable_full_product_surface` or a separate launch arg still needs a defined test pass before ungating.

## How to test gated features today

| Launch argument | Unlocks |
|-----------------|---------|
| `-enable_full_product_surface` | Lists tab, Paints, Combat Patrol, StarCraft, Rules Q&A, 40k 10e, cross-pillar links |
| `-enable_wh40k_combat_resolver` | 11e combat resolver (can combine with full surface) |

**Simulator / Xcode:** Edit Scheme → Run → Arguments Passed On Launch.

**Automation helpers** (combine as needed): `-skip_onboarding`, `-open_guided_match`, `-apply_starter_matchup`, `-open_battle_tracker` — see [TestPlanSpec.md](../../specs/TestPlanSpec.md).

---

## Summary matrix

| Gated feature | Unit / domain tests | Release-surface tests | Manual QA | UI automation | Ship blocker |
|---------------|--------------------|-----------------------|-----------|---------------|--------------|
| Paints (Models) | Partial | ❌ | ❌ | ❌ | Polish + QA pass |
| Lists (Muster) | Partial | ❌ | ❌ | ❌ | Polish + QA pass |
| Play from roster | ❌ | ❌ | ❌ | ❌ | Depends on Muster |
| Paint status in match | ❌ | ❌ | ❌ | ❌ | Depends on Paints |
| Combat Patrol (10e CP) | ✅ Strong | ❌ | ❌ | ❌ | End-to-end Play QA |
| StarCraft TMG | ✅ Strong | ❌ | ❌ | ❌ | End-to-end Play QA |
| Rules Q&A assistant | Partial | ❌ | ❌ | ❌ | Quality + licensing review |
| 40k 10e (coming soon) | N/A | ❌ | ❌ | ❌ | Content not ready |
| 11e combat resolver | Partial | ❌ | ❌ | ❌ | Separate launch arg QA |

**Legend:** ✅ = meaningful automated coverage exists; Partial = domain only, not surface/integration; ❌ = not done for ungate sign-off.

---

## 1. Paints (Models tab segment)

**Gate:** `ReleaseSurface.showsPaintsInBench`

### Existing automated coverage

- `Tests/Unit/Hobby/BackupCodecTests.swift`, `BackupSanitizerTests.swift` — paints in backup snapshot
- `Tests/Unit/Hobby/PipelineTests.swift` — hobby data pipeline

### Still needed

**Unit / integration**

- [ ] `ReleaseSurfaceTests` — full-surface path asserts `showsPaintsInBench == true`
- [ ] Paints CRUD ViewModel or store tests (add, edit, delete, filter)
- [ ] Backup round-trip with non-empty paints array
- [ ] `BenchTab` — when gated off, router `.paints` deep link falls back to Collection

**Manual QA** (with `-enable_full_product_surface`)

- [ ] Models tab shows Collection | Paints segmented control
- [ ] Add paint, edit quantity/brand, delete
- [ ] Settings backup export/import preserves paints
- [ ] VoiceOver on Paints list and add sheet
- [ ] iPhone + iPad layout

**UI automation**

- [ ] Launch with full surface → open Paints segment → add paint flow (`bench.sectionPicker`, paints identifiers)

**Promotion criteria:** Manual QA checklist complete; no P0/P1 bugs; product polish sign-off.

---

## 2. Lists / Muster tab

**Gate:** `ReleaseSurface.showsMusterTab`, `showsPlayFromRoster`

### Existing automated coverage

- `Tests/Unit/Muster/RosterStoreTests.swift`, `UnitCatalogLoaderTests.swift`, `UnitNameMatchTests.swift`
- `Tests/Unit/Hobby/RosterPointsTests.swift`
- `Tests/Unit/NewRosterPrefillResolverTests.swift`
- `Tests/Unit/AppDeepLinkTests.swift` — `minimuster://muster` URLs

### Still needed

**Unit / integration**

- [ ] `ReleaseSurfaceTests` — full-surface path asserts `showsMusterTab` and `showsPlayFromRoster`
- [ ] `NewRosterSheet` / roster editor integration tests (create 40k + AoS lists, point totals)
- [ ] Collection ↔ roster linking when both Bench and Muster visible
- [ ] Deep links reach Muster tab when `showsMusterTab == false` (graceful no-op or redirect)

**Manual QA**

- [ ] Lists tab visible; create roster (40k 11e, Spearhead)
- [ ] Edit units, custom points, faction/battle size hints
- [ ] **Play from roster** opens Guided Match with prefilled armies
- [ ] Link roster to Collection army
- [ ] New list keyboard Done dismisses (see [release checklist](release_checklist.md))
- [ ] Deep links: `minimuster://muster`, roster detail URLs
- [ ] Onboarding tab tour includes Lists when full surface on

**UI automation**

- [ ] Full surface → Lists tab → new roster → save → open in editor
- [ ] Play from roster → lands in Guided Match setup

**Promotion criteria:** Muster polish complete; Play-from-roster smoke on iPhone + iPad.

---

## 3. Combat Patrol (40k 10e CP)

**Gate:** `ReleaseSurface.isGameSystemVisible("wh40k-10e-cp")` (full surface only in 1.0.0)

### Existing automated coverage

- `Tests/Unit/BundledCombatPatrolCatalogRepositoryTests.swift`
- `Tests/Unit/CombatPatrolStratagemPhaseTests.swift`
- `Tests/Unit/Wh40k10eCombatRollEngineTests.swift`
- `Tests/Unit/AppSearchEngineTests.swift` — CP search index

### Still needed

**Unit / integration**

- [ ] `ReleaseSurfaceTests` — full-surface visibility + guided match + combat resolver for `wh40k-10e-cp`
- [ ] Guided Match CP mission selection and stratagem phase flow
- [ ] Match history record/reopen for CP game system id

**Manual QA**

- [ ] Home row shows Combat Patrol; onboarding picker includes CP
- [ ] Getting Started + Guided Match (SM vs Tyranids starter)
- [ ] Combat resolver in battle tracker (10e engine)
- [ ] Rules reference CP categories and missions
- [ ] Offline smoke

**UI automation**

- [ ] `-enable_full_product_surface` + `-open_guided_match` with CP system context
- [ ] Battle tracker combat resolver entry for CP

**Promotion criteria:** Parity with Spearhead smoke checklist in [release_checklist.md](release_checklist.md).

---

## 4. StarCraft TMG

**Gate:** `ReleaseSurface.isGameSystemVisible("sc-tmg")`

### Existing automated coverage

- `Tests/Unit/BundledScTmgCatalogRepositoryTests.swift`
- `Tests/Unit/ScTmgActivationTests.swift`
- `Tests/Unit/GameSystemRegistryTests.swift`
- `Tests/Unit/AppSearchEngineTests.swift` — SC index

### Still needed

**Unit / integration**

- [ ] `ReleaseSurfaceTests` — full-surface visibility + guided match for `sc-tmg`
- [ ] Supply pool + activation bar in battle tracker (engine-level tests exist; UI wiring untested)
- [ ] SC-specific deployment checklist

**Manual QA**

- [ ] Home + onboarding show StarCraft
- [ ] Founders Edition starter matchup Guided Match
- [ ] Activation / supply UX in battle phases
- [ ] Rules search SC glossary and topics
- [ ] Offline smoke

**UI automation**

- [ ] Full surface → select SC → starter matchup → battle tracker activation bar

**Promotion criteria:** [StarCraftTMGLaunchPlan.md](../../FutureIdeas/StarCraftTMGLaunchPlan.md) Phase 2 sign-off items complete.

---

## 5. Rules Q&A assistant

**Gate:** `ReleaseSurface.showsRulesAssistant` (Rules tab shows `AppSearchView` instead of `RulesReferenceView`)

### Existing automated coverage

- `Tests/Unit/AppSearchEngineTests.swift`, `AppSearchViewModelTests.swift`

### Still needed

**Unit / integration**

- [ ] `ReleaseSurfaceTests` — full-surface `showsRulesAssistant == true`
- [ ] Search → destination routing (rules section, warscroll, combat resolver link)
- [ ] Per-system search picker respects `isGameSystemVisible`

**Manual QA**

- [ ] Rules tab icon/label switches to search affordance
- [ ] Query → result → correct detail screen for Spearhead, 40k 11e, CP, SC (when each visible)
- [ ] Empty / low-confidence query UX
- [ ] VoiceOver on search field and results

**Quality / legal**

- [ ] On-device assistant quality review ([RulesAIAssistant.md](../../FutureIdeas/RulesAIAssistant.md))
- [ ] Licensing review for generated answers

**Promotion criteria:** Spec promoted from FutureIdeas; quality bar met; not a stub.

---

## 6. Cross-pillar links

**Gates:** `showsPlayFromRoster`, `showsPaintStatusInMatch`

### Still needed

- [ ] Unit tests for visibility when full surface off (no-op / hidden UI)
- [ ] Manual: paint status chips in Guided Match when paints exist in collection
- [ ] Manual: roster → Play handoff with correct game system and armies

---

## 7. 40k 11e combat resolver

**Gate:** `-enable_wh40k_combat_resolver` (separate from full surface)

### Existing automated coverage

- `Wh40k10eCombatRollEngineTests.swift` (10e engine; 11e may share or extend)
- `ReleaseSurfaceTests.testCombatResolverHiddenForWh40k11eByDefault`

### Still needed

**Manual QA** (with `-enable_wh40k_combat_resolver`)

- [ ] Resolver entry visible in 11e battle tracker only when arg set
- [ ] Roll flow matches 11e rules; trust tests updated if engine differs from 10e CP

**Promotion criteria:** Flip default in `ReleaseSurface` or manifest capability without launch arg.

---

## 8. Release surface test harness (meta)

Today `ReleaseSurfaceTests` and `PillarSurfaceTests` assert **1.0.0 defaults only**. Before ungating any feature:

- [ ] Add `ReleaseSurfaceFullSurfaceTests` (or inject launch args in test host) asserting opposite of release defaults
- [ ] CI: keep default tests on every PR; optional nightly job with `-enable_full_product_surface` scheme
- [ ] Document test scheme in [TestPlanSpec.md](../../specs/TestPlanSpec.md)

Suggested test host approach: duplicate critical assertions under a test plan configuration that passes `-enable_full_product_surface` to the test bundle host, **or** extract gate logic to testable pure functions that take `fullSurfaceEnabled: Bool`.

---

## When to update this doc

- A gated feature moves to **shipped** in [feature-inventory.md](../feature-inventory.md) → mark its section complete and date the sign-off in [status.md](status.md).
- New gate added in `ReleaseSurface.swift` → add a section here before merging.
- Unit or UI tests land → update the summary matrix.
