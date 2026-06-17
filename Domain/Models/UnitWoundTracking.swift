import Foundation

public enum UnitWoundTracker {
    public static func unitKey(armyId: String, unitId: String) -> String {
        "\(armyId):\(unitId)"
    }
}

public enum UnitWoundCapacity {
    public static func capacity(for unit: SpearheadUnit) -> Int {
        guard let health = unit.health else { return 1 }
        return health * max(1, unit.modelCount ?? 1)
    }
}
