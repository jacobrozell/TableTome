import Foundation

public struct AlternatingActivationBattleTrackerEngine: BattleTrackerEngine {
    public let playEngineId: PlayEngineId = .alternatingActivation

    public init() {}

    public func bootstrap(
        trackerState: inout BattleTrackerState,
        matchState: GuidedMatchState,
        playContext: GameSystemPlayContext
    ) {
        guard !playContext.playEngine.mainPhases().contains(trackerState.currentPhase) else { return }
        trackerState.currentPhase = playContext.playEngine.initialPhase()
    }

    public func afterPhaseChange(
        from previous: BattleTurnPhase,
        trackerState: inout BattleTrackerState
    ) {
        trackerState.scPhasePassClaimedByPlayerOne = nil
        if let markerIsOne = trackerState.scFirstPlayerMarkerIsPlayerOne {
            trackerState.activePlayerIsOne = markerIsOne
        }
    }

    public func afterBattleRoundChange(trackerState: inout BattleTrackerState) {
        applyMarkerHolder(to: &trackerState)
    }

    public func passActivation(trackerState: inout BattleTrackerState) {
        if trackerState.scPhasePassClaimedByPlayerOne == nil {
            trackerState.scPhasePassClaimedByPlayerOne = trackerState.activePlayerIsOne
            trackerState.scFirstPlayerMarkerIsPlayerOne = trackerState.activePlayerIsOne
        }
        trackerState.activePlayerIsOne.toggle()
    }

    public func usesRoundChecklistAutoCompletion(playContext: GameSystemPlayContext) -> Bool {
        false
    }

    private func applyMarkerHolder(to trackerState: inout BattleTrackerState) {
        trackerState.scPhasePassClaimedByPlayerOne = nil
        if let markerIsOne = trackerState.scFirstPlayerMarkerIsPlayerOne {
            trackerState.activePlayerIsOne = markerIsOne
        }
    }
}
