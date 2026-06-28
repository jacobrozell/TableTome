import Foundation

public struct PhasedRoundBattleTrackerEngine: BattleTrackerEngine {
    public let playEngineId: PlayEngineId = .phasedRound

    public init() {}

    public func bootstrap(
        trackerState: inout BattleTrackerState,
        matchState: GuidedMatchState,
        playContext: GameSystemPlayContext
    ) {
        guard playContext.capabilities.usesPatrolFormatRules,
              let firstTurnIsPlayerOne = matchState.firstTurnIsPlayerOne,
              trackerState.battleRound == 1,
              trackerState.currentPhase == playContext.playEngine.initialPhase(),
              trackerState.playerOneVictoryPoints == 0,
              trackerState.playerTwoVictoryPoints == 0 else {
            return
        }
        trackerState.activePlayerIsOne = firstTurnIsPlayerOne
    }

    public func afterPhaseChange(
        from previous: BattleTurnPhase,
        trackerState: inout BattleTrackerState
    ) {}

    public func afterBattleRoundChange(trackerState: inout BattleTrackerState) {}

    public func passActivation(trackerState: inout BattleTrackerState) {
        trackerState.activePlayerIsOne.toggle()
    }

    public func usesRoundChecklistAutoCompletion(playContext: GameSystemPlayContext) -> Bool {
        playContext.capabilities.showsRoundChecklist
    }
}
