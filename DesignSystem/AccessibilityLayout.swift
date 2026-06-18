import SwiftUI

extension DynamicTypeSize {
    /// Largest standard size and all accessibility sizes need single-column / wrapped layouts.
    public var needsLayoutAdaptation: Bool {
        if isAccessibilitySize { return true }
        return self >= .xxxLarge
    }
}

struct AdaptiveLineLimit: ViewModifier {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let limit: Int

    func body(content: Content) -> some View {
        if dynamicTypeSize.needsLayoutAdaptation {
            content
        } else {
            content.lineLimit(limit)
        }
    }
}

struct AdaptiveHStack<Content: View>: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    var alignment: VerticalAlignment = .top
    var spacing: CGFloat = DesignTokens.Spacing.md
    @ViewBuilder let content: () -> Content

    var body: some View {
        if dynamicTypeSize.needsLayoutAdaptation {
            VStack(alignment: .leading, spacing: spacing, content: content)
        } else {
            HStack(alignment: alignment, spacing: spacing, content: content)
        }
    }
}

extension View {
    func adaptiveLineLimit(_ limit: Int) -> some View {
        modifier(AdaptiveLineLimit(limit: limit))
    }

    func minimumTouchTarget(alignment: Alignment = .center) -> some View {
        frame(minHeight: DesignTokens.minTouchTarget, alignment: alignment)
    }

    func adaptiveControlSize() -> some View {
        modifier(AdaptiveControlSize())
    }
}

struct AdaptiveControlSize: ViewModifier {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    func body(content: Content) -> some View {
        content.controlSize(dynamicTypeSize.needsLayoutAdaptation ? .regular : .small)
    }
}

/// Horizontal chip/pill row that scrolls at large text sizes instead of clipping.
struct AdaptiveHorizontalChipRow<Content: View>: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    var spacing: CGFloat = DesignTokens.Spacing.xs
    @ViewBuilder let content: () -> Content

    var body: some View {
        Group {
            if dynamicTypeSize.needsLayoutAdaptation {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: spacing, content: content)
                }
            } else {
                HStack(spacing: spacing, content: content)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
