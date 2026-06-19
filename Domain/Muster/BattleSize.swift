import Foundation

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

    public static let customKey = "custom"

    public static func resolve(game: String, key: String) -> BattleSize? {
        if let custom = parseCustomKey(key, game: game) { return custom }
        return forGame(game).first { $0.id == key }
    }

    public static func storageKey(selectionKey: String, customPoints: Int?) -> String {
        guard selectionKey == customKey, let customPoints, customPoints > 0 else { return selectionKey }
        return "custom:\(customPoints)"
    }

    private static func parseCustomKey(_ key: String, game: String) -> BattleSize? {
        guard key.hasPrefix("custom:") else { return nil }
        let raw = key.dropFirst("custom:".count)
        guard let points = Int(raw), points > 0 else { return nil }
        return BattleSize(id: key, label: "Custom", pointsLimit: points, game: game)
    }

    private static let warhammer40k: [BattleSize] = [
        .init(id: "combat-patrol", label: "Combat Patrol", pointsLimit: 500, game: "40k"),
        .init(id: "incursion", label: "Incursion", pointsLimit: 1000, game: "40k"),
        .init(id: "strike-force", label: "Strike Force", pointsLimit: 2000, game: "40k"),
        .init(id: "onslaught", label: "Onslaught", pointsLimit: 3000, game: "40k"),
    ]
}
