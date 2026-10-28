import SwiftUI

/// Palette mirrors `TTColor` and must be kept in sync. Dark values are the hero.
enum Tokens {
    struct Palette {
        let bg, bg2, surface, surface2, line, ink, inkDim, inkFaint: String
        let gold, goldBright, blood, crestText, chipOnText, err: String
    }

    static let dark = Palette(
        bg: "#0e131d", bg2: "#0a0e15", surface: "#161d2b", surface2: "#1e2738",
        line: "#2a3346", ink: "#f2ece0", inkDim: "#b9b2a4", inkFaint: "#9a9486",
        gold: "#e8935a", goldBright: "#f0a878", blood: "#f06a5f",
        crestText: "#1a0e06", chipOnText: "#1a0e06", err: "#f06a5f")

    static let light = Palette(
        bg: "#f6f1e7", bg2: "#ece5d6", surface: "#fffdf8", surface2: "#ffffff",
        line: "#ddd3c1", ink: "#1c1a16", inkDim: "#5a554b", inkFaint: "#69645a",
        gold: "#9e4b18", goldBright: "#b85c24", blood: "#b42318",
        crestText: "#ffffff", chipOnText: "#ffffff", err: "#b42318")

    static func palette(for scheme: ColorScheme) -> Palette {
        scheme == .dark ? dark : light
    }
}

extension EnvironmentValues {
    /// Convenience accessor for the active palette.
    var palette: Tokens.Palette {
        Tokens.palette(for: colorScheme)
    }
}
