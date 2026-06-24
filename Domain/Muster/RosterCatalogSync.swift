import Foundation

/// Compares roster entry snapshots to the bundled unit catalog (GW Munitorum–sourced JSON).
public enum RosterCatalogSync {
    public struct EntrySnapshot: Sendable, Hashable {
        public let catalogUnitId: String
        public let pointsEach: Int

        public init(catalogUnitId: String, pointsEach: Int) {
            self.catalogUnitId = catalogUnitId
            self.pointsEach = pointsEach
        }
    }

    public struct Drift: Sendable, Hashable {
        public let catalogUnitId: String
        public let storedPoints: Int
        public let catalogPoints: Int

        public init(catalogUnitId: String, storedPoints: Int, catalogPoints: Int) {
            self.catalogUnitId = catalogUnitId
            self.storedPoints = storedPoints
            self.catalogPoints = catalogPoints
        }
    }

    public struct Status: Sendable, Hashable {
        public let catalogVersion: String
        public let rosterCatalogVersion: String
        public let catalogPointsKey: String
        public let driftedEntries: [Drift]
        public let missingCatalogIds: [String]

        public var hasVersionDrift: Bool {
            !rosterCatalogVersion.isEmpty && rosterCatalogVersion != catalogVersion
        }

        public var hasPointsDrift: Bool { !driftedEntries.isEmpty }

        public var needsRefresh: Bool {
            hasVersionDrift || hasPointsDrift || !missingCatalogIds.isEmpty
        }

        public var driftCount: Int { driftedEntries.count }
    }

    public static func catalogPoints(for catalogUnitId: String) -> Int? {
        UnitCatalogLoader.unit(id: catalogUnitId)?.basePoints
    }

    public static func status(
        entries: [EntrySnapshot],
        rosterCatalogVersion: String
    ) -> Status {
        UnitCatalogLoader.loadIfNeeded()
        var drifted: [Drift] = []
        var missing: [String] = []
        for entry in entries {
            guard let unit = UnitCatalogLoader.unit(id: entry.catalogUnitId) else {
                missing.append(entry.catalogUnitId)
                continue
            }
            if entry.pointsEach != unit.basePoints {
                drifted.append(
                    Drift(
                        catalogUnitId: entry.catalogUnitId,
                        storedPoints: entry.pointsEach,
                        catalogPoints: unit.basePoints
                    )
                )
            }
        }
        return Status(
            catalogVersion: UnitCatalogLoader.version,
            rosterCatalogVersion: rosterCatalogVersion,
            catalogPointsKey: UnitCatalogLoader.pointsKey,
            driftedEntries: drifted,
            missingCatalogIds: missing
        )
    }
}
