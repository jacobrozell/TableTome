import SwiftUI
import UIKit

/// Semantic color tokens for the "Tome & Table" theme.
/// Light/dark values are tuned for ≥ 4.5:1 text contrast. See ongoing/ui-overhaul/01-design-system.md §DS-01.
public enum TTColor {
    // MARK: Surfaces
    public static let canvas = dynamic(light: 0xF6F1E7, dark: 0x0E131D)
    public static let surface = dynamic(light: 0xFFFDF8, dark: 0x161D2B)
    public static let raised = dynamic(light: 0xFFFFFF, dark: 0x1E2738)
    public static let sunken = dynamic(light: 0xECE5D6, dark: 0x0A0E15)
    public static let stroke = dynamic(
        light: 0xDDD3C1,
        dark: 0x2A3346,
        highContrastLight: 0xA89C86,
        highContrastDark: 0x56617C
    )
    public static let strokeStrong = dynamic(light: 0xBFB29A, dark: 0x3D4862)
    public static let scrim = dynamic(light: 0x000000, dark: 0x000000, lightAlpha: 0.35, darkAlpha: 0.55)

    // MARK: Ink
    public static let inkPrimary = dynamic(light: 0x1C1A16, dark: 0xF2ECE0)
    public static let inkSecondary = dynamic(
        light: 0x5A554B,
        dark: 0xB9B2A4,
        highContrastLight: 0x3F3B34,
        highContrastDark: 0xD6D0C3
    )
    public static let inkTertiary = dynamic(light: 0x69645A, dark: 0x9A9486)

    // MARK: Brand
    public static let brand = dynamic(light: 0x9E4B18, dark: 0xE8935A)
    public static let brandFill = dynamic(light: 0xB85C24, dark: 0xE8935A)
    public static let inkOnBrand = dynamic(light: 0xFFFFFF, dark: 0x1A0E06)
    public static let brandSoft = dynamic(light: 0xB85C24, dark: 0xE8935A, lightAlpha: 0.10, darkAlpha: 0.16)
    public static let parchment = dynamic(light: 0xF3E6C9, dark: 0xF3E6C9)

    // MARK: Players
    public static let playerOne = dynamic(light: 0x1E62A8, dark: 0x62AEF5)
    public static let playerOneSoft = dynamic(light: 0x1E62A8, dark: 0x62AEF5, lightAlpha: 0.10, darkAlpha: 0.16)
    public static let playerTwo = dynamic(light: 0x7D5F00, dark: 0xF2C14E)
    public static let playerTwoSoft = dynamic(light: 0x7D5F00, dark: 0xF2C14E, lightAlpha: 0.10, darkAlpha: 0.16)
    public static let inkOnPlayer = dynamic(light: 0xFFFFFF, dark: 0x0E131D)

    // MARK: Status
    public static let success = dynamic(light: 0x176B42, dark: 0x4CC38A)
    public static let warning = dynamic(light: 0xA35200, dark: 0xF59E42)
    public static let danger = dynamic(light: 0xB42318, dark: 0xF06A5F)
    public static let successSoft = dynamic(light: 0x176B42, dark: 0x4CC38A, lightAlpha: 0.10, darkAlpha: 0.16)
    public static let warningSoft = dynamic(light: 0xA35200, dark: 0xF59E42, lightAlpha: 0.10, darkAlpha: 0.16)
    public static let dangerSoft = dynamic(light: 0xB42318, dark: 0xF06A5F, lightAlpha: 0.10, darkAlpha: 0.16)

    /// Player identity color. `isPlayerOne == true` → Azure, else Gold.
    public static func player(_ isPlayerOne: Bool) -> Color { isPlayerOne ? playerOne : playerTwo }
    public static func playerSoft(_ isPlayerOne: Bool) -> Color { isPlayerOne ? playerOneSoft : playerTwoSoft }

    // MARK: Helpers
    private static func dynamic(
        light: UInt32,
        dark: UInt32,
        lightAlpha: CGFloat = 1,
        darkAlpha: CGFloat = 1,
        highContrastLight: UInt32? = nil,
        highContrastDark: UInt32? = nil
    ) -> Color {
        Color(UIColor { traits in
            let isDark = traits.userInterfaceStyle == .dark
            let isHighContrast = traits.accessibilityContrast == .high
            let hex: UInt32
            if isDark {
                hex = (isHighContrast ? highContrastDark : nil) ?? dark
            } else {
                hex = (isHighContrast ? highContrastLight : nil) ?? light
            }
            return UIColor(ttHex: hex, alpha: isDark ? darkAlpha : lightAlpha)
        })
    }
}

extension UIColor {
    convenience init(ttHex hex: UInt32, alpha: CGFloat = 1) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: alpha
        )
    }
}
