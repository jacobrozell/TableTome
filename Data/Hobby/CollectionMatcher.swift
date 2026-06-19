import Foundation
import SwiftData
import TabletomeDomain

public struct CollectionMatchResult: Sendable {
    public enum Status: Sendable { case owned, partial, missing, unknown }
    public let entryId: UUID
    public let status: Status
    public let ownedQty: Int
    public let requiredQty: Int
    public let matchedUnitIds: [UUID]
}

public enum CollectionMatcher {
    public static func matchAll(roster: Roster, armies: [Army], in ctx: ModelContext) -> [(RosterEntry, CollectionMatchResult)] {
        let units = scopedCollectionUnits(roster: roster, armies: armies)
        return roster.orderedEntries.map { entry in
            (entry, match(entry: entry, collectionUnits: units))
        }
    }

    public static func fieldablePercent(roster: Roster, armies: [Army], in ctx: ModelContext) -> Int {
        let results = matchAll(roster: roster, armies: armies, in: ctx)
        guard !results.isEmpty else { return 0 }
        let owned = results.filter { $0.1.status == .owned }.count
        return Int((Double(owned) / Double(results.count) * 100).rounded())
    }

    public static func match(entry: RosterEntry, collectionUnits: [ArmyUnit]) -> CollectionMatchResult {
        let catalog = UnitCatalogLoader.unit(id: entry.catalogUnitId)
        let required = requiredModels(entry: entry, catalog: catalog)
        let matched = collectionUnits.filter { unit in
            UnitNameMatch.matches(collectionUnitName: unit.name,
                                  catalogName: entry.displayName,
                                  aliases: catalog?.aliases ?? [])
        }
        let owned = matched.reduce(0) { $0 + ModelCount.of(name: $1.name, qty: $1.qty) }
        let status: CollectionMatchResult.Status = {
            if catalog == nil { return .unknown }
            if owned >= required { return .owned }
            if owned > 0 { return .partial }
            return .missing
        }()
        return CollectionMatchResult(
            entryId: entry.id,
            status: status,
            ownedQty: owned,
            requiredQty: required,
            matchedUnitIds: matched.map(\.id)
        )
    }

    private static func requiredModels(entry: RosterEntry, catalog: CatalogUnit?) -> Int {
        let perEntry = catalog?.modelCount ?? 1
        return entry.qty * max(1, perEntry)
    }

    private static func scopedCollectionUnits(roster: Roster, armies: [Army]) -> [ArmyUnit] {
        if let id = roster.linkedArmyId, let army = armies.first(where: { $0.id == id }) {
            return army.units
        }
        let f = FactionResolver.normalize(roster.faction)
        return armies.filter {
            $0.game == roster.game && FactionResolver.normalize($0.faction) == f
        }.flatMap(\.units)
    }
}
