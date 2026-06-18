import Foundation

public enum UnitWoundTracker {
    public static func unitKey(armyId: String, unitId: String) -> String {
        "\(armyId):\(unitId)"
    }
}

public enum UnitWoundCapacity {
    public static func healthPerModel(
        for unit: SpearheadUnit,
        override: Int? = nil
    ) -> Int? {
        override ?? unit.health
    }

    public static func capacity(
        for unit: SpearheadUnit,
        healthPerModelOverride: Int? = nil
    ) -> Int {
        guard let health = healthPerModel(for: unit, override: healthPerModelOverride) else { return 1 }
        return health * max(1, unit.modelCount ?? 1)
    }
}
