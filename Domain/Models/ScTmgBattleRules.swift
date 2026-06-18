import Foundation

public enum ScTmgBattleRules {
    public static let battleRoundCount = 5

    public static let mainPhases: [BattleTurnPhase] = [
        .movement, .assault, .combat, .scoring
    ]

    public static let initialPhase: BattleTurnPhase = .movement

    public static func roundLabel(round: Int) -> String {
        String(localized: "Battle Round \(round) of \(battleRoundCount)")
    }

    public static func clampBattleRound(_ round: Int) -> Int {
        min(battleRoundCount, max(1, round))
    }
}
