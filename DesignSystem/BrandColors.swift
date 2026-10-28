import SwiftUI

extension Color {
    /// Accent-colored text and icons on white or card surfaces. The fill accent is lighter;
    /// this variant keeps WCAG-friendly contrast for labels and links.
    /// Legacy alias. Prefer `TTColor.brand` in new code.
    static var accentOnSurface: Color { TTColor.brand }
}

extension View {
    /// Label content for `.borderedProminent` buttons. Dark-mode `AccentOnSurface` matches the accent
    /// fill, so hierarchical SF Symbols can disappear without an explicit contrast color.
    func prominentButtonLabelStyle() -> some View {
        symbolRenderingMode(.monochrome)
            .foregroundStyle(.white)
    }
}
