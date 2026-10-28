import Foundation
import TabletomeDomain

extension SpearheadBattleViewModel {
    var currentGuideStep: BattleFlowGuideStep? {
        BattleFlowGuide.currentStep(
            matchState: matchState,
            trackerState: trackerState,
            gameSystemId: gameSystemId
        )
    }

    var focusedRoundOpenerStep: BattleRoundChecklistStep? {
        guard playContext.capabilities.showsBattleTacticDecks else { return nil }
        return BattleFlowGuide.nextIncompleteRoundOpenerStep(
            round: trackerState.battleRound,
            completedSteps: trackerState.completedRoundChecklistSteps
        )
    }

    var roundOpenerIsIncomplete: Bool {
        focusedRoundOpenerStep != nil
    }

    var isTurnFlowBlocked: Bool {
        playContext.capabilities.showsBattleTacticDecks && roundOpenerIsIncomplete
    }

    var canAdvancePhase: Bool {
        !isTurnFlowBlocked && nextPhaseTitle != nil
    }

    /// The active player is finishing the first turn of the round, so the next step is a handoff.
    /// The second turn is not in `completedTurnsThisRound` yet, so round-advance stays false until they confirm.
    var endsTurnWithHandoff: Bool {
        guard trackerState.currentPhase == .endOfTurn else { return false }
        let opponent = !trackerState.activePlayerIsOne
        return !trackerState.completedTurnsThisRound.contains(opponent)
    }

    var canPassToNextPlayerThisRound: Bool {
        guard !roundOpenerIsIncomplete else { return false }
        guard trackerState.currentPhase == .endOfTurn else { return false }
        let active = trackerState.activePlayerIsOne
        return !trackerState.completedTurnsThisRound.contains(active)
    }

    var canAdvanceBattleRound: Bool {
        let maxRound = playContext.playEngine.battleRoundCount()
        guard trackerState.battleRound < maxRound else { return false }
        guard trackerState.currentPhase == .endOfTurn else { return false }
        return trackerState.completedTurnsThisRound.count >= 2
    }

    var isBattleComplete: Bool {
        let maxRound = playContext.playEngine.battleRoundCount()
        guard trackerState.battleRound >= maxRound else { return false }
        guard trackerState.currentPhase == .endOfTurn else { return false }
        return trackerState.completedTurnsThisRound.count >= 2
    }

    var nextHandoffPlayerName: String? {
        guard canPassToNextPlayerThisRound else { return nil }
        return trackerState.activePlayerIsOne ? playerTwoName : playerOneName
    }

    var unactedCombatUnitCount: Int {
        guard let army = activeArmy else { return 0 }
        return combatActivationUnits.filter { unit in
            let key = UnitWoundTracker.unitKey(armyId: army.id, unitId: unit.id)
            return !unitHasActed(unitKey: key)
        }.count
    }

    var firstTurnIsPlayerOne: Bool? {
        matchState.firstTurnIsPlayerOne
    }

    var attackerName: String? {
        matchState.attackerIsPlayerOne.map { $0 ? playerOneName : playerTwoName }
    }

    var playerOneArmyLabel: String {
        MatchArmyLabelFormatter.label(for: matchState.playerOne, in: catalog)
    }

