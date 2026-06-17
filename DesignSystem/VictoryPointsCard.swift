import SwiftUI

struct VictoryPointsCard: View {
    let playerOneName: String
    let playerTwoName: String
    let playerOneVP: Int
    let playerTwoVP: Int
    let onAdjust: (Bool, Int) -> Void
    let onQuickAdd: (Bool, Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Text(String(localized: "Victory Points"))
                .font(.headline)

            HStack(alignment: .top, spacing: DesignTokens.Spacing.md) {
                vpColumn(name: playerOneName, vp: playerOneVP, isPlayerOne: true)
                Divider()
                vpColumn(name: playerTwoName, vp: playerTwoVP, isPlayerOne: false)
            }

            Text(String(localized: "Quick add (end of turn scoring)"))
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .surfaceCard()
        .accessibilityIdentifier("battleTracker.victoryPoints")
    }

    private func vpColumn(name: String, vp: Int, isPlayerOne: Bool) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text(name)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .minimumScaleFactor(0.85)

            Text("\(vp)")
                .font(.title2.bold())
                .monospacedDigit()
                .contentTransition(.numericText())
                .accessibilityLabel(String(localized: "\(vp) victory points"))

            Stepper(
                String(localized: "Adjust"),
                onIncrement: { onAdjust(isPlayerOne, 1) },
                onDecrement: { onAdjust(isPlayerOne, -1) }
            )
            .labelsHidden()
            .accessibilityLabel(String(localized: "\(name), \(vp) victory points"))
            .accessibilityIdentifier(isPlayerOne ? "battleTracker.vp.playerOne" : "battleTracker.vp.playerTwo")

            HStack(spacing: DesignTokens.Spacing.xs) {
                quickButton(label: String(localized: "+1 obj"), isPlayerOne: isPlayerOne, amount: 1)
                quickButton(label: String(localized: "+1 tactic"), isPlayerOne: isPlayerOne, amount: 1)
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
    }

    private func quickButton(label: String, isPlayerOne: Bool, amount: Int) -> some View {
        Button(label) {
            onQuickAdd(isPlayerOne, amount)
        }
        .buttonStyle(.bordered)
        .controlSize(.small)
        .font(.caption)
        .frame(minHeight: 32)
    }
}
