import Foundation

public enum ScTmgFeaturedArmies {
    private static var config: FeaturedArmiesConfig {
        GameSystemRegistry.bundled.featuredArmies(for: .scTmg)!
    }

    public static var armyIds: Set<String> { config.armyIds }
    public static var starterMatchupTitle: String { config.starterMatchupTitle }

    public static var configuration: GuidedMatchFeaturedArmies {
        GuidedMatchFeaturedArmies(config: config)
    }

    public static func isFeatured(_ armyId: String) -> Bool {
        config.isFeatured(armyId)
    }

    public static func applyStarterMatchup(to state: inout GuidedMatchState) {
        config.applyStarterMatchup(to: &state)
    }
}
