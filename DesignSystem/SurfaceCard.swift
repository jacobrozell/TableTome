import SwiftUI

private struct SurfaceCardModifier: ViewModifier {
    var padding: CGFloat

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                    .strokeBorder(Color(.separator).opacity(0.4), lineWidth: 0.5)
            )
    }
}

public extension View {
    /// Groups content in the standard raised surface used across tracker and setup cards.
    func surfaceCard(padding: CGFloat = DesignTokens.Spacing.md) -> some View {
        modifier(SurfaceCardModifier(padding: padding))
    }
}

struct ProgressBadge: View {
    let done: Int
    let total: Int

    private var isComplete: Bool { total > 0 && done >= total }

    var body: some View {
        Text("\(done)/\(total)")
            .font(.caption.weight(.semibold))
            .monospacedDigit()
            .padding(.horizontal, DesignTokens.Spacing.sm)
            .padding(.vertical, 3)
            .background(
                isComplete ? Color.green.opacity(0.15) : Color(.tertiarySystemFill),
                in: Capsule()
            )
            .foregroundStyle(isComplete ? Color.green : Color.secondary)
    }
}

struct SectionHeader: View {
    let title: String
    var systemImage: String?

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.xs) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .accessibilityAddTraits(.isHeader)
    }
}
