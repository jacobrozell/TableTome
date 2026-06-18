import Foundation

/// Stable identifiers shared across Bench, Muster, and Play. Cross-pillar links
/// MUST flow through these — see `FutureIdeas/UnifiedAppPlan.md` and the catalog
/// key audit.
public struct GameSystemId: Hashable, Sendable, Codable, RawRepresentable {
    public let rawValue: String
    public init(rawValue: String) { self.rawValue = rawValue }
    public init(_ rawValue: String) { self.rawValue = rawValue }

    public static let wh40k11e   = GameSystemId("wh40k-11e")
    public static let wh40k10e   = GameSystemId("wh40k-10e")
    public static let aosSpearhead = GameSystemId("aos-spearhead")
    public static let starcraftTMG = GameSystemId("sc-tmg")
}

/// Canonical key for a catalog unit, joining Muster's points catalog and Play's
/// warscroll IDs. Format: `"<gameSystemId>:<unitSlug>"`.
public struct CatalogUnitKey: Hashable, Sendable, Codable, RawRepresentable {
    public let rawValue: String
    public init(rawValue: String) { self.rawValue = rawValue }
    public init(_ rawValue: String) { self.rawValue = rawValue }

    public init(gameSystem: GameSystemId, unitSlug: String) {
        self.rawValue = "\(gameSystem.rawValue):\(unitSlug)"
    }
}
