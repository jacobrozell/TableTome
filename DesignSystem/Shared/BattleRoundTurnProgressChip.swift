import SwiftUI

/// Compact “Round N · 1/2 turns” indicator for phased-round battle trackers.
struct BattleRoundTurnProgressChip: View {
    let round: Int
    let playerOneName: String
    let playerTwoName: String
    let completedTurnPlayerOnes: Set<Bool>
    let activePlayerIsOne: Bool

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            Label {
                Text(String(localized: "Round \(round)"))
                    .font(.caption.weight(.semibold))
            } icon: {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.caption.weight(.semibold))
            }
            .foregroundStyle(.secondary)

            ProgressBadge(done: completedTurnPlayerOnes.count, total: 2)

            HStack(spacing: DesignTokens.Spacing.xs) {
                turnDot(
                    name: playerOneName,
                    isComplete: completedTurnPlayerOnes.contains(true),
                    isActive: activePlayerIsOne
                )
                turnDot(
                    name: playerTwoName,
                    isComplete: completedTurnPlayerOnes.contains(false),
                    isActive: !activePlayerIsOne
                )
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.sm)
        .padding(.vertical, DesignTokens.Spacing.xs)
        .background(Color(.tertiarySystemFill), in: Capsule())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilitySummary)
    }

    private var accessibilitySummary: String {
        String(
            localized: """
            Round \(round), \(completedTurnPlayerOnes.count) of 2 turns complete. \
            Active player: \(activePlayerIsOne ? playerOneName : playerTwoName).
            """
        )
    }

    private func turnDot(name: String, isComplete: Bool, isActive: Bool) -> some View {
        HStack(spacing: 3) {
            Image(systemName: isComplete ? "checkmark.circle.fill" : (isActive ? "circle.inset.filled" : "circle"))
                .font(.caption2.weight(.semibold))
                .foregroundStyle(isComplete ? .green : (isActive ? Color.accentColor : Color.secondary.opacity(0.5)))
            Text(name)
                .font(.caption2.weight(isActive ? .semibold : .regular))
                .foregroundStyle(isActive ? .primary : .secondary)
                .lineLimit(1)
        }
        .accessibilityHidden(true)
    }
}
