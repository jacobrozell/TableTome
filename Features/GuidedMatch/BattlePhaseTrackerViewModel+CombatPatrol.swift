import Foundation
import TabletomeDomain

extension BattlePhaseTrackerViewModel {
    var selectedMission: CombatPatrolMission? {
        guard playContext.isCombatPatrol,
              let missionId = matchState.selectedMissionId else { return nil }
        return catalog.missions.first { $0.id == missionId }
    }

    var isCombatPatrol: Bool {
        playContext.isCombatPatrol
    }

    var focusedCombatPatrolDeploymentStep: CombatPatrolDeploymentChecklistStep? {
        guard playContext.isCombatPatrol, trackerState.battleRound == 1 else { return nil }
        return BattleFlowGuide.nextIncompleteCombatPatrolSetupStep(in: trackerState.completedDeploymentSteps)
    }

    func setCombatPatrolDeploymentStep(_ step: CombatPatrolDeploymentChecklistStep, complete: Bool) {
        if complete {
            trackerState.completedDeploymentSteps.insert(step.rawValue)
            recordDeploymentStep(step.rawValue)
        } else {
            trackerState.completedDeploymentSteps.remove(step.rawValue)
        }
        persist()
    }

    func setBattleReady(isPlayerOne: Bool, value: Bool?) {
        if isPlayerOne {
            trackerState.playerOneBattleReady = value
        } else {
            trackerState.playerTwoBattleReady = value
        }
        persist()
    }

    func applyBattleReadyBonus(isPlayerOne: Bool) {
        adjustVictoryPoints(playerIsOne: isPlayerOne, delta: 10, reason: .other)
    }

    func setSecuredObjectiveIds(_ ids: Set<String>) {
        trackerState.securedObjectiveIds = ids
        persist()
    }

    func setUsedStratagemIds(_ ids: Set<String>) {
        trackerState.usedStratagemIds = ids
        persist()
    }

    func setIntelRecoveredObjectiveIds(_ ids: Set<String>) {
        trackerState.intelRecoveredObjectiveIds = ids
        persist()
    }

    static func gotchas(for armyId: String, gameSystemId: GameSystemId) -> [SpearheadGotcha] {
        gotchas(for: armyId, gameSystemId: gameSystemId.rawValue)
    }

    static func gotchas(for armyId: String, gameSystemId: String) -> [SpearheadGotcha] {
        let context = GameSystemPlayContext.context(for: gameSystemId)
        if context.isSpearhead {
            return SpearheadGotchaCatalog.gotchas(for: armyId)
        }
        if context.isCombatPatrol {
            return CombatPatrolGotchaCatalog.gotchas(for: armyId)
        }
        return []
    }
}
