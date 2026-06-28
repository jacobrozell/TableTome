import Foundation
import TabletomeDomain

extension BattlePhaseTrackerViewModel {
    var focusedDeploymentStep: DeploymentChecklistStep? {
        guard playContext.capabilities.showsBattleTacticDecks, trackerState.battleRound == 1 else { return nil }
        return BattleFlowGuide.nextIncompleteDeploymentStep(in: trackerState.completedDeploymentSteps)
    }

    var focusedWh40kDeploymentStep: Wh40kDeploymentChecklistStep? {
        guard playContext.capabilities.deploymentChecklistStyle == .wh40k, trackerState.battleRound == 1 else { return nil }
        return BattleFlowGuide.nextIncompleteWh40kSetupStep(in: trackerState.completedDeploymentSteps)
    }

    var focusedRoundOpenerStep: BattleRoundChecklistStep? {
        guard playContext.capabilities.showsBattleTacticDecks else { return nil }
        return BattleFlowGuide.nextIncompleteRoundOpenerStep(
            round: trackerState.battleRound,
            completedSteps: trackerState.completedRoundChecklistSteps
        )
    }

    var startOfRoundAbilities: [TriggeredAbility] {
        startOfRoundAbilities(for: playerOneArmy) + startOfRoundAbilities(for: playerTwoArmy)
    }

    var needsStartOfRoundAbilitiesPrompt: Bool {
        guard playContext.capabilities.showsBattleTacticDecks else { return false }
        return !BattleRoundChecklist.isComplete(
            step: .startOfRoundAbilities,
            round: trackerState.battleRound,
            completedSteps: trackerState.completedRoundChecklistSteps
        )
    }

    var roundOpenerIsIncomplete: Bool {
        focusedRoundOpenerStep != nil
    }

    /// Regiment ability and enhancement when they explicitly trigger in the current phase.
    var phaseArmyRuleOptions: [ArmyRuleOption] {
        guard let army = activeArmy else { return [] }
        let player = activePlayerSelection
        var options: [ArmyRuleOption] = []
        if let regiment = army.regimentAbilities.first(where: { $0.id == player.regimentAbilityId }),
           regiment.isAvailableIn(phase: trackerState.currentPhase) {
            options.append(regiment)
        }
        if let enhancement = army.enhancements.first(where: { $0.id == player.enhancementId }),
           enhancement.isAvailableIn(phase: trackerState.currentPhase) {
            options.append(enhancement)
        }
        return options
    }

    var underdogIsPlayerOne: Bool? {
        guard playContext.capabilities.showsBattleTacticDecks else { return nil }
        let p1 = trackerState.playerOneVictoryPoints
        let p2 = trackerState.playerTwoVictoryPoints
        if p1 == p2 { return nil }
        return p1 < p2
    }

    func setDeploymentStep(_ step: DeploymentChecklistStep, complete: Bool) {
        if complete {
            trackerState.completedDeploymentSteps.insert(step.rawValue)
            recordDeploymentStep(step.rawValue)
        } else {
            trackerState.completedDeploymentSteps.remove(step.rawValue)
        }
        persist()
    }

    func setWh40kDeploymentStep(_ step: Wh40kDeploymentChecklistStep, complete: Bool) {
        if complete {
            trackerState.completedDeploymentSteps.insert(step.rawValue)
            recordDeploymentStep(step.rawValue)
        } else {
            trackerState.completedDeploymentSteps.remove(step.rawValue)
        }
        persist()
    }

    func setRoundChecklistStep(_ step: BattleRoundChecklistStep, complete: Bool) {
        let key = BattleRoundChecklist.storageKey(round: trackerState.battleRound)
        var steps = trackerState.completedRoundChecklistSteps[key] ?? []
        if complete {
            steps.insert(step.rawValue)
        } else {
            steps.remove(step.rawValue)
        }
        trackerState.completedRoundChecklistSteps[key] = steps
        persist()
    }

    func completePhasedRoundTurnPhase(_ phase: BattleTurnPhase) {
        if phase == .endOfTurn {
            if trackerState.battleRound >= playContext.playEngine.battleRoundCount() {
                return
            }
            trackerState.activePlayerIsOne.toggle()
            trackerState.currentPhase = playContext.playEngine.turnStartPhase()
            persist()
            refreshAbilities()
        } else {
            advancePhase()
        }
    }

    func startOfRoundAbilities(for army: SpearheadArmy?) -> [TriggeredAbility] {
        guard let army else { return [] }
        return BattleAbilityCatalog.abilities(for: army).filter(\.isStartOfBattleRound)
    }
}
