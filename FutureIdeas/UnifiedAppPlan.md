# Unified App Plan — Prep → Muster → Play

**Status:** Future work (non-authoritative until promoted to `specs/`)  
**Canonical repo:** **Tabletome** (`/Users/jrozell/Desktop/personal/Tabletome`)  
**Port source:** MiniMuster iOS (`WarhammerTracker/ios/`) — **frozen**; no new feature work there  
**Related:** [CatalogKeyAudit.md](CatalogKeyAudit.md) · [MiniMusterPortFreeze.md](MiniMusterPortFreeze.md)

## Product thesis

One offline-first app for the full tabletop loop:

| Pillar | Verb | Question |
|--------|------|----------|
| **Bench** | Prep | What do I own? What’s still on the sprue? |
| **Muster** | List | What am I bringing to the table? |
| **Play** | Play | What do I do right now? |

StarCraft TMG lives under **Play** (and Muster later if lists ship). Warhammer hobby lives under **Bench** and **Muster**.

Neither Tabletome nor MiniMuster is released — merge as architecture work, not user migration.

---

## Locked decisions

| Decision | Choice |
|----------|--------|
| Canonical repo | **Tabletome** |
| Display name (for now) | **Tabletome** — rename before TestFlight if desired |
| Bundle ID (for now) | `com.jacobrozell.tabletome` |
| MiniMuster | Read-only port source; see freeze note |
| Min iOS | 17 today → **18** before SwiftData port (Phase 4) |
| Module strategy | Extend Tabletome’s XcodeGen targets (Domain / Data / Hobby) |

---

## Architecture principles

### Two data planes — never mixed

| Plane | Contents | Storage | Updates |
|-------|----------|---------|---------|
| **Reference** | Rules, warscrolls, play rosters, Muster points catalogs | Bundled JSON | App releases |
| **User** | Armies, paints, rosters, match state | SwiftData (+ UserDefaults during Play migration) | User |

Cross-pillar links use stable IDs only (`gameSystemId`, `catalogUnitKey`, `armyId`, `rosterId`). See [CatalogKeyAudit.md](CatalogKeyAudit.md).

### Dependency rules (extend `specs/ArchitectureSpec.md`)

```
Features/Bench, Features/Muster, Features/Play
    ↓ protocols
TabletomeDomain
    ↓
TabletomeData (reference JSON) + TabletomeHobbyData (SwiftData)
DesignSystem + Support
```

- Domain: Foundation only.
- No feature-to-feature imports.
- `ReleaseSurface` gates pillars and cross-links.

### Target navigation (end state)

| Tab | Contents |
|-----|----------|
| **Bench** | Collection + Paints |
| **Muster** | Roster builder + collection match |
| **Play** | Game picker → guided match (Tabletome today) |
| **Rules** | Search / reference |

Settings: gear on Bench or Play nav bar (MiniMuster pattern).

---

## Target module map

| Target | Contents |
|--------|----------|
| `Tabletome` | App shell, Features |
| `TabletomeDomain` | Models, use cases, protocols, shared identity |
| `TabletomeData` | Bundled JSON repositories |
| `TabletomeHobbyData` | SwiftData models, CSV/backup I/O (port from MiniMuster) |
| `TabletomeTests` | Unit tests |

Optional later: split `Features/Bench`, `Features/Muster`, `Features/Play` into frameworks if compile times or import enforcement require it.

---

## Phases

### Phase 0 — Foundation ✅ (decisions locked)

- [x] Canonical repo: Tabletome
- [x] Pillars defined: Bench / Muster / Play
- [x] Catalog key audit started → [CatalogKeyAudit.md](CatalogKeyAudit.md)
- [x] MiniMuster frozen → [MiniMusterPortFreeze.md](MiniMusterPortFreeze.md)
- [ ] Tab IA wireframes
- [ ] Promote to `specs/UnifiedArchitectureSpec.md` when module map locks

### Phase 1 — Repo scaffold (in progress)

