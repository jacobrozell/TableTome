import SwiftUI
import TabletomeDomain

struct BattleTrackerEmptyStateSection: View {
    let showsActivationBar: Bool
    let usesGuidedBattleTracker: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text(String(localized: "Battle tracker isn't available for this army yet."))
                .font(.headline)
            Text(detailText)
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .surfaceCard()
    }

    private var detailText: String {
        if showsActivationBar {
            return String(
                localized: """
                Unit cards and Command Center have full combat detail. Use the Turn tab for activations and \
                scoring below for victory points.
                """
            )
        }
        if usesGuidedBattleTracker {
            return String(
                localized: """
                Ability reminders for this army aren't in Tabletome yet. Use your box unit cards and the \
                official core rules for full detail. Turn tracking, phases, and victory points still work below.
                """
            )
        }
        return String(
            localized: """
            Ability reminders for this army aren't in Tabletome yet. Use the GW Spearhead PDF link on \
            the army picker for full rules. Turn tracking, phases, and victory points still work below.
            """
        )
    }
}
