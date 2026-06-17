import Foundation

public enum RealmSide: String, CaseIterable, Sendable, Identifiable {
    case aqshy
    case ghyran

    public var id: String { rawValue }

    public var name: String {
        switch self {
        case .aqshy: String(localized: "Aqshy")
        case .ghyran: String(localized: "Ghyran")
        }
    }

    public var elementLabel: String {
        switch self {
        case .aqshy: String(localized: "Fire")
        case .ghyran: String(localized: "Jade")
        }
    }

    public var resultDescription: String {
        String(localized: "\(name) — \(elementLabel) side")
    }
}
