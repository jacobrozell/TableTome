import SwiftUI
import TabletomeDomain

struct WrongGuideBanner: View {
    let alert: WrongGuideAlert
    let onOpenSuggestedGuide: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title3)
                    .foregroundStyle(.orange)
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text(alert.title)
                        .font(.subheadline.weight(.semibold))
                    Text(alert.message)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(String(localized: "Dismiss"))
            }

            Button(action: onOpenSuggestedGuide) {
                Label(alert.buttonTitle, systemImage: "arrow.right.circle.fill")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget)
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("guide.wrongGuide.openSuggested")
        }
        .accentHighlightCard()
        .accessibilityIdentifier("guide.wrongGuideBanner")
    }
}
