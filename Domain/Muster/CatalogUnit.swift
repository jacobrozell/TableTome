import Foundation

public struct CatalogUnit: Identifiable, Hashable, Codable, Sendable {
    public let id: String
    public let name: String
    public let faction: String
    public let game: String
    public let category: String
    public let basePoints: Int
    public let modelCount: Int
    public let keywords: [String]
    public let aliases: [String]
    public let boxSources: [String]
    public let edition: String
    public let pointsKey: String
}

public struct FactionCatalogFile: Codable, Sendable {
    public let faction: String
    public let game: String
    public let units: [CatalogUnit]
}

public struct UnitCatalogManifest: Codable, Sendable {
    public let version: String
    public let generatedAt: String
    public let attribution: String
    public let games: [String]
}

public struct UnitCatalogIndex: Codable, Sendable {
    /// "40k:Grey Knights" → "40k/grey-knights.json"
    public let factions: [String: String]
}
