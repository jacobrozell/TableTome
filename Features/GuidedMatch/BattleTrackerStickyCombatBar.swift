import SwiftUI

struct BattleTrackerStickyCombatBar: View {
    let attackerName: String
    let defenderName: String
    let phaseTitle: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: DesignTokens.Spacing.sm) {
                Image(systemName: "dice.fill")
                    .font(.headline)
                VStack(alignment: .leading, spacing: 2) {
                    Text(String(localized: "Resolve Combat"))
                        .font(.subheadline.weight(.semibold))
                    Text("\(attackerName) → \(defenderName)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
                Text(phaseTitle)
                    .font(.caption2.weight(.semibold))
                    .padding(.horizontal, DesignTokens.Spacing.sm)
                    .padding(.vertical, DesignTokens.Spacing.xs)
                    .background(Color.accentColor.opacity(0.15), in: Capsule())
                    .foregroundStyle(Color.accentColor)
                Image(systemName: "chevron.up")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, DesignTokens.Spacing.md)
            .padding(.vertical, DesignTokens.Spacing.sm)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
            .overlay {
                RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                    .strokeBorder(Color.accentColor.opacity(0.25), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.bottom, DesignTokens.Spacing.sm)
        .accessibilityIdentifier("battleTracker.stickyCombatBar")
        .accessibilityLabel(String(localized: "Resolve combat for \(attackerName) attacking \(defenderName)"))
    }
}
