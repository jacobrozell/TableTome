import Foundation

public enum MatchWinnerResolver: Sendable {
    public static func resolve(playerOneVP: Int, playerTwoVP: Int) -> MatchWinner {
        if playerOneVP > playerTwoVP {
            return .playerOne
        }
        if playerTwoVP > playerOneVP {
            return .playerTwo
        }
        return .tie
    }
}