    var playerTwoArmyLabel: String {
        MatchArmyLabelFormatter.label(for: matchState.playerTwo, in: catalog)
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

    func setPhase(_ phase: BattleTurnPhase) {
        let previous = trackerState.currentPhase
        trackerState.currentPhase = phase
        if previous != phase {
            trackerEngine.afterPhaseChange(from: previous, trackerState: &trackerState)
            clearReinforcementCallPromptIfLeavingMovement(from: previous, to: phase)
            recordBattleLog(
                kind: .phaseChanged,
                payload: MatchLogEventPayload(
                    round: trackerState.battleRound,
                    phaseId: phase.rawValue,
                    playerIsOne: trackerState.activePlayerIsOne,
                    playerName: activePlayerName
                )
            )
        }
        persist()
    }

    func advancePhase() {
        guard !isTurnFlowBlocked else { return }
        let phases = playContext.playEngine.mainPhases()
        guard let index = phases.firstIndex(of: trackerState.currentPhase),
              index < phases.count - 1 else { return }
        setPhase(phases[index + 1])
    }

    func advanceTurnOrPhase() {
        if isTurnFlowBlocked { return }
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

    func completePhasedRoundTurnPhase(_ phase: BattleTurnPhase) {
        if phase == .endOfTurn {
            trackerState.completedTurnsThisRound.insert(trackerState.activePlayerIsOne)
            if trackerState.completedTurnsThisRound.count < 2 {
                trackerState.activePlayerIsOne.toggle()
                trackerState.currentPhase = playContext.playEngine.turnStartPhase()
                recordBattleLog(
                    kind: .activePlayerChanged,
                    payload: MatchLogEventPayload(
                        round: trackerState.battleRound,
                        phaseId: trackerState.currentPhase.rawValue,
                        playerIsOne: trackerState.activePlayerIsOne,
                        playerName: activePlayerName
                    )
                )
                persist()
            } else {
                persist()
            }
        } else {
            advancePhase()
        }
    }

    func advanceBattleRound() {
        guard canAdvanceBattleRound else { return }
        trackerState.battleRound += 1
        trackerState.completedTurnsThisRound = []
        trackerEngine.afterBattleRoundChange(trackerState: &trackerState)
        recordBattleLog(
            kind: .roundAdvanced,
            payload: MatchLogEventPayload(round: trackerState.battleRound)
        )
        if playContext.capabilities.showsBattleTacticDecks {
            matchState.firstTurnIsPlayerOne = nil
            MatchSetupStore.save(matchState, gameSystemId: gameSystemId)
        }
        persist()
        onMatchStateChange?()
    }

    func setDeploymentStep(_ step: DeploymentChecklistStep, complete: Bool) {
        if complete {
            trackerState.completedDeploymentSteps.insert(step.rawValue)
        } else {
            trackerState.completedDeploymentSteps.remove(step.rawValue)
        }
        persist()
    }

    func resetTracker() {
        trackerState = BattleTrackerState(
            activePlayerIsOne: trackerState.activePlayerIsOne,
            currentPhase: playContext.playEngine.initialPhase()
        )
        persist()
        onMatchStateChange?()
    }

    func setBattleRound(_ round: Int) {
        trackerState.battleRound = playContext.playEngine.clampBattleRound(round)
        trackerState.completedTurnsThisRound = []
        trackerEngine.afterBattleRoundChange(trackerState: &trackerState)
        persist()
        onMatchStateChange?()
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
        if trackerState.battleRound == 1 {
            correctRoundOneFirstTurn(isPlayerOne: isPlayerOne)
        } else {
            matchState.firstTurnIsPlayerOne = isPlayerOne
            trackerState.activePlayerIsOne = isPlayerOne
            MatchSetupStore.save(matchState, gameSystemId: gameSystemId)
            syncAutoCompletions()
        }
        let key = BattleRoundChecklist.storageKey(round: trackerState.battleRound)
        var steps = trackerState.completedRoundChecklistSteps[key] ?? []
        steps.insert(BattleRoundChecklistStep.firstTurnOrPriority.rawValue)
        trackerState.completedRoundChecklistSteps[key] = steps
        persist()
        beginRoundTurnsIfReady()
        onMatchStateChange?()
    }

    func correctRoundOneFirstTurn(isPlayerOne: Bool) {
        guard trackerState.battleRound == 1 else { return }

        let firstTurnChanged = matchState.firstTurnIsPlayerOne != isPlayerOne
        matchState.firstTurnIsPlayerOne = isPlayerOne
        trackerState.activePlayerIsOne = isPlayerOne
        MatchSetupStore.save(matchState, gameSystemId: gameSystemId)
        syncAutoCompletions()

        if firstTurnChanged {
            trackerState.completedTurnsThisRound = []
            let turnStart = playContext.playEngine.turnStartPhase()
            if trackerState.currentPhase != turnStart {
                trackerState.currentPhase = turnStart
            }
        }

        let key = BattleRoundChecklist.storageKey(round: trackerState.battleRound)
        var steps = trackerState.completedRoundChecklistSteps[key] ?? []
        steps.insert(BattleRoundChecklistStep.firstTurnOrPriority.rawValue)
        trackerState.completedRoundChecklistSteps[key] = steps

        persist()
        beginRoundTurnsIfReady()
        onMatchStateChange?()
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
        }
    }

    func completeCurrentGuideStep() {
        guard let step = currentGuideStep else { return }
        switch step.kind {
        case .deployment(let deploymentStep):
            setDeploymentStep(deploymentStep, complete: true)
        case .roundOpener(let openerStep):
            if openerStep == .firstTurnOrPriority, matchState.firstTurnIsPlayerOne == nil {
                return
            }
            setRoundChecklistStep(openerStep, complete: true)
        case .turnPhase(let phase):
            if phase == .endOfTurn, canAdvanceBattleRound {
                advanceBattleRound()
            } else {
                completePhasedRoundTurnPhase(phase)
            }
        case .startNextRound:
            advanceBattleRound()
        case .battleComplete:
            break
        default:
            break
        }
    }

    func recordBattleLog(kind: MatchLogEventKind, payload: MatchLogEventPayload) {
        guard ReleaseSurface.showsMatchHistory else { return }
        MatchLogRecorder.record(gameSystemId: gameSystemId, kind: kind, payload: payload)
    }

    func setFinalVictoryPoints(playerOne: Int, playerTwo: Int) {
        trackerState.playerOneVictoryPoints = max(0, playerOne)
        trackerState.playerTwoVictoryPoints = max(0, playerTwo)
        persist()
    }

    func reloadFromPersistedStores() {
        matchState = MatchSetupStore.load(gameSystemId: gameSystemId)
        trackerState = BattleTrackerStore.load(gameSystemId: gameSystemId)
        syncAutoCompletions()
        syncPlayerNames()
        syncArmies()
    }
}
