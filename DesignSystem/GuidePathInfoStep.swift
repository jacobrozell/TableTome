import SwiftUI

/// Numbered path row without navigation — pairs with a primary CTA below on start-here cards.
struct GuidePathInfoStep: View {
    let number: Int
    let title: String
    let detail: String
    let accessibilityId: String

    var body: some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
            Text("\(number).")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color.accentOnSurface)
                .monospacedDigit()
                .frame(minWidth: 20, alignment: .trailing)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .frame(minHeight: DesignTokens.minTouchTarget, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier(accessibilityId)
    }
}
