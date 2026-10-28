import SwiftUI

public enum TTElevation {
    case flat
    case card
    case raised

    var shadowColor: Color { .black.opacity(self == .flat ? 0 : (self == .card ? 0.05 : 0.10)) }
    var shadowRadius: CGFloat { self == .flat ? 0 : (self == .card ? 6 : 14) }
    var shadowY: CGFloat { self == .flat ? 0 : (self == .card ? 2 : 6) }
}

public extension View {
    /// Light mode gets a soft shadow; dark mode relies on surface tone + stroke (shadows are invisible on navy).
    func ttElevation(_ level: TTElevation) -> some View {
        modifier(TTElevationModifier(level: level))
    }
}

private struct TTElevationModifier: ViewModifier {
    let level: TTElevation
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content.shadow(
            color: colorScheme == .dark ? .clear : level.shadowColor,
            radius: level.shadowRadius,
            y: level.shadowY
        )
    }
}
