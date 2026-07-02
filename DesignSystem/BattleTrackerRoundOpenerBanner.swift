import SwiftUI

struct BattleTrackerRoundOpenerBanner: View {
    let round: Int
    let nextStepTitle: String
    let onJumpToChecklist: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
                Image(systemName: "flag.checkered.2.crossed")
                    .font(.title3)
                    .foregroundStyle(Color.accentColor)
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text(String(localized: "Round \(round) setup"))
                        .font(.subheadline.weight(.semibold))
                    Text(
                        String(
                            localized: """
                            Next up: \(nextStepTitle). Two different decks — twist cards from the \
                            battlefield pack (shared), battle tactic cards from each army box (personal).
                            """
                        )
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .minimumTouchTarget()
                .accessibilityLabel(String(localized: "Dismiss"))
            }

            Button(String(localized: "Jump to checklist"), action: onJumpToChecklist)
                .buttonStyle(.borderedProminent)
                .adaptiveControlSize()
                .frame(maxWidth: .infinity)
                .minimumTouchTarget()
                .accessibilityIdentifier("battleTracker.roundOpener.jump")
        }
        .accentHighlightCard()
        .accessibilityIdentifier("battleTracker.roundOpener")
    }
}
