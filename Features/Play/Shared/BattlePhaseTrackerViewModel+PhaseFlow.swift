import Foundation
import TabletomeDomain

extension BattlePhaseTrackerViewModel {
    func setPhase(_ phase: BattleTurnPhase) {
        let previous = trackerState.currentPhase
        trackerState.currentPhase = phase
        if previous != phase {
            trackerEngine.afterPhaseChange(from: previous, trackerState: &trackerState)
        }
        persist()
        refreshAbilities()
        recordPhaseChanged(previousPhase: previous)
    }

    func syncAutoCompletions() {
        guard trackerEngine.usesRoundChecklistAutoCompletion(playContext: playContext) else { return }
        let suggested = BattleChecklistCompletionEvaluator.suggestedRoundCompletions(
            round: trackerState.battleRound,
            playerOneVictoryPoints: trackerState.playerOneVictoryPoints,
            playerTwoVictoryPoints: trackerState.playerTwoVictoryPoints
        )
        let key = BattleRoundChecklist.storageKey(round: trackerState.battleRound)
        var steps = trackerState.completedRoundChecklistSteps[key] ?? []
        let before = steps
        for step in suggested {
            steps.insert(step.rawValue)
        }
        guard steps != before else { return }
        trackerState.completedRoundChecklistSteps[key] = steps
        persist()
    }

    func setBattleRound(_ round: Int) {
        let previousRound = trackerState.battleRound
        trackerState.battleRound = playContext.playEngine.clampBattleRound(round)
        trackerEngine.afterBattleRoundChange(trackerState: &trackerState)
        persist()
        recordRoundAdvanced(previousRound: previousRound)
    }

    func toggleActivePlayer() {
        completeActivation()
    }

    func completeActivation() {
        trackerState.activePlayerIsOne.toggle()
        persist()
        refreshAbilities()
        recordActivePlayerChanged()
    }

    func setActivePlayer(isOne: Bool) {
        guard trackerState.activePlayerIsOne != isOne else { return }
        trackerState.activePlayerIsOne = isOne
        persist()
        refreshAbilities()
        recordActivePlayerChanged()
    }

    func toggleShowAll() {
        trackerState.showAllAbilities.toggle()
        persist()
        refreshAbilities()
    }

    func advancePhase() {
        let phases = playContext.playEngine.mainPhases()
        guard let index = phases.firstIndex(of: trackerState.currentPhase), index < phases.count - 1 else { return }
        setPhase(phases[index + 1])
    }

    func markUsed(_ ability: TriggeredAbility) {
        trackerState.usedOncePerBattleAbilityIds.insert(ability.id)
        persist()
        refreshAbilities()
        recordAbilityUsed(ability)
    }

    func isUsed(_ ability: TriggeredAbility) -> Bool {
        trackerState.usedOncePerBattleAbilityIds.contains(ability.id)
    }

    func adjustVictoryPoints(
        playerIsOne: Bool,
        delta: Int,
        reason: MatchVictoryPointsReason = .manual
    ) {
        if playerIsOne {
            trackerState.playerOneVictoryPoints = max(0, trackerState.playerOneVictoryPoints + delta)
        } else {
            trackerState.playerTwoVictoryPoints = max(0, trackerState.playerTwoVictoryPoints + delta)
        }
        persist()
        syncAutoCompletions()
        guard delta != 0 else { return }
        recordVictoryPointsChange(playerIsOne: playerIsOne, delta: delta, reason: reason)
    }

    func setFinalVictoryPoints(playerOne: Int, playerTwo: Int) {
        trackerState.playerOneVictoryPoints = max(0, playerOne)
        trackerState.playerTwoVictoryPoints = max(0, playerTwo)
        persist()
    }
}
