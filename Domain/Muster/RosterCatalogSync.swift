import Foundation

/// Compares roster entry snapshots to the bundled unit catalog (GW Munitorum–sourced JSON).
public enum RosterCatalogSync {
    public enum EntryPointsKind: Sendable, Hashable {
        case catalog
        case customOverride
        case catalogMissing
    }

    public struct EntryPointsInfo: Sendable, Hashable {
        public let kind: EntryPointsKind
        public let pointsEach: Int
        public let catalogPoints: Int?
        public let pointsKey: String
        public let catalogVersion: String

        public init(
            kind: EntryPointsKind,
            pointsEach: Int,
            catalogPoints: Int?,
            pointsKey: String,
            catalogVersion: String
        ) {
            self.kind = kind
            self.pointsEach = pointsEach
            self.catalogPoints = catalogPoints
            self.pointsKey = pointsKey
            self.catalogVersion = catalogVersion
        }
    }

    public struct EntrySnapshot: Sendable, Hashable {
        public let catalogUnitId: String
        public let pointsEach: Int
        public let usesCustomPoints: Bool

        public init(catalogUnitId: String, pointsEach: Int, usesCustomPoints: Bool = false) {
            self.catalogUnitId = catalogUnitId
            self.pointsEach = pointsEach
            self.usesCustomPoints = usesCustomPoints
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
        public let customOverrideCount: Int

        public var hasVersionDrift: Bool {
            !rosterCatalogVersion.isEmpty && rosterCatalogVersion != catalogVersion
        }

        public var hasPointsDrift: Bool { !driftedEntries.isEmpty }

        public var needsRefresh: Bool {
            hasVersionDrift || hasPointsDrift || !missingCatalogIds.isEmpty
        }

        public var driftCount: Int { driftedEntries.count }
    }

    public struct CatalogAttribution: Sendable, Hashable {
        public let pointsKey: String
        public let version: String
        public let attribution: String
    }

    public static var catalogAttribution: CatalogAttribution {
        UnitCatalogLoader.loadIfNeeded()
        return CatalogAttribution(
            pointsKey: UnitCatalogLoader.pointsKey,
            version: UnitCatalogLoader.version,
            attribution: UnitCatalogLoader.attribution
        )
    }

    public static func entryPointsInfo(for snapshot: EntrySnapshot) -> EntryPointsInfo {
        UnitCatalogLoader.loadIfNeeded()
        let key = UnitCatalogLoader.pointsKey
        let version = UnitCatalogLoader.version
        if snapshot.usesCustomPoints {
            return EntryPointsInfo(
                kind: .customOverride,
                pointsEach: snapshot.pointsEach,
                catalogPoints: catalogPoints(for: snapshot.catalogUnitId),
                pointsKey: key,
                catalogVersion: version
            )
        }
        guard let catalogPts = catalogPoints(for: snapshot.catalogUnitId) else {
            return EntryPointsInfo(
                kind: .catalogMissing,
                pointsEach: snapshot.pointsEach,
                catalogPoints: nil,
                pointsKey: key,
                catalogVersion: version
            )
        }
        return EntryPointsInfo(
            kind: .catalog,
            pointsEach: snapshot.pointsEach,
            catalogPoints: catalogPts,
            pointsKey: key,
            catalogVersion: version
        )
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
        var customOverrides = 0
        for entry in entries {
            if entry.usesCustomPoints {
                customOverrides += 1
                continue
            }
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
            missingCatalogIds: missing,
            customOverrideCount: customOverrides
        )
    }
}
