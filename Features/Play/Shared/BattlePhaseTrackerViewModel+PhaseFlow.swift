import Foundation
import TabletomeDomain

extension BattlePhaseTrackerViewModel {
    func setPhase(_ phase: BattleTurnPhase) {
        let previous = trackerState.currentPhase
        trackerState.currentPhase = phase
        if previous != phase {
            trackerEngine.afterPhaseChange(from: previous, trackerState: &trackerState)
            clearReinforcementCallPromptIfLeavingMovement(from: previous, to: phase)
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
            playerTwoVictoryPoints: trackerState.playerTwoVictoryPoints,
            firstTurnIsPlayerOne: matchState.firstTurnIsPlayerOne
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
        trackerState.completedTurnsThisRound = []
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
        if playContext.capabilities.showsBattleTacticDecks,
           roundOpenerIsIncomplete,
           focusedRoundOpenerStep == .firstTurnOrPriority {
            if trackerState.battleRound == 1 {
                correctRoundOneFirstTurn(isPlayerOne: isOne)
            } else {
                setRoundFirstTurn(isPlayerOne: isOne)
            }
            return
        }
        if gameSystemId == .aosSpearhead, trackerState.battleRound == 1 {
            trackerState.activePlayerIsOne = isOne
            persist()
            refreshAbilities()
            recordActivePlayerChanged()
            return
        }
        trackerState.activePlayerIsOne = isOne
        if trackerState.battleRound == 1 {
            applyRoundOneFirstTurnChoice(isPlayerOne: isOne)
        }
        persist()
        refreshAbilities()
        recordActivePlayerChanged()
    }

    /// Round 1 Spearhead — fix first turn without End of Turn or consuming a completed turn slot.
    func correctRoundOneFirstTurn(isPlayerOne: Bool) {
        guard trackerState.battleRound == 1 else { return }

        let firstTurnChanged = matchState.firstTurnIsPlayerOne != isPlayerOne
        matchState.firstTurnIsPlayerOne = isPlayerOne
        trackerState.activePlayerIsOne = isPlayerOne
        persistMatchState()
        syncAutoCompletions()

        if firstTurnChanged {
            trackerState.completedTurnsThisRound = []
            let turnStart = playContext.playEngine.turnStartPhase()
            if trackerState.currentPhase != turnStart {
                trackerState.currentPhase = turnStart
            }
        }

        persist()
        refreshAbilities()
    }

    private func applyRoundOneFirstTurnChoice(isPlayerOne: Bool) {
        let firstTurnChanged = matchState.firstTurnIsPlayerOne != isPlayerOne
        matchState.firstTurnIsPlayerOne = isPlayerOne
        persistMatchState()
        guard shouldResetTurnStartAfterFirstTurnCorrection() else { return }
        if firstTurnChanged || trackerState.currentPhase != playContext.playEngine.turnStartPhase() {
            trackerState.currentPhase = playContext.playEngine.turnStartPhase()
            persist()
        }
    }

    private func shouldResetTurnStartAfterFirstTurnCorrection() -> Bool {
        trackerState.battleRound == 1
            && trackerState.completedTurnsThisRound.isEmpty
    }

    var canPassToNextPlayerThisRound: Bool {
        guard !playContext.usesAlternatingActivation else { return false }
        guard !roundOpenerIsIncomplete else { return false }
        guard trackerState.currentPhase == .endOfTurn else { return false }
        let active = trackerState.activePlayerIsOne
        return !trackerState.completedTurnsThisRound.contains(active)
    }

    var canAdvanceBattleRound: Bool {
        let maxRound = playContext.playEngine.battleRoundCount()
        guard trackerState.battleRound < maxRound else { return false }
        let scoringPhase: BattleTurnPhase = playContext.usesAlternatingActivation ? .scoring : .endOfTurn
        guard trackerState.currentPhase == scoringPhase else { return false }
        guard !playContext.usesAlternatingActivation else { return true }
        return trackerState.completedTurnsThisRound.count >= 2
    }

    func advanceBattleRound() {
        guard canAdvanceBattleRound else { return }
        let previousRound = trackerState.battleRound
        let nextRound = trackerState.battleRound + 1
        trackerState.battleRound = playContext.playEngine.clampBattleRound(nextRound)
        trackerState.completedTurnsThisRound = []
        if playContext.capabilities.showsBattleTacticDecks {
            matchState.firstTurnIsPlayerOne = nil
            persistMatchState()
        }
        persist()
        recordRoundAdvanced(previousRound: previousRound)
    }

    /// Primary advance control for phased-round modes (Spearhead, 40k, etc.).
    func advanceTurnOrPhase() {
        if isTurnFlowBlocked { return }
        if playContext.usesAlternatingActivation {
            advancePhase()
            return
        }
        if trackerState.currentPhase == .endOfTurn, canPassToNextPlayerThisRound {
            completePhasedRoundTurnPhase(.endOfTurn)
            return
        }
        if trackerState.currentPhase == .endOfTurn, canAdvanceBattleRound {
            advanceBattleRound()
            return
        }
        advancePhase()
    }

    func toggleShowAll() {
        trackerState.showAllAbilities.toggle()
        persist()
        refreshAbilities()
    }

    func advancePhase() {
        guard !isTurnFlowBlocked else { return }
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
        applyVictoryPointsDelta(
            playerIsOne: playerIsOne,
            delta: delta,
            round: trackerState.battleRound
        )
        persist()
        syncAutoCompletions()
        guard delta != 0 else { return }
        recordVictoryPointsChange(playerIsOne: playerIsOne, delta: delta, reason: reason)
    }

    func setRoundVictoryPoints(playerIsOne: Bool, round: Int, value: Int) {
        let previous = trackerState.victoryPointsByRound[round]?.value(forPlayerOne: playerIsOne) ?? 0
        let clamped = max(0, value)
        guard clamped != previous else { return }
        var entry = trackerState.victoryPointsByRound[round] ?? RoundVictoryPoints()
        entry.setValue(clamped, forPlayerOne: playerIsOne)
        trackerState.victoryPointsByRound[round] = entry
        syncVictoryPointTotalsFromByRound()
        persist()
        syncAutoCompletions()
        recordVictoryPointsChange(
            playerIsOne: playerIsOne,
            delta: clamped - previous,
            reason: .manual
        )
    }

    func setFinalVictoryPoints(playerOne: Int, playerTwo: Int) {
        trackerState.playerOneVictoryPoints = max(0, playerOne)
        trackerState.playerTwoVictoryPoints = max(0, playerTwo)
        persist()
    }

    private func applyVictoryPointsDelta(playerIsOne: Bool, delta: Int, round: Int) {
        guard delta != 0 else { return }
        var entry = trackerState.victoryPointsByRound[round] ?? RoundVictoryPoints()
        entry.add(delta, forPlayerOne: playerIsOne)
        trackerState.victoryPointsByRound[round] = entry
        syncVictoryPointTotalsFromByRound()
    }

    private func syncVictoryPointTotalsFromByRound() {
        trackerState.playerOneVictoryPoints = trackerState.victoryPointsByRound.values.reduce(0) { $0 + $1.playerOne }
        trackerState.playerTwoVictoryPoints = trackerState.victoryPointsByRound.values.reduce(0) { $0 + $1.playerTwo }
    }
}
