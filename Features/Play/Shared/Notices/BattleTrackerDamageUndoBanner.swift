import SwiftUI

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
        .background(Color.accentColor.opacity(0.1), in: CardSurface.shape(radius: DesignTokens.Radius.nested))
        .accessibilityIdentifier("battleTracker.damageUndo")
    }
}
