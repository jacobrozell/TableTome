import SwiftUI
import TabletomeDomain

struct MatchVictoryScoreboardSection: View {
    let playerOneName: String
    let playerTwoName: String
    let playerOneArmyLabel: String
    let playerTwoArmyLabel: String
    let playerOneVP: Int
    let playerTwoVP: Int
    let winner: MatchWinner

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var isDraw: Bool {
        winner == .tie
    }

    var body: some View {
        Group {
            if dynamicTypeSize.needsLayoutAdaptation {
                VStack(spacing: DesignTokens.Spacing.md) {
                    playerColumn(isPlayerOne: true)
                    playerColumn(isPlayerOne: false)
                }
            } else {
                HStack(alignment: .top, spacing: DesignTokens.Spacing.md) {
                    playerColumn(isPlayerOne: true)
                    playerColumn(isPlayerOne: false)
                }
            }
        }
    }

    private func playerColumn(isPlayerOne: Bool) -> some View {
        let isWinner = (isPlayerOne && winner == .playerOne) || (!isPlayerOne && winner == .playerTwo)

        return MatchVictoryPlayerColumnSection(
            name: isPlayerOne ? playerOneName : playerTwoName,
            army: isPlayerOne ? playerOneArmyLabel : playerTwoArmyLabel,
            victoryPoints: isPlayerOne ? playerOneVP : playerTwoVP,
            isWinner: isWinner,
            highlightTie: isDraw,
            isPlayerOne: isPlayerOne
        )
    }
}
