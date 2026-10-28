import SwiftUI

public extension DesignTokens {
    /// Comfortable max line length for body content on iPad and landscape.
    static let readableContentMaxWidth: CGFloat = 680
}

private struct ReadableContentWidthModifier: ViewModifier {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    func body(content: Content) -> some View {
        let layoutContext = TabletomeLayout.context(
            horizontalSizeClass: horizontalSizeClass,
            verticalSizeClass: verticalSizeClass
        )
        switch layoutContext {
        case .padPortrait, .padLandscape:
            content
                .frame(maxWidth: DesignTokens.readableContentMaxWidth)
                .frame(maxWidth: .infinity)
        case .phoneLandscape:
            content
                .frame(maxWidth: DesignTokens.readableContentMaxWidthPhoneLandscape)
                .frame(maxWidth: .infinity)
        case .phonePortrait:
            content
        }
    }
}

public extension View {
    /// Centers content in a readable column on iPad and iPhone landscape.
    /// Apply to inner scroll content (e.g. a `VStack` inside `ScrollView`), not to `Form` or `List` —
    /// constraining those containers narrows the scroll hit area to the centered column.
    func readableContentWidth() -> some View {
        modifier(ReadableContentWidthModifier())
    }

    /// Extra bottom margin on scrollable content so it is not hidden behind the tab bar.
    @ViewBuilder
    func tabBarScrollInset(enabled: Bool = true, additionalBottom: CGFloat = 0) -> some View {
        if enabled {
            contentMargins(
                .bottom,
                DesignTokens.tabBarScrollBottomInset + additionalBottom,
                for: .scrollContent
            )
        } else {
            self
        }
    }

    /// Bar material behind status / hub chrome rows, bleeding to the horizontal screen edges.
    @ViewBuilder
    func barChromeBackground(
        horizontalPadding: CGFloat = DesignTokens.Spacing.md,
        verticalPadding: CGFloat = DesignTokens.Spacing.sm
    ) -> some View {
        let chrome = padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget, alignment: .leading)
        if #available(iOS 26.0, *) {
            chrome.background(.bar, ignoresSafeAreaEdges: .horizontal)
        } else {
            chrome
                .background(TTColor.surface.opacity(0.92), ignoresSafeAreaEdges: .horizontal)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(TTColor.stroke)
                        .frame(height: 1)
                }
        }
    }

    /// Breathing room above the phase dock when it is pinned below scroll content.
    func battleTrackerPhaseDockScrollInset() -> some View {
        contentMargins(.bottom, DesignTokens.battleTrackerPhaseDockScrollBottomInset, for: .scrollContent)
    }
}
