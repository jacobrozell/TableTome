import Foundation
import TabletomeDomain

extension BattlePhaseTrackerViewModel {
    func setUnitWounds(key: String, remaining: Int) {
        let previous = trackerState.unitWoundsRemaining[key]
        trackerState.unitWoundsRemaining[key] = remaining
        persist()
        logWoundChange(key: key, previous: previous, remaining: remaining)
    }

    func applyDamageToUnit(armyId: String, unitId: String, damage: Int) -> Int? {
        guard damage > 0 else { return nil }
        let key = UnitWoundTracker.unitKey(armyId: armyId, unitId: unitId)
        let current = trackerState.unitWoundsRemaining[key] ?? 0
        let remaining = max(0, current - damage)
        trackerState.unitWoundsRemaining[key] = remaining
        persist()
        recordDamage(
            armyId: armyId,
            unitId: unitId,
            woundsRemoved: damage,
            woundsRemaining: remaining,
            source: "combat"
        )
        return current
    }

    func healthPerModelOverride(for key: String) -> Int? {
        trackerState.unitHealthPerModelOverrides[key]
    }

    func woundCapacity(for armyId: String, unit: SpearheadUnit) -> Int {
        let key = UnitWoundTracker.unitKey(armyId: armyId, unitId: unit.id)
        return UnitWoundCapacity.capacity(
            for: unit,
            healthPerModelOverride: trackerState.unitHealthPerModelOverrides[key]
        )
    }

    func effectiveHealthPerModel(for armyId: String, unit: SpearheadUnit) -> Int {
        let key = UnitWoundTracker.unitKey(armyId: armyId, unitId: unit.id)
        return UnitWoundCapacity.healthPerModel(
            for: unit,
            override: trackerState.unitHealthPerModelOverrides[key]
        ) ?? 1
    }

    func setUnitHealthPerModelOverride(armyId: String, unit: SpearheadUnit, healthPerModel: Int?) {
        let key = UnitWoundTracker.unitKey(armyId: armyId, unitId: unit.id)
        let previousCapacity = woundCapacity(for: armyId, unit: unit)
        if let healthPerModel, healthPerModel > 0 {
            trackerState.unitHealthPerModelOverrides[key] = healthPerModel
        } else {
            trackerState.unitHealthPerModelOverrides.removeValue(forKey: key)
        }
        let newCapacity = woundCapacity(for: armyId, unit: unit)
        let current = trackerState.unitWoundsRemaining[key] ?? previousCapacity
        trackerState.unitWoundsRemaining[key] = min(current, newCapacity)
        persist()
    }

    func unitId(matchingSource source: String, in army: SpearheadArmy?) -> String? {
        guard let army else { return nil }
        let normalized = source.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return army.units.first {
            $0.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == normalized
        }?.id
    }

    func ensureWoundTrackingInitialized() {
        var updated = false
        for army in [playerOneArmy, playerTwoArmy].compactMap({ $0 }) {
            for unit in army.units where unit.health != nil {
                let key = UnitWoundTracker.unitKey(armyId: army.id, unitId: unit.id)
                if trackerState.unitWoundsRemaining[key] == nil {
                    trackerState.unitWoundsRemaining[key] = woundCapacity(for: army.id, unit: unit)
                    updated = true
                }
            }
        }
        if updated { persist() }
    }
}
