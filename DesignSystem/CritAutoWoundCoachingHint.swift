import SwiftUI

struct CritAutoWoundCoachingHint: View {
    var body: some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(Color.accentOnSurface)
                .symbolRenderingMode(.hierarchical)
                .accessibilityHidden(true)
            Text(
                String(
                    localized: """
                    Crit (Auto-wound) on a hit roll of 6 skips the wound roll — the defender still rolls saves \
                    (Rend applies). Only mortal damage skips saves.
                    """
                )
            )
            .font(.caption)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accentHighlightCard(radius: DesignTokens.Radius.sm)
        .accessibilityIdentifier("combatResolver.critAutoWoundHint")
    }
}
