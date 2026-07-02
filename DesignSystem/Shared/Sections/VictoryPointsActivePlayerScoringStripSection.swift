import SwiftUI
import TabletomeDomain

struct VictoryPointsActivePlayerScoringStripSection: View {
    let activePlayerName: String
    let activePlayerIsOne: Bool
    let scoring: VictoryPointsScoring
    let onQuickAdd: (Bool, Int, MatchVictoryPointsReason) -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Text(String(localized: "Quick add for \(activePlayerName)"))
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            HStack(spacing: DesignTokens.Spacing.sm) {
                quickButton(
                    label: scoring.primaryQuickAddLabel,
                    isPlayerOne: activePlayerIsOne,
                    amount: scoring.primaryQuickAddAmount,
                    reason: .objective
                )
                quickButton(
                    label: scoring.secondaryQuickAddLabel,
                    isPlayerOne: activePlayerIsOne,
                    amount: scoring.secondaryQuickAddAmount,
                    reason: .tactic
                )
            }
        }
        .padding(DesignTokens.Spacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.accentColor.opacity(0.06), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm))
    }

    private func quickButton(
        label: String,
        isPlayerOne: Bool,
        amount: Int,
        reason: MatchVictoryPointsReason
    ) -> some View {
        Button(label) {
            onQuickAdd(isPlayerOne, amount, reason)
        }
        .buttonStyle(.bordered)
        .controlSize(dynamicTypeSize.needsLayoutAdaptation ? .regular : .small)
        .font(.caption.weight(.semibold))
        .minimumTouchTarget(alignment: .leading)
    }
}
