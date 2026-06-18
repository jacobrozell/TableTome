import Foundation

public struct ArmyUnitHealth: Sendable, Equatable, Identifiable {
    public let unitId: String
    public let unitName: String
    public let woundsRemaining: Int
    public let woundCapacity: Int

    public var id: String { unitId }

    public var isDestroyed: Bool {
        woundsRemaining == 0
    }

    public var fractionRemaining: Double {
        guard woundCapacity > 0 else { return 0 }
        return Double(woundsRemaining) / Double(woundCapacity)
    }

    public init(unitId: String, unitName: String, woundsRemaining: Int, woundCapacity: Int) {
        self.unitId = unitId
        self.unitName = unitName
        self.woundsRemaining = woundsRemaining
        self.woundCapacity = woundCapacity
    }
}

public struct ArmyHealthSummary: Sendable, Equatable {
    public let armyId: String
    public let armyName: String
    public let playerName: String
    public let units: [ArmyUnitHealth]

    public var trackableUnitCount: Int {
        units.count
    }

    public var aliveUnitCount: Int {
        units.filter { !$0.isDestroyed }.count
    }

    public var totalWoundsRemaining: Int {
        units.reduce(0) { $0 + $1.woundsRemaining }
    }

    public var totalWoundCapacity: Int {
        units.reduce(0) { $0 + $1.woundCapacity }
    }

    public var destroyedUnitCount: Int {
        units.filter(\.isDestroyed).count
    }

    public var fractionRemaining: Double {
        guard totalWoundCapacity > 0 else { return 0 }
        return Double(totalWoundsRemaining) / Double(totalWoundCapacity)
    }

    public func visibleUnits(hidingDestroyed: Bool) -> [ArmyUnitHealth] {
        hidingDestroyed ? units.filter { !$0.isDestroyed } : units
    }

    public init(armyId: String, armyName: String, playerName: String, units: [ArmyUnitHealth]) {
        self.armyId = armyId
        self.armyName = armyName
        self.playerName = playerName
        self.units = units
    }
}

public enum ArmyHealthCatalog {
    public static func summary(
        army: SpearheadArmy,
        playerName: String,
        woundsRemaining: [String: Int],
        healthPerModelOverrides: [String: Int] = [:]
    ) -> ArmyHealthSummary? {
        let units = army.units
            .filter { $0.health != nil }
            .map { unit -> ArmyUnitHealth in
                let key = UnitWoundTracker.unitKey(armyId: army.id, unitId: unit.id)
                let capacity = UnitWoundCapacity.capacity(
                    for: unit,
                    healthPerModelOverride: healthPerModelOverrides[key]
                )
                let remaining = woundsRemaining[key] ?? capacity
                return ArmyUnitHealth(
                    unitId: unit.id,
                    unitName: unit.name,
                    woundsRemaining: remaining,
                    woundCapacity: capacity
                )
            }
            .sorted { lhs, rhs in
                if lhs.isDestroyed != rhs.isDestroyed {
                    return !lhs.isDestroyed
                }
                return lhs.unitName.localizedCaseInsensitiveCompare(rhs.unitName) == .orderedAscending
            }

        guard !units.isEmpty else { return nil }

        return ArmyHealthSummary(
            armyId: army.id,
            armyName: army.name,
            playerName: playerName,
            units: units
        )
    }
}
