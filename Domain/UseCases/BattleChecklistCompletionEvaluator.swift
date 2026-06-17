import Foundation

public enum BattleChecklistCompletionEvaluator {
    public static func suggestedRoundCompletions(
        round: Int,
        playerOneVictoryPoints: Int,
        playerTwoVictoryPoints: Int
    ) -> Set<BattleRoundChecklistStep> {
        var steps = Set<BattleRoundChecklistStep>()
        if playerOneVictoryPoints != playerTwoVictoryPoints {
            steps.insert(.identifyUnderdog)
        }
        return steps
    }
}
