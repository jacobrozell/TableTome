import SwiftUI

struct BattleTrackerStickyCombatBar: View {
    let attackerName: String
    let defenderName: String
    let phaseTitle: String
    var defenderWoundsLabel: String?
    let onTap: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Button(action: onTap) {
            Group {
                if dynamicTypeSize.needsLayoutAdaptation {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                        HStack(spacing: DesignTokens.Spacing.sm) {
                            Image(systemName: "dice.fill")
                                .font(.headline)
                            Text(String(localized: "Resolve Combat"))
                                .font(.subheadline.weight(.semibold))
                            Spacer(minLength: 0)
                            Image(systemName: "chevron.up")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.secondary)
                        }
                        Text("\(attackerName) → \(defenderName)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        if let defenderWoundsLabel {
                            Text(defenderWoundsLabel)
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(.secondary)
                        }
                        Text(phaseTitle)
                            .font(.caption2.weight(.semibold))
                            .padding(.horizontal, DesignTokens.Spacing.sm)
                            .padding(.vertical, DesignTokens.Spacing.xs)
                            .background(Color.accentColor.opacity(0.15), in: Capsule())
                            .foregroundStyle(Color.accentOnSurface)
                    }
                } else {
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
                            if let defenderWoundsLabel {
                                Text(defenderWoundsLabel)
                                    .font(.caption2.weight(.medium))
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        Spacer(minLength: 0)
                        Text(phaseTitle)
                            .font(.caption2.weight(.semibold))
                            .padding(.horizontal, DesignTokens.Spacing.sm)
                            .padding(.vertical, DesignTokens.Spacing.xs)
                            .background(Color.accentColor.opacity(0.15), in: Capsule())
                            .foregroundStyle(Color.accentOnSurface)
                        Image(systemName: "chevron.up")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.secondary)
                    }
                }
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

struct BattleTrackerDamageUndoBanner: View {
    let message: String
    let onUndo: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            Image(systemName: "heart.slash.fill")
                .foregroundStyle(Color.accentOnSurface)
            Text(message)
                .font(.caption)
                .foregroundStyle(.primary)
                .lineLimit(2)
            Spacer(minLength: 0)
            Button(String(localized: "Undo"), action: onUndo)
                .font(.caption.weight(.semibold))
                .minimumTouchTarget()
            Button(action: onDismiss) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .minimumTouchTarget()
            .accessibilityLabel(String(localized: "Dismiss"))
        }
        .padding(DesignTokens.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.accentColor.opacity(0.1), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
        .accessibilityIdentifier("battleTracker.damageUndo")
    }
}
