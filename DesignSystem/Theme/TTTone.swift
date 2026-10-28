import SwiftUI

/// Semantic tone for tinted cards, badges, and buttons.
public enum TTTone: Equatable, Sendable {
    case neutral, brand, playerOne, playerTwo, success, warning, danger

    public static func player(_ isPlayerOne: Bool) -> TTTone {
        isPlayerOne ? .playerOne : .playerTwo
    }

    public var foreground: Color {
        switch self {
        case .brand: TTColor.brand
        case .playerOne: TTColor.playerOne
        case .playerTwo: TTColor.playerTwo
        case .success: TTColor.success
        case .warning: TTColor.warning
        case .danger: TTColor.danger
        case .neutral: TTColor.inkSecondary
        }
    }

    public var fill: Color { solid }

    public var solid: Color {
        switch self {
        case .brand: TTColor.brandFill
        case .playerOne: TTColor.playerOne
        case .playerTwo: TTColor.playerTwo
        case .success: TTColor.success
        case .warning: TTColor.warning
        case .danger: TTColor.danger
        case .neutral: TTColor.inkTertiary
        }
    }

    public var onSolid: Color {
        switch self {
        case .brand: TTColor.inkOnBrand
        case .playerOne, .playerTwo: TTColor.inkOnPlayer
        case .success, .warning, .danger, .neutral: TTColor.inkOnPlayer
        }
    }

    public var soft: Color {
        switch self {
        case .brand: TTColor.brandSoft
        case .playerOne: TTColor.playerOneSoft
        case .playerTwo: TTColor.playerTwoSoft
        case .success: TTColor.successSoft
        case .warning: TTColor.warningSoft
        case .danger: TTColor.dangerSoft
        case .neutral: TTColor.sunken
        }
    }
}
