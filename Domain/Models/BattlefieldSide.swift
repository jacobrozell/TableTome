import Foundation

public enum BattlefieldSide: String, CaseIterable, Sendable, Identifiable {
    case aqshy
    case ghyran
    case ossia
    case dolorum
    case ashenBastion
    case shatteredCrossroads

    public var id: String { rawValue }

    public var battlefield: SpearheadBattlefield {
        switch self {
        case .aqshy, .ghyran: .fireAndJade
        case .ossia, .dolorum: .sandAndBone
        case .ashenBastion, .shatteredCrossroads: .cityOfAsh
        }
    }

    public var name: String {
        switch self {
        case .aqshy: String(localized: "Aqshy")
        case .ghyran: String(localized: "Ghyran")
        case .ossia: String(localized: "Ossia")
        case .dolorum: String(localized: "Dolorum")
        case .ashenBastion: String(localized: "Ashen Bastion")
        case .shatteredCrossroads: String(localized: "Shattered Crossroads")
        }
    }

    public var paletteLabel: String {
        switch self {
        case .aqshy: String(localized: "Fire")
        case .ghyran: String(localized: "Jade")
        case .ossia: String(localized: "Sand")
        case .dolorum: String(localized: "Bone")
        case .ashenBastion: String(localized: "Bastion")
        case .shatteredCrossroads: String(localized: "Crossroads")
        }
    }

    public var resultDescription: String {
        switch self {
        case .ashenBastion, .shatteredCrossroads:
            name
        default:
            String(localized: "\(name) — \(paletteLabel) side")
        }
    }

    public static func sides(for battlefield: SpearheadBattlefield) -> [BattlefieldSide] {
        switch battlefield {
        case .fireAndJade: [.aqshy, .ghyran]
        case .sandAndBone: [.ossia, .dolorum]
        case .cityOfAsh: [.ashenBastion, .shatteredCrossroads]
        }
    }
}
