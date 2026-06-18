import Foundation

/// Runtime turn-flow behavior for the battle tracker — keyed by `PlayEngineId`, not `GameSystemId`.
public protocol BattleTrackerEngine: Sendable {
    var playEngineId: PlayEngineId { get }

    func bootstrap(
        trackerState: inout BattleTrackerState,
        matchState: GuidedMatchState,
        playContext: GameSystemPlayContext
    )

    func afterPhaseChange(
        from previous: BattleTurnPhase,
        trackerState: inout BattleTrackerState
    )

    func afterBattleRoundChange(trackerState: inout BattleTrackerState)

    func passActivation(trackerState: inout BattleTrackerState)

    func usesRoundChecklistAutoCompletion(playContext: GameSystemPlayContext) -> Bool
}

public enum BattleTrackerEngineFactory {
    public static func engine(for playContext: GameSystemPlayContext) -> any BattleTrackerEngine {
        switch playContext.playEngine.playEngineId {
        case .alternatingActivation:
            AlternatingActivationBattleTrackerEngine()
        case .phasedRound, .gridSportDrive, .commandCardPool, .heroSkirmish, .rulesOnly:
            PhasedRoundBattleTrackerEngine()
        }
    }
}
