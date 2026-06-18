import SwiftUI

struct CritAutoWoundCoachingHint: View {
    var body: some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(Color.accentColor)
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
        .padding(DesignTokens.Spacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.accentColor.opacity(0.08), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm))
        .accessibilityIdentifier("combatResolver.critAutoWoundHint")
    }
}
