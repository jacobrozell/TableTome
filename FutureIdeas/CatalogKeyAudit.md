# Catalog Key Audit — MiniMuster Muster ↔ Tabletome Play

**Status:** Living document (Phase 0 / 2 input)  
**Parent:** [UnifiedAppPlan.md](UnifiedAppPlan.md)

## Why two ID schemes exist today

| System | Purpose | ID shape | Example |
|--------|---------|----------|---------|
| **MiniMuster UnitCatalog** | List building (points, qty) | `{game}:{faction-slug}:{unit-slug}` | `40k:grey-knights:interceptor-squad` |
| **Tabletome play catalogs** | Guided match (warscrolls, abilities) | `{unit-slug}` scoped by `armyId` | `intercessors` in `operation-imperator` |

They serve different jobs. Cross-pillar glue (Phase 8) needs an explicit **mapping layer**, not a forced merge on day one.

---

## MiniMuster Muster catalog

**Loader:** `WarhammerTracker/ios/MiniMuster/Domain/Muster/UnitCatalogLoader.swift`  
**Resources:** `MiniMuster/Resources/UnitCatalog/`

**Index key:** `"40k:Grey Knights"` → file `40k/grey-knights.json`  
**Unit id:** lowercase faction slug in path segment:

```text
40k:grey-knights:interceptor-squad
40k:chaos-space-marines:legionaries
40k:space-marines:intercessor-squad
```

**Fields:** `name`, `basePoints`, `category`, `keywords`, `aliases`, `edition`, `pointsKey`

**Factions in index (today):** Grey Knights, Space Marines, Necrons, Orks, Chaos Space Marines

---

## Tabletome play catalogs

**Loader:** `BundledWh40kCatalogRepository` / `BundledCombatPatrolCatalogRepository`  
**Resources:** `Resources/Rules/Wh40k/armies/*.json`, `wh40k-catalog-v1.json`

**Army scope:** `armyId` e.g. `operation-imperator`, `waaagh-armageddon`  
**Unit id:** short slug within army file:

```text
operation-imperator / intercessors
operation-imperator / captain-relic-shield
waaagh-armageddon / (army-specific slugs)
```

**Fields:** `name`, `keywords`, `modelCount`, `abilities`, `notes` — no points

**Game system ids:** `wh40k-10e-cp`, `wh40k-11e`, `aos-spearhead`, `sc-tmg`

---

## Proposed unified identity (Domain)

```swift
/// Global Muster / collection catalog key (MiniMuster format).
struct CatalogUnitKey: Hashable, Sendable {
    let rawValue: String  // "40k:grey-knights:interceptor-squad"
}

/// Play roster unit within a bundled army (Tabletome format).
struct PlayUnitRef: Hashable, Sendable {
    let gameSystemId: String   // "wh40k-10e-cp"
    let armyId: String         // "operation-imperator"
    let unitId: String         // "intercessors"
}

/// Crosswalk when glue layer connects Muster → Play.
struct CatalogPlayLink: Sendable {
    let catalogKey: CatalogUnitKey
    let playRef: PlayUnitRef
    let matchConfidence: MatchConfidence  // exact | alias | fuzzy
}
```

---

## Mapping strategy by game

### 40k — Combat Patrol (overlap exists)

CP box armies are a **subset** of faction catalogs. Mapping is many catalog keys → one play ref, or name match.

| Muster key (example) | Play ref (example) | Match method |
|----------------------|-------------------|--------------|
| `40k:space-marines:intercessor-squad` | `operation-imperator` / `intercessors` | Name normalize |
| `40k:space-marines:eradicator-squad` | `operation-imperator` / `eradicators` | Name normalize (plural) |

**Gap:** Muster catalog is faction-wide; Play is box-specific. Phase 8 must filter play armies by faction/game before matching.

### 40k — Open play / Muster only

Grey Knights roster units have Muster keys but **no** Tabletome play army yet. “Play this roster” falls back to manual setup or future `wh40k-11e` armies.

### AoS Spearhead

| Muster (future) | Play (today) |
|-----------------|--------------|
| Not bundled in MiniMuster yet | `aos-spearhead` army JSON with unit ids like `kragnos` |

When AoS Muster catalog ships, prefer **same slug** as Spearhead catalog unit id where possible.

### StarCraft TMG

| Muster (future) | Play (today) |
|-----------------|--------------|
| TBD | `sc-tmg-catalog-v1.json` unit ids |

Tabletome owns SC identity; define `sc-tmg:{faction}:{unit}` when Muster catalog is added.

---

## Name matching (existing code to port)

MiniMuster already implements fuzzy collection ↔ roster matching:

- `Domain/Muster/CollectionMatcher.swift`
- `Domain/Muster/UnitNameMatch.swift`

Phase 8 reuses this for Play ↔ Bench (paint status) and Muster → Play (roster seed).

---

## Action items

| # | Task | Phase |
|---|------|-------|
| 1 | Add `CatalogUnitKey` + `PlayUnitRef` to `TabletomeDomain` | 2 |
| 2 | Script: dump all MiniMuster catalog ids + names | 2 |
| 3 | Script: dump all Tabletome play unit ids + names per army | 2 |
| 4 | Generate `catalog-play-links-40k.json` for CP overlaps | 2 |
| 5 | Unit tests: known pairs (Intercessors, Eradicators, …) | 2 |
| 6 | Document unmapped catalog keys (expected gaps) | 2 |

---

## Sample overlap table (manual seed)

| CatalogUnitKey | PlayUnitRef | Notes |
|----------------|-------------|-------|
| `40k:space-marines:intercessor-squad` | `wh40k-10e-cp` / `operation-imperator` / `intercessors` | CP box |
| `40k:space-marines:eradicator-squad` | `wh40k-10e-cp` / `operation-imperator` / `eradicators` | CP box |
| `40k:grey-knights:interceptor-squad` | — | No play army yet |
| `40k:grey-knights:strike-squad` | — | No play army yet |

Expand this table as play armies and Muster factions grow.
