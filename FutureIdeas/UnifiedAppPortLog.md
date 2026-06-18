# Unified App — MiniMuster Port Log

**Status:** Living document. Tracks what has been ported from MiniMuster into Tabletome
as the Unified App Plan rolls out. Pair with [`UnifiedAppPlan.md`](UnifiedAppPlan.md).

## Phases 1 & 2

### Phase 1 — Repo scaffold

| Item | Status | Notes |
|------|--------|-------|
| Deployment target → iOS 18 | ✅ | `project.yml` |
| `TabletomeHobbyData` framework target | ✅ | Anchored by `Data/Hobby/HobbyDataModule.swift`; depends on `TabletomeDomain` |
| `SWIFT_STRICT_CONCURRENCY: complete` on all targets | ⚠️ partial | Set on `TabletomeHobbyData` only; existing targets unchanged to keep CI green. Follow-up PR promotes Domain → `targeted` → `complete`. |
| Folder skeleton `Features/Bench`, `Features/Muster`, `Features/Play` | ✅ Bench + Muster | Play stays in-place (existing Tabletome guided match is the Play pillar per the plan). Phase 7 reorganizes. |
| CI green with new target | ⏳ | Verify after merge |

### Phase 2 — Domain kernel

Ported into `Domain/Hobby/` from `MiniMuster/Domain/`:

| File | Source | Notes |
|------|--------|-------|
| `HobbyIdentity.swift` | new | `GameSystemId`, `CatalogUnitKey` shared identity types per `CatalogKeyAudit.md` |
| `HobbyProtocols.swift` | new | `ArmyLike`, `UnitLike`, `SquadMemberLike` + `FactionPresetOverride`, `safeColor`. Pure abstractions — engines never touch SwiftData. |
| `FactionDefs.swift` | `Domain/Factions/FactionDefs.swift` | Verbatim |
| `FactionResolver.swift` | `Domain/Factions/FactionResolver.swift` | Verbatim minus the `extension Army` convenience (re-add in Phase 4 once SwiftData `Army` conforms to `ArmyLike`) |
| `Tags.swift` | `Domain/Tags.swift` | Verbatim |
| `Limits.swift` | `Domain/Limits.swift` | Renamed namespace `Limits` → `HobbyLimits`; `capped` → `hobbyCapped` to avoid Tabletome collisions |
| `ModelCount.swift` | `Domain/ModelCount.swift` | Verbatim |
| `Pipeline.swift` | `Domain/Pipeline.swift` + `Models/PipelineStage.swift` | Engine operates over `UnitLike` / `ArmyLike`; `PipelineStage`, `ProgressSegment`, `NormalizedState` are value structs (SwiftData stage model will map to/from these in Phase 4) |
| `Members.swift` | `Domain/Members.swift` | Engine operates over `UnitLike` |
| `CollectionStats.swift` | `Domain/CollectionStats.swift` | Engine operates over `UnitLike` |
| `SourceMatch.swift` | `Domain/SourceMatch.swift` | Verbatim |

Tests under `Tests/Unit/Hobby/`:
- `FactionResolverTests` — composite key, alias normalization, override priority, two-char fallback
- `TagsTests` — extraction, hyphenated tags
- `ModelCountTests` — paren group sums, qty clamp
- `PillarSurfaceTests` — Bench/Muster hidden by default, Play/Rules on
- `PipelineTests` — resolve / sanitize, normalize, segments, advance + member-override clearing
- `MembersTests` — effective state fallback, sorted state summary, quick-view classification
- `CollectionStatsTests` — bucket counts, overall %, empty case
- `SourceMatchTests` — split, substring match either direction, empty guard
- `HobbyTestFixtures` — in-memory `TestUnit` / `TestSquadMember` / `TestArmy` conforming to the protocols

### Phase 1 ReleaseSurface — pillar gates

`Support/ReleaseSurface.swift` now exposes:

- `showsBenchTab`, `showsMusterTab`, `showsPlayTab`, `showsRulesTab`
- `showsPlayFromRoster`, `showsPaintStatusInMatch`

All non-Play pillars default to the `-enable_full_product_surface` launch arg, so TestFlight
and Release builds stay scoped to today's Play + Rules MVP.

---

## Deferred — to follow-up PRs

| Item | Owner / phase | Why deferred |
|------|---------------|--------------|
| `Color+Hex.swift` | DesignSystem (Phase 3) | UIKit/SwiftUI dependency belongs in DesignSystem unification, not Domain. |
| `RosterPoints`, `BattleSize`, `CatalogUnit` | Phase 2 follow-up | Needs CatalogKeyAudit decisions on key shape first. |
| Strict-concurrency promotion on existing targets | Phase 1 follow-up | Risk of breaking existing build; rolling out gradually keeps each PR reviewable. |
| Wiring `BenchTab` / `MusterTab` into `RootTabView` | Phase 5 / Phase 6 | Plan calls out that pillars ship behind their own `ReleaseSurface` flag. The views exist, but `RootTabView.swift` stays untouched until each pillar has real content. |
| SwiftData models (`Army`, `Unit`, `Paint`, `Roster`, …) → `TabletomeHobbyData` | Phase 4 | Largest single chunk; deserves its own PR with migration tests. SwiftData `Army`/`Unit` conform to `ArmyLike`/`UnitLike` so today's engines snap into place. |
| `AppContainer`, DataIO (CSV/JSON backup), widget snapshot | Phase 4 | Same as above. |

---

## MiniMuster freeze reminder

MiniMuster (`jacobrozell/MiniMuster`) is the read-only port source. No new feature work
happens there. See `MiniMusterPortFreeze.md` in this repo (to be promoted from
MiniMuster's docs) for the canonical freeze notice.
