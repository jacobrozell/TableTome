import SwiftUI
import TabletomeHobbyData
import TabletomeDomain

struct NewRosterListSectionFooter: View {
    let errorMessage: String?
    let customPointsValidationMessage: String?
    let battleSizeHint: String
    let skipToPlayLabel: String
    let skipToPlayAccessibilityHint: String
    let onSkipToPlay: () -> Void

    var body: some View {
        if let errorMessage {
            FormValidationFooter(message: errorMessage)
        } else if let customPointsValidationMessage {
            FormValidationFooter(message: customPointsValidationMessage)
        } else {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Text(FormHints.uniqueName)
                Text(battleSizeHint)
                Button(skipToPlayLabel) {
                    onSkipToPlay()
                }
                .font(.caption.weight(.semibold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(minHeight: DesignTokens.minTouchTarget, alignment: .leading)
                .accessibilityIdentifier("musterNewRoster.skipToPlay")
                .accessibilityLabel(skipToPlayLabel)
                .accessibilityHint(skipToPlayAccessibilityHint)
            }
        }
    }
}
