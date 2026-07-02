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

    var scoreLeaderIsPlayerOne: Bool? {
        let p1 = trackerState.playerOneVictoryPoints
        let p2 = trackerState.playerTwoVictoryPoints
        if p1 == p2 { return nil }
        return p1 > p2
    }

    var nextHandoffPlayerName: String? {
        guard canPassToNextPlayerThisRound else { return nil }
        return trackerState.activePlayerIsOne ? playerTwoName : playerOneName
    }

    var isBattleComplete: Bool {
        let maxRound = playContext.playEngine.battleRoundCount()
        guard trackerState.battleRound >= maxRound else { return false }
        guard trackerState.currentPhase == .endOfTurn else { return false }
        return trackerState.completedTurnsThisRound.count >= 2
    }

    func turnIsComplete(round: Int, playerIsOne: Bool) -> Bool {
        if round < trackerState.battleRound { return true }
        guard round == trackerState.battleRound else { return false }
        return trackerState.completedTurnsThisRound.contains(playerIsOne)
    }

    func turnIsActive(round: Int, playerIsOne: Bool) -> Bool {
        round == trackerState.battleRound
            && trackerState.activePlayerIsOne == playerIsOne
            && !trackerState.completedTurnsThisRound.contains(playerIsOne)
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
            if step == .firstTurnOrPriority, matchState.firstTurnIsPlayerOne == nil {
                return
            }
            steps.insert(step.rawValue)
        } else {
            steps.remove(step.rawValue)
        }
        trackerState.completedRoundChecklistSteps[key] = steps
        persist()
        if complete {
            beginRoundTurnsIfReady()
        }
    }

    func setRoundFirstTurn(isPlayerOne: Bool) {
        if trackerState.battleRound == 1, gameSystemId == .aosSpearhead {
            correctRoundOneFirstTurn(isPlayerOne: isPlayerOne)
        } else {
            matchState.firstTurnIsPlayerOne = isPlayerOne
            trackerState.activePlayerIsOne = isPlayerOne
            persistMatchState()
            syncAutoCompletions()
        }
        let key = BattleRoundChecklist.storageKey(round: trackerState.battleRound)
        var steps = trackerState.completedRoundChecklistSteps[key] ?? []
        steps.insert(BattleRoundChecklistStep.firstTurnOrPriority.rawValue)
        trackerState.completedRoundChecklistSteps[key] = steps
        persist()
        beginRoundTurnsIfReady()
    }

    func beginRoundTurnsIfReady() {
        guard playContext.capabilities.showsBattleTacticDecks else { return }
        guard !roundOpenerIsIncomplete else { return }
        guard let firstTurnIsPlayerOne = matchState.firstTurnIsPlayerOne else { return }
        trackerState.activePlayerIsOne = firstTurnIsPlayerOne
        let turnStart = playContext.playEngine.turnStartPhase()
        if trackerState.currentPhase != turnStart {
            setPhase(turnStart)
        } else {
            persist()
            refreshAbilities()
        }
    }

    func completePhasedRoundTurnPhase(_ phase: BattleTurnPhase) {
        if phase == .endOfTurn {
            trackerState.completedTurnsThisRound.insert(trackerState.activePlayerIsOne)
            if trackerState.completedTurnsThisRound.count < 2 {
                trackerState.activePlayerIsOne.toggle()
                trackerState.currentPhase = playContext.playEngine.turnStartPhase()
                persist()
                refreshAbilities()
            } else {
                persist()
            }
        } else {
            advancePhase()
        }
    }

    func startOfRoundAbilities(for army: SpearheadArmy?) -> [TriggeredAbility] {
        guard let army else { return [] }
        return BattleAbilityCatalog.abilities(for: army).filter(\.isStartOfBattleRound)
    }
}
