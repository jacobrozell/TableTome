import SwiftUI

public extension DesignTokens {
    /// Comfortable max line length for body content on iPad and landscape.
    static let readableContentMaxWidth: CGFloat = 680
}

private struct ReadableContentWidthModifier: ViewModifier {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    func body(content: Content) -> some View {
        if horizontalSizeClass == .regular {
            content
                .frame(maxWidth: DesignTokens.readableContentMaxWidth)
                .frame(maxWidth: .infinity)
        } else {
            content
        }
    }
}

public extension View {
    /// Centers content in a readable column on regular horizontal size class (iPad).
    func readableContentWidth() -> some View {
        modifier(ReadableContentWidthModifier())
    }
}
