import SwiftUI

/// Nudges new players to check their unit cards for protective keywords (Ward / Invulnerable
/// save) and other modifiers before resolving damage. Tapping opens the Extra rules section.
struct CombatWardReminderHint: View {
    let keyword: String
    let example: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
                Image(systemName: "magnifyingglass.circle.fill")
                    .font(.title3)
                    .foregroundStyle(Color.accentColor)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text(String(localized: "Looking for a \(keyword)?"))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(
                        String(
                            localized: """
                            Check both unit cards for keywords like \(example) and any hit, wound, \
                            or save modifiers, then tap to add them.
                            """
                        )
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.down")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)
            }
            .padding(DesignTokens.Spacing.sm)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.accentColor.opacity(0.1), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm))
            .overlay {
                RoundedRectangle(cornerRadius: DesignTokens.Radius.sm)
                    .strokeBorder(Color.accentColor.opacity(0.3), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("battleTracker.combatResolver.wardReminder")
        .accessibilityHint(String(localized: "Opens extra rules to add Ward and modifiers"))
    }
}
