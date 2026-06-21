import Foundation
import TabletomeDomain

public enum ReleaseSurface {
    /// Unlock gated features for CI, dogfood, and internal builds.
    private static var fullSurfaceEnabled: Bool {
        ProcessInfo.processInfo.arguments.contains("-enable_full_product_surface")
    }

    /// Combat Patrol — separate from full surface until all armies ship and polish is done.
    public static var showsCombatPatrol: Bool {
        ProcessInfo.processInfo.arguments.contains("-enable_combat_patrol")
    }

    /// Game systems shipped in App Store 1.0.0.
    private static let releaseGameSystemIds: Set<String> = [
        GameSystemId.aosSpearhead.rawValue,
        GameSystemId.wh40k11e.rawValue,
    ]

    // MARK: Tabs (1.0.0: Models, Play, Rules, Settings)

    public static var showsBenchTab: Bool { true }
    public static var showsMusterTab: Bool { fullSurfaceEnabled }
    public static var showsPaintsInBench: Bool { fullSurfaceEnabled }
    public static var showsPlayTab: Bool { true }
    public static var showsRulesTab: Bool { true }

    // MARK: Cross-pillar links

    public static var showsPlayFromRoster: Bool { fullSurfaceEnabled }
    public static var showsPaintStatusInMatch: Bool { showsPaintsInBench }

    // MARK: Play features

    public static var shows40kEditions: Bool { true }
    public static var showsRollEvaluator: Bool { true }
    public static var showsRulesAssistant: Bool { fullSurfaceEnabled }
    public static var showsMatchHistory: Bool { true }

    // MARK: Game systems

    public static func isGameSystemIdVisible(
        _ gameSystemId: String,
        registry: GameSystemRegistry = .bundled
    ) -> Bool {
        if gameSystemId == GameSystemId.wh40k10eCp.rawValue {
            return showsCombatPatrol
        }
        if fullSurfaceEnabled {
            if let capabilities = registry.capabilities(for: gameSystemId) {
                if capabilities.requiresFullSurfaceFlag {
                    return true
                }
                if capabilities.homeRowVisible {
                    return true
                }
            }
            switch gameSystemId {
            case "wh40k-10e":
                return true
            default:
                return true
            }
        }
        return releaseGameSystemIds.contains(gameSystemId)
    }

    public static func showsNewEditionBadge(
        for gameSystemId: GameSystemId,
        registry: GameSystemRegistry = .bundled
    ) -> Bool {
        showsNewEditionBadge(for: gameSystemId.rawValue, registry: registry)
    }

    public static func showsNewEditionBadge(
        for gameSystemId: String,
        registry: GameSystemRegistry = .bundled
    ) -> Bool {
        registry.capabilities(for: gameSystemId)?.showsNewEditionBadge == true
    }

    public static func showsGuidedMatch(
        for gameSystemId: GameSystemId,
        registry: GameSystemRegistry = .bundled
    ) -> Bool {
        showsGuidedMatch(for: gameSystemId.rawValue, registry: registry)
    }

    public static func showsGuidedMatch(
        for gameSystemId: String,
        registry: GameSystemRegistry = .bundled
    ) -> Bool {
        guard isGameSystemIdVisible(gameSystemId, registry: registry) else { return false }
        return registry.capabilities(for: gameSystemId)?.showsGuidedMatch == true
    }

    public static func showsCombatResolver(
        for gameSystemId: GameSystemId,
        registry: GameSystemRegistry = .bundled
    ) -> Bool {
        showsCombatResolver(for: gameSystemId.rawValue, registry: registry)
    }

    public static func showsCombatResolver(
        for gameSystemId: String,
        registry: GameSystemRegistry = .bundled
    ) -> Bool {
        guard showsRollEvaluator else { return false }
        guard isGameSystemIdVisible(gameSystemId, registry: registry) else { return false }
        guard let capabilities = registry.capabilities(for: gameSystemId) else { return false }
        if capabilities.showsCombatResolver {
            return true
        }
        return false
    }

    public static func isGameSystemVisible(
        _ system: GameSystem,
        registry: GameSystemRegistry = .bundled
    ) -> Bool {
        guard isGameSystemIdVisible(system.id, registry: registry) else { return false }
        if fullSurfaceEnabled {
            switch system.id {
            case "wh40k-10e":
                return true
            default:
                return system.availability == .available
            }
        }
        return system.availability == .available
    }
}
