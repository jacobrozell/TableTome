import Foundation

/// Combat Patrol (10th Edition) scoring and table-state rules — engine timing lives in `PlayEngineConfig`.
public enum CombatPatrolRules {
    public static let objectiveMarkerIds = ["A", "B", "C", "D"]

    /// Primary scoring begins battle round 2 in most CP missions.
    public static func primaryScoringActive(round: Int) -> Bool {
        round >= 2
    }

    /// Round 5: the player who took the second turn scores primary VP at end of turn, not Command phase.
    public static func scoresPrimaryAtEndOfTurn(round: Int, activePlayerIsFirstTurnPlayer: Bool) -> Bool {
        round == 5 && !activePlayerIsFirstTurnPlayer
    }
}
