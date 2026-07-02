import SwiftUI
import TabletomeDomain

struct VictoryPointsTurnPlayerRowSection: View {
    let name: String
    let value: Int
    let round: Int
    let isPlayerOne: Bool
    let isComplete: Bool
    let isActive: Bool
    let onSetRoundVictoryPoints: (Int, Bool, Int) -> Void

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            Image(systemName: isComplete ? "checkmark.circle.fill" : (isActive ? "circle.inset.filled" : "circle"))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(isComplete ? .green : (isActive ? Color.accentColor : Color.secondary.opacity(0.35)))
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.caption.weight(isActive ? .semibold : .regular))
                    .foregroundStyle(isActive ? .primary : .secondary)
                    .lineLimit(1)
                if isActive {
                    Text(String(localized: "Scoring this turn"))
                        .font(.caption2)
                        .foregroundStyle(Color.accentColor)
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

            Text("\(value)")
                .font(.body.bold())
                .monospacedDigit()
                .contentTransition(.numericText())
                .frame(minWidth: 28, alignment: .trailing)

            Stepper(
                String(localized: "Adjust \(name), round \(round)"),
                onIncrement: { onSetRoundVictoryPoints(round, isPlayerOne, value + 1) },
                onDecrement: { onSetRoundVictoryPoints(round, isPlayerOne, max(0, value - 1)) }
            )
            .labelsHidden()
            .accessibilityLabel(String(localized: "\(name), round \(round) turn, \(value) victory points"))
        }
        .padding(.vertical, 2)
        .opacity(isComplete ? 0.88 : 1)
    }
}
