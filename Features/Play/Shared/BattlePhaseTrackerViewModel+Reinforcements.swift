import Foundation
import TabletomeDomain

extension BattlePhaseTrackerViewModel {
    func isReinforcementOnTable(armyId: String, unitId: String) -> Bool {
        ReinforcementsTracking.isCalledOnTable(
            armyId: armyId,
            unitId: unitId,
            calledUnitKeys: trackerState.calledReinforcementUnitKeys
        )
    }

    func setReinforcementOnTable(armyId: String, unitId: String, onTable: Bool) {
        let key = UnitWoundTracker.unitKey(armyId: armyId, unitId: unitId)
        if onTable {
            trackerState.calledReinforcementUnitKeys.insert(key)
            if let army = army(withId: armyId),
               let unit = army.units.first(where: { $0.id == unitId }),
               unit.health != nil,
               trackerState.unitWoundsRemaining[key] == nil {
                trackerState.unitWoundsRemaining[key] = woundCapacity(for: armyId, unit: unit)
            }
            pendingReinforcementCall = nil
        } else {
            trackerState.calledReinforcementUnitKeys.remove(key)
        }
        persist()
    }

    func clearReinforcementCallPrompt() {
        pendingReinforcementCall = nil
    }

    func evaluateReinforcementCallPrompt(destroyedArmyId: String, unitId: String) {
        let unitName = army(withId: destroyedArmyId)?.units.first { $0.id == unitId }?.name ?? unitId
        pendingReinforcementCall = ReinforcementsTracking.callPrompt(
            context: ReinforcementCallContext(
                gameSystemId: gameSystemId,
                phase: trackerState.currentPhase,
                activePlayerIsOne: trackerState.activePlayerIsOne,
                destroyedArmyId: destroyedArmyId,
                playerOneArmyId: playerOneArmy?.id,
                playerTwoArmyId: playerTwoArmy?.id,
                playerOneArmy: playerOneArmy,
                playerTwoArmy: playerTwoArmy,
                playerOneName: playerOneName,
                playerTwoName: playerTwoName,
                destroyedUnitName: unitName,
                calledUnitKeys: trackerState.calledReinforcementUnitKeys
            )
        )
    }

    func clearReinforcementCallPromptIfLeavingMovement(from previous: BattleTurnPhase, to phase: BattleTurnPhase) {
        guard previous == .movement, phase != .movement else { return }
        pendingReinforcementCall = nil
    }
}
