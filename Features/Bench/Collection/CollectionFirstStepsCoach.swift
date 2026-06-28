import SwiftUI

/// Dismissible coach card after the collection intro — guides the first add flow.
struct CollectionFirstStepsCoach: View {
    let hasArmies: Bool
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Label(String(localized: "First steps"), systemImage: "figure.walk")
                .font(.headline)
                .foregroundStyle(Color.accentOnSurface)

            Text(message)
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Button(String(localized: "Got it")) { onDismiss() }
                .buttonStyle(.bordered)
                .frame(minHeight: DesignTokens.minTouchTarget)
                .accessibilityIdentifier("collectionFirstStepsDismiss")
        }
        .accentHighlightCard()
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("collection.firstStepsCoach")
    }

    private var message: String {
        if hasArmies {
            return String(
                localized: """
                Open an army and tap Add unit. Name what's on your sprue — try \"Intercessors (5)\" for a \
                five-model squad. Swipe right later to mark painting progress.
                """
            )
        }
        return String(
            localized: """
            Tap New army and pick the faction on your box lid. You can load sample data anytime from Settings \
            if you want to explore first.
            """
        )
    }
}
