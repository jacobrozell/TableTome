import SwiftUI

struct MatchVictoryInteractiveActionsSection: View {
    let onAdjustScore: () -> Void
    let onRematch: () -> Void
    let onDone: () -> Void

    var body: some View {
        Button(String(localized: "Adjust score")) {
            onAdjustScore()
        }
        .font(.callout.weight(.semibold))
        .frame(minHeight: DesignTokens.minTouchTarget)
        .accessibilityIdentifier("matchVictory.adjustScore")

        HStack(spacing: DesignTokens.Spacing.md) {
            Button(String(localized: "Rematch")) {
                onRematch()
            }
            .buttonStyle(.bordered)
            .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget)
            .accessibilityIdentifier("matchVictory.rematch")

            PrimaryButton(
                title: String(localized: "Done"),
                accessibilityId: "matchVictory.done"
            ) {
                onDone()
            }
        }
    }
}