- [x] `TabletomeHobbyData` target + `Data/Hobby/` stub
- [ ] Bump `deploymentTarget` to iOS 18.0
- [ ] `SWIFT_STRICT_CONCURRENCY: complete` on all targets
- [ ] CI green with new target
- [ ] Folder skeleton: `Features/Bench`, `Features/Muster`, `Features/Play` (placeholders)

### Phase 2 — Domain kernel

Port pure MiniMuster domain (no SwiftData/SwiftUI):

- `Pipeline`, `FactionDefs`, `FactionResolver`, `CollectionMatcher`, `RosterPoints`, `BattleSize`, `CatalogUnit`
- Shared `GameSystemId`, `CatalogUnitKey` in Domain
- Align catalog keys per [CatalogKeyAudit.md](CatalogKeyAudit.md)
- Port MiniMuster domain unit tests

**Exit:** Domain tests green; no SwiftData in Domain.

### Phase 3 — Design system unification

Merge tokens; single `BrandCrest`, `EmptyStateView`, chip components; one accessibility identifier scheme (`screen.element.action`).

### Phase 4 — Hobby data layer

Port SwiftData models (`Army`, `Unit`, `Paint`, `Roster`, …), `AppContainer`, DataIO (CSV, JSON backup), `RosterStore`, widget snapshot writer.

**Exit:** MiniMuster DataIO tests pass in Tabletome.

### Phase 5 — Bench pillar

Port Collection + Paints tabs; `ReleaseSurface.showsBenchTab`.

### Phase 6 — Muster pillar

Port `MusterTab`, unit catalogs → `Resources/Catalogs/`; collection match UI.

### Phase 6b — Play engine architecture (blocking — do before multi-franchise)

Today’s Play layer does not scale: ~35 files with identical `switch gameSystemId` blocks, four catalog repos in DI, `BattleRules` god switch, monolithic battle tracker ViewModel. **Must refactor before Blood Bowl, Legion, etc.**

Phased plan: [PlayEngineArchitectureRefactor.md](PlayEngineArchitectureRefactor.md) (registry + manifest → unified catalog repo → `PlayEngine` protocol → capability-driven UI → tracker split by engine).

**Exit:** new game system = manifest JSON + catalog bundle; no new switch arms in Features.

### Phase 7 — Play pillar consolidation

Reorganize existing Tabletome guided match under `Features/Play/` **after Phase 6b**; optional SwiftData `PlaySession` (migrate from UserDefaults).

### Phase 8 — Cross-pillar glue

- Muster → Play: “Play this roster”
- Play → Bench: paint status on units (`CollectionMatcher` / `UnitNameMatch`)
- Bench → Muster: “Muster this army”
- Unified `DeepLinkRouter`

### Phase 9 — Shell polish

Onboarding, widget extension, iPad layouts, TipKit, privacy merge.

### Phase 10 — TestFlight v1

| Pillar | v1 | Post-v1 |
|--------|-----|---------|
| Bench | Collection + Paints + backup | Photos, iCloud |
| Muster | 40k roster MVP | AoS catalog, BS import |
| Play | Spearhead + 40k CP + SC-TMG (per `ReleaseSurface`) | — |
| Rules | Reference / search | Rules AI |

---

## `ReleaseSurface` (unified shape)

```swift
// Pillars
static var showsBenchTab: Bool
static var showsMusterTab: Bool
static var showsPlayTab: Bool
static var showsRulesTab: Bool

// Cross-links
static var showsPlayFromRoster: Bool
static var showsPaintStatusInMatch: Bool

// Existing per-game gates unchanged
static func showsGuidedMatch(for gameSystemId: String) -> Bool
```

---

## Risks

1. **Catalog key mismatch** between Muster points catalog and Play warscroll IDs — #1 integration bug; audit first.
2. **Two 40k data sources** short-term — document divergence; converge in Phase 2/6.
3. **Scope creep** — ship pillars independently via `ReleaseSurface`.

---

## Promotion path

When behavior locks: `FutureIdeas/UnifiedAppPlan.md` → `specs/UnifiedProductSpec.md` + `specs/UnifiedArchitectureSpec.md` with Verification blocks.
