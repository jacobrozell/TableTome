import SwiftUI

/// Semantic tone for tinted cards, badges, and buttons.
public enum TTTone: Equatable {
    case brand
    case playerOne
    case playerTwo
    case success
    case warning
    case danger
    case neutral

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

    public var fill: Color {
        switch self {
        case .brand: TTColor.brandFill
        case .playerOne: TTColor.playerOne
        case .playerTwo: TTColor.playerTwo
        case .success: TTColor.success
        case .warning: TTColor.warning
        case .danger: TTColor.danger
        case .neutral: TTColor.sunken
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
