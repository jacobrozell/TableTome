import Foundation

public enum BattleChecklistCompletionEvaluator {
    public static func suggestedRoundCompletions(
        round: Int,
        playerOneVictoryPoints: Int,
        playerTwoVictoryPoints: Int,
        firstTurnIsPlayerOne: Bool? = nil
    ) -> Set<BattleRoundChecklistStep> {
        var steps = Set<BattleRoundChecklistStep>()
        if playerOneVictoryPoints != playerTwoVictoryPoints {
            steps.insert(.identifyUnderdog)
        }
        if firstTurnIsPlayerOne != nil {
            steps.insert(.firstTurnOrPriority)
        }
        return steps
    }
}
