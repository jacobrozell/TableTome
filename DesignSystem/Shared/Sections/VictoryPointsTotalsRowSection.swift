import SwiftUI
import TabletomeDomain

struct VictoryPointsTotalsRowSection: View {
    let playerOneName: String
    let playerTwoName: String
    let playerOneVP: Int
    let playerTwoVP: Int
    let scoreLeaderIsPlayerOne: Bool?
    let onAdjust: (Bool, Int, MatchVictoryPointsReason) -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Group {
            if dynamicTypeSize.needsLayoutAdaptation {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                    totalColumn(name: playerOneName, vp: playerOneVP, isPlayerOne: true)
                    Divider()
                    totalColumn(name: playerTwoName, vp: playerTwoVP, isPlayerOne: false)
                }
            } else {
                HStack(alignment: .top, spacing: DesignTokens.Spacing.md) {
                    totalColumn(name: playerOneName, vp: playerOneVP, isPlayerOne: true)
                    Divider()
                    totalColumn(name: playerTwoName, vp: playerTwoVP, isPlayerOne: false)
                }
            }
        }
    }

    private func totalColumn(name: String, vp: Int, isPlayerOne: Bool) -> some View {
        VictoryPointsTotalColumnSection(
            name: name,
            victoryPoints: vp,
            isPlayerOne: isPlayerOne,
            scoreLeaderIsPlayerOne: scoreLeaderIsPlayerOne,
            onAdjust: onAdjust
        )
    }
}
