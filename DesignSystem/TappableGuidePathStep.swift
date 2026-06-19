import SwiftUI

/// Numbered guide path row that navigates when tapped — used on game guide start-here cards.
struct TappableGuidePathStep<D: Hashable>: View {
    let number: Int
    let title: String
    let detail: String
    let destination: D
    let accessibilityId: String

    var body: some View {
        NavigationLink(value: destination) {
            HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
                HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
                    Text("\(number).")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color.accentColor)
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
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
                    .accessibilityHidden(true)
            }
            .frame(minHeight: DesignTokens.minTouchTarget, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(accessibilityId)
    }
}
