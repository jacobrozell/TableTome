import Foundation
import TabletomeDomain

extension BattlePhaseTrackerViewModel {
    var selectedMission: CombatPatrolMission? {
        guard playContext.capabilities.usesPatrolFormatRules,
              let missionId = matchState.selectedMissionId else { return nil }
        return catalog.missions.first { $0.id == missionId }
    }

    var usesPatrolFormatRules: Bool {
        playContext.capabilities.usesPatrolFormatRules
    }

    var focusedCombatPatrolDeploymentStep: CombatPatrolDeploymentChecklistStep? {
        guard playContext.capabilities.usesPatrolFormatRules, trackerState.battleRound == 1 else { return nil }
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

    var phaseStratagems: [CombatPatrolStratagem] {
        guard playContext.capabilities.usesPatrolFormatRules, let army = activeArmy else { return [] }
        if trackerState.showAllAbilities {
            return army.stratagems
        }
        return army.stratagems.filter { $0.matches(battlePhase: trackerState.currentPhase) }
    }

    func toggleStratagem(_ stratagem: CombatPatrolStratagem) {
        guard let armyId = activeArmy?.id else { return }
        let key = "\(armyId):\(stratagem.id)"
        if trackerState.usedStratagemIds.contains(key) {
            trackerState.usedStratagemIds.remove(key)
        } else {
            trackerState.usedStratagemIds.insert(key)
        }
        persist()
    }

    func isStratagemUsed(_ stratagem: CombatPatrolStratagem) -> Bool {
        guard let armyId = activeArmy?.id else { return false }
        return trackerState.usedStratagemIds.contains("\(armyId):\(stratagem.id)")
    }

    static func gotchas(for armyId: String, gameSystemId: GameSystemId, army: SpearheadArmy? = nil) -> [SpearheadGotcha] {
        gotchas(for: armyId, gameSystemId: gameSystemId.rawValue, army: army)
    }

    static func gotchas(for armyId: String, gameSystemId: String, army: SpearheadArmy? = nil) -> [SpearheadGotcha] {
        let context = GameSystemPlayContext.context(for: gameSystemId)
        if context.capabilities.showsBattleTacticDecks {
            return SpearheadGotchaCatalog.gotchas(for: armyId)
        }
        if context.capabilities.usesPatrolFormatRules {
            return CombatPatrolGotchaCatalog.gotchas(for: armyId, army: army)
        }
        return []
    }
}
