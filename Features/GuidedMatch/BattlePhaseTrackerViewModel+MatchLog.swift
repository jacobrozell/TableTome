import Foundation
import TabletomeDomain

extension BattlePhaseTrackerViewModel {
    func recordMatchLog(kind: MatchLogEventKind, payload: MatchLogEventPayload) {
        guard ReleaseSurface.showsMatchHistory else { return }
        MatchLogRecorder.record(gameSystemId: gameSystemId, kind: kind, payload: payload)
    }

    func recordPhaseChanged(previousPhase: BattleTurnPhase) {
        guard previousPhase != trackerState.currentPhase else { return }
        recordMatchLog(
            kind: .phaseChanged,
            payload: MatchLogEventPayload(
                round: trackerState.battleRound,
                phaseId: trackerState.currentPhase.rawValue,
                playerIsOne: trackerState.activePlayerIsOne,
                playerName: trackerState.activePlayerIsOne ? playerOneName : playerTwoName
            )
        )
    }

    func recordActivePlayerChanged() {
        recordMatchLog(
            kind: .activePlayerChanged,
            payload: MatchLogEventPayload(
                round: trackerState.battleRound,
                phaseId: trackerState.currentPhase.rawValue,
                playerIsOne: trackerState.activePlayerIsOne,
                playerName: trackerState.activePlayerIsOne ? playerOneName : playerTwoName
            )
        )
    }

    func recordRoundAdvanced(previousRound: Int) {
        guard trackerState.battleRound != previousRound else { return }
        recordMatchLog(
            kind: .roundAdvanced,
            payload: MatchLogEventPayload(round: trackerState.battleRound)
        )
    }

    func recordVictoryPointsChange(
        playerIsOne: Bool,
        delta: Int,
        reason: MatchVictoryPointsReason
    ) {
        recordMatchLog(
            kind: .victoryPointsChanged,
            payload: MatchLogEventPayload(
                round: trackerState.battleRound,
                playerIsOne: playerIsOne,
                playerName: playerIsOne ? playerOneName : playerTwoName,
                delta: delta,
                newTotal: playerIsOne
                    ? trackerState.playerOneVictoryPoints
                    : trackerState.playerTwoVictoryPoints,
                pointsReason: reason
            )
        )
    }

    func recordAbilityUsed(_ ability: TriggeredAbility) {
        recordMatchLog(
            kind: .abilityUsed,
            payload: MatchLogEventPayload(
                round: trackerState.battleRound,
                phaseId: trackerState.currentPhase.rawValue,
                abilityId: ability.id,
                abilityName: ability.name
            )
        )
    }

    func recordDeploymentStep(_ stepId: String) {
        recordMatchLog(
            kind: .deploymentStepCompleted,
            payload: MatchLogEventPayload(
                round: trackerState.battleRound,
                stepId: stepId
            )
        )
    }

    func recordDamage(
        armyId: String,
        unitId: String,
        woundsRemoved: Int,
        woundsRemaining: Int,
        source: String
    ) {
        let unitName = army(withId: armyId)?.units.first { $0.id == unitId }?.name ?? unitId
        let playerIsOne = matchState.playerOne.armyId == armyId
        recordMatchLog(
            kind: .damageApplied,
            payload: MatchLogEventPayload(
                round: trackerState.battleRound,
                phaseId: trackerState.currentPhase.rawValue,
                playerIsOne: playerIsOne,
                unitId: unitId,
                unitName: unitName,
                woundsRemoved: woundsRemoved,
                woundsRemaining: woundsRemaining,
                damageSource: source
            )
        )
        if woundsRemaining == 0 {
            recordMatchLog(
                kind: .unitDestroyed,
                payload: MatchLogEventPayload(
                    round: trackerState.battleRound,
                    playerIsOne: playerIsOne,
                    unitId: unitId,
                    unitName: unitName
                )
            )
        }
    }

    func logWoundChange(key: String, previous: Int?, remaining: Int) {
        guard let previous, remaining < previous, let (armyId, unitId) = parseUnitKey(key) else { return }
        recordDamage(
            armyId: armyId,
            unitId: unitId,
            woundsRemoved: previous - remaining,
            woundsRemaining: remaining,
            source: "manual"
        )
    }

    func parseUnitKey(_ key: String) -> (String, String)? {
        let parts = key.split(separator: ":", maxSplits: 1).map(String.init)
        guard parts.count == 2 else { return nil }
        return (parts[0], parts[1])
    }

    func recordCombatBatchResolved(_ context: CombatBatchLogContext) {
        recordMatchLog(
            kind: .combatBatchResolved,
            payload: MatchLogEventPayload(
                round: trackerState.battleRound,
                phaseId: trackerState.currentPhase.rawValue,
                attackerUnitName: context.attackerUnitName,
                defenderUnitName: context.defenderUnitName,
                weaponName: context.weaponName,
                combatHits: context.hits,
                combatWounds: context.wounds,
                combatFailedSaves: context.failedSaves,
                combatDamageDealt: context.damageDealt
            )
        )
    }
}
