import Foundation

/// Combat Patrol (10th Edition) — five rounds, Command-first turn flow.
public enum CombatPatrolBattleRules {
    public static let battleRoundCount = 5

    /// In-battle phases only — deployment is handled in Guided Match setup.
    public static let mainPhases: [BattleTurnPhase] = [
        .command, .movement, .shooting, .charge, .combat, .endOfTurn
    ]

    public static let initialPhase: BattleTurnPhase = .command

    public static let objectiveMarkerIds = ["A", "B", "C", "D"]

    public static func roundLabel(round: Int) -> String {
        String(localized: "Battle Round \(round) of \(battleRoundCount)")
    }

    public static func clampBattleRound(_ round: Int) -> Int {
        min(battleRoundCount, max(1, round))
    }

    /// Primary scoring begins battle round 2 in most CP missions.
    public static func primaryScoringActive(round: Int) -> Bool {
        round >= 2
    }

    /// Round 5: the player who took the second turn scores primary VP at end of turn, not Command phase.
    public static func scoresPrimaryAtEndOfTurn(round: Int, activePlayerIsFirstTurnPlayer: Bool) -> Bool {
        round == battleRoundCount && !activePlayerIsFirstTurnPlayer
    }
}
