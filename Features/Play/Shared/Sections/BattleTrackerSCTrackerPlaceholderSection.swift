import SwiftUI
import TabletomeDomain

struct BattleTrackerSCTrackerPlaceholderSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text(String(localized: "Resolve attacks on the table"))
                .font(.headline)
            Text(
                String(
                    localized: """
                    Use your physical unit cards and Command Center for combat. On the Turn tab, tap Done after each \
                    activation and Pass when you want the First Player Marker for the next phase. Victory points and \
                    turn activations are tracked in the tabs below.
                    """
                )
            )
            .font(.callout)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
        }
        .surfaceCard()
        .accessibilityIdentifier("battleTracker.scPlaceholder")
    }
}
