import SwiftUI

struct ArmyDetailBatchActionBar: View {
    let isEditing: Bool
    let selectionCount: Int
    let onAdvance: () -> Void
    let onDelete: () -> Void

    var body: some View {
        if isEditing, selectionCount > 0 {
            HStack(spacing: DesignTokens.Spacing.sm) {
                Text(String(localized: "\(selectionCount) selected"))
                    .font(TTFont.subheadline)
                    .foregroundStyle(TTColor.inkSecondary)
                Spacer(minLength: DesignTokens.Spacing.sm)
                Button(String(localized: "Advance")) { onAdvance() }
                    .buttonStyle(TTSecondaryButtonStyle(fullWidth: false))
                    .accessibilityHint(String(localized: "Moves the selected units to the next painting stage"))
                    .accessibilityIdentifier("army.batch.advance")
                Button(String(localized: "Delete"), role: .destructive) { onDelete() }
                    .buttonStyle(TTDestructiveButtonStyle(fullWidth: false))
                    .accessibilityHint(String(localized: "Removes the selected units"))
                    .accessibilityIdentifier("army.batch.delete")
            }
            .barChromeBackground()
        }
    }
}
