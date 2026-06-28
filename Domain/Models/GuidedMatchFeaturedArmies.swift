import Foundation

public struct GuidedMatchFeaturedArmies: Sendable {
    public let armyIds: Set<String>
    public let starterMatchupTitle: String
    public let starterSetDescription: String
    public let starterSetBadge: String
    private let config: FeaturedArmiesConfig

    public init(config: FeaturedArmiesConfig) {
        self.config = config
        armyIds = config.armyIds
        starterMatchupTitle = config.starterMatchupTitle
        starterSetDescription = config.starterSetDescription
        starterSetBadge = config.starterSetBadge
    }

    public func isFeatured(_ armyId: String) -> Bool {
        config.isFeatured(armyId)
    }

    public func applyStarterMatchup(to state: inout GuidedMatchState) {
        config.applyStarterMatchup(to: &state)
    }

    public static func forGameSystem(_ gameSystemId: GameSystemId) -> GuidedMatchFeaturedArmies? {
        guard let config = GameSystemRegistry.bundled.featuredArmies(for: gameSystemId) else {
            return nil
        }
        return GuidedMatchFeaturedArmies(config: config)
    }

    public static func forGameSystem(_ gameSystemId: String) -> GuidedMatchFeaturedArmies? {
        forGameSystem(GameSystemId(resolving: gameSystemId))
    }

    /// Featured armies for a system, falling back to the default game system when unset.
    public static func resolved(for gameSystemId: GameSystemId) -> GuidedMatchFeaturedArmies {
        forGameSystem(gameSystemId) ?? forGameSystem(.default)!
    }

    public static func resolved(for gameSystemId: String) -> GuidedMatchFeaturedArmies {
        resolved(for: GameSystemId(resolving: gameSystemId))
    }
}
