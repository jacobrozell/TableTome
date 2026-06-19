import Foundation
import TabletomeDomain

public struct BattleSize: Identifiable, Hashable, Sendable {
    public let id: String
    public let label: String
    public let pointsLimit: Int
    public let game: String

    public init(id: String, label: String, pointsLimit: Int, game: String) {
        self.id = id
        self.label = label
        self.pointsLimit = pointsLimit
        self.game = game
    }
}

public enum BattleSizes {
    public static func forGame(_ game: String) -> [BattleSize] {
        switch game {
        case "40k": return warhammer40k
        default: return []
        }
    }

    public static func resolve(game: String, key: String) -> BattleSize? {
        forGame(game).first { $0.id == key }
    }

    private static let warhammer40k: [BattleSize] = [
        .init(id: "incursion", label: "Incursion", pointsLimit: 1000, game: "40k"),
        .init(id: "strike-force", label: "Strike Force", pointsLimit: 2000, game: "40k"),
        .init(id: "onslaught", label: "Onslaught", pointsLimit: 3000, game: "40k"),
    ]
}
