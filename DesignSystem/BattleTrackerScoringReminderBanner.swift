import SwiftUI
import TabletomeDomain

struct BattleTrackerScoringReminderBanner: View {
    let playerName: String
    var gameSystemId: GameSystemId = .default
    let onJumpToScoring: () -> Void
    let onDismiss: () -> Void

    private var playContext: GameSystemPlayContext {
        GameSystemPlayContext.context(for: gameSystemId)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
                Image(systemName: "star.circle.fill")
                    .font(.title3)
                    .foregroundStyle(Color.accentColor)
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text(String(localized: "Score \(playerName)'s turn"))
                        .font(.subheadline.weight(.semibold))
                    Text(scoringDetail)
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

            Button(String(localized: "Jump to scoring"), action: onJumpToScoring)
                .buttonStyle(.borderedProminent)
                .adaptiveControlSize()
                .frame(maxWidth: .infinity)
                .minimumTouchTarget()
                .accessibilityIdentifier("battleTracker.scoringReminder.jump")
        }
        .accentHighlightCard()
        .accessibilityIdentifier("battleTracker.scoringReminder")
    }

    private var scoringDetail: String {
        if playContext.capabilities.showsActivationBar {
            String(
                localized: "Add victory points for Supply held within 3\" of objectives, then advance the battle round."
            )
        } else if playContext.capabilities.resolvesWh40kRules {
            String(
                localized: "Add victory points for primary and secondary objectives before passing the phone."
            )
        } else {
            String(
                localized: """
                Add victory points for objectives and completed battle tactics. Cards used as commands cannot also score their tactic.
                """
            )
        }
    }
}
