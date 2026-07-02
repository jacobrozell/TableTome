import SwiftUI
import TabletomeDomain

struct VictoryPointsTotalColumnSection: View {
    let name: String
    let victoryPoints: Int
    let isPlayerOne: Bool
    let scoreLeaderIsPlayerOne: Bool?
    let onAdjust: (Bool, Int, MatchVictoryPointsReason) -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            HStack(spacing: DesignTokens.Spacing.xs) {
                Text(name)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .adaptiveLineLimit(2)
                    .minimumScaleFactor(dynamicTypeSize.needsLayoutAdaptation ? 1 : 0.85)
                if scoreLeaderIsPlayerOne == isPlayerOne {
                    Image(systemName: "crown.fill")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                        .accessibilityLabel(String(localized: "Leading"))
                }
            }

            Text("\(victoryPoints)")
                .font(.title2.bold())
                .monospacedDigit()
                .contentTransition(.numericText())
                .foregroundStyle(scoreLeaderIsPlayerOne == isPlayerOne ? .primary : .secondary)
                .accessibilityLabel(String(localized: "\(victoryPoints) victory points"))

            Stepper(
                String(localized: "Adjust"),
                onIncrement: { onAdjust(isPlayerOne, 1, .manual) },
                onDecrement: { onAdjust(isPlayerOne, -1, .manual) }
            )
            .labelsHidden()
            .accessibilityLabel(String(localized: "\(name), \(victoryPoints) victory points"))
            .accessibilityIdentifier(isPlayerOne ? "battleTracker.vp.playerOne" : "battleTracker.vp.playerTwo")
        }
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
    }
}
