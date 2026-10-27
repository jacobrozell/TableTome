import Foundation
import TabletomeDomain

extension SpearheadBattleViewModel {
    func isActivePlayerArmy(_ armyId: String) -> Bool {
        let activeArmyId = trackerState.activePlayerIsOne ? playerOneArmy?.id : playerTwoArmy?.id
        return armyId == activeArmyId
    }

    func playerName(forArmyId armyId: String) -> String {
        if matchState.playerOne.armyId == armyId { return playerOneName }
        if matchState.playerTwo.armyId == armyId { return playerTwoName }
        return ""
    }

    func healthPerModelOverride(for key: String) -> Int? {
        trackerState.unitHealthPerModelOverrides[key]
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
}
