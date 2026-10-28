import SwiftUI

/// Dismissible coach card after the collection intro — guides the first add flow.
/// Uses the same brand card as `TTNotice`. The notice component cannot host a
/// numbered list or the existing dismiss identifier, so the card is composed here.
struct CollectionFirstStepsCoach: View {
    let hasArmies: Bool
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
                Image(systemName: "figure.walk")
                    .foregroundStyle(TTColor.brand)
                    .accessibilityHidden(true)
                Text(String(localized: "First steps"))
                    .font(TTFont.headline)
                    .foregroundStyle(TTColor.inkPrimary)
                Spacer(minLength: 0)
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(String(localized: "Dismiss"))
                .accessibilityIdentifier("collectionFirstStepsDismiss")
            }

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    Text("\(index + 1). \(step)")
                        .font(TTFont.callout)
                        .foregroundStyle(TTColor.inkSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .accentHighlightCard(tone: .brand)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("collection.firstStepsCoach")
    }

    private var steps: [String] {
        if hasArmies {
            return [
                String(localized: "Open an army and tap Add Unit."),
                String(localized: "Name what's on your sprue."),
                String(localized: "Swipe right to mark painting progress.")
            ]
        }
        return [
            String(localized: "Add an army and pick your faction."),
            String(localized: "Name the units on your sprue."),
            String(localized: "Load sample data from Settings to explore.")
        ]
    }
}
