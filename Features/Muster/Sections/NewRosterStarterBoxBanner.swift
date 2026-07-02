import SwiftUI
import TabletomeDomain

struct NewRosterStarterBoxBanner: View {
    let guidance: NewRosterPrefillResolver.StarterBoxGuidance
    let onOpenGuidedMatch: (String) -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Label(String(localized: "Starter box player?"), systemImage: "flag.checkered")
                .font(.headline)
                .foregroundStyle(Color.accentOnSurface)

            Text(guidance.message)
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: DesignTokens.Spacing.sm) {
                Button(guidance.buttonTitle) {
                    onOpenGuidedMatch(guidance.gameSystemId)
                }
                .buttonStyle(.borderedProminent)
                .frame(minHeight: DesignTokens.minTouchTarget)
                .accessibilityIdentifier("musterNewRoster.openGuidedMatch")

                Button(String(localized: "Build a list anyway")) {
                    onDismiss()
                }
                .buttonStyle(.bordered)
                .frame(minHeight: DesignTokens.minTouchTarget)
                .accessibilityIdentifier("musterNewRoster.dismissStarterBanner")
            }
        }
        .accentHighlightCard()
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("musterNewRoster.starterBoxBanner")
    }
}
