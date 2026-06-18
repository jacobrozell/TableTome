import Foundation

/// Canonical key for a catalog unit, joining Muster's points catalog and Play's
/// warscroll IDs. Format: `"<gameSystemId>:<unitSlug>"`.
/// See `FutureIdeas/CatalogKeyAudit.md` and `Domain/Registry/GameSystemId.swift`.
public struct CatalogUnitKey: Hashable, Sendable, Codable, RawRepresentable {
    public let rawValue: String
    public init(rawValue: String) { self.rawValue = rawValue }
    public init(_ rawValue: String) { self.rawValue = rawValue }

    public init(gameSystem: GameSystemId, unitSlug: String) {
        self.rawValue = "\(gameSystem.rawValue):\(unitSlug)"
    }
}
