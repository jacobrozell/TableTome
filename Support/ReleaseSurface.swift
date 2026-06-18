import Foundation
import TabletomeDomain

public enum ReleaseSurface {
    private static var fullSurfaceEnabled: Bool {
        ProcessInfo.processInfo.arguments.contains("-enable_full_product_surface")
    }

    public static var shows40kEditions: Bool { true }

    public static var showsRollEvaluator: Bool { true }
    public static var showsRulesAssistant: Bool { true }
    public static var showsMatchHistory: Bool { true }

    // MARK: Pillars
    //
    // Unified-app pillars from FutureIdeas/UnifiedAppPlan.md. All non-Play pillars
    // default to the full-surface flag so they stay hidden in TestFlight/Release
    // until each pillar's Phase ships. Toggle from a single point so feature gates
    // never scatter across views.

    public static var showsBenchTab: Bool { fullSurfaceEnabled }
    public static var showsMusterTab: Bool { fullSurfaceEnabled }
    public static var showsPlayTab: Bool { true }
    public static var showsRulesTab: Bool { true }

    // MARK: Cross-pillar links

    public static var showsPlayFromRoster: Bool { fullSurfaceEnabled }
    public static var showsPaintStatusInMatch: Bool { fullSurfaceEnabled }

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
        registry.capabilities(for: gameSystemId)?.showsGuidedMatch == true
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
        guard let capabilities = registry.capabilities(for: gameSystemId) else { return false }
        if capabilities.showsCombatResolver {
            return true
        }
        return showsWh40kCombatResolver && gameSystemId == GameSystemId.wh40k11e.rawValue
    }

    /// Optional override for 11e resolver QA before general release.
    public static var showsWh40kCombatResolver: Bool {
        ProcessInfo.processInfo.arguments.contains("-enable_wh40k_combat_resolver")
    }

    public static func isGameSystemVisible(
        _ system: GameSystem,
        registry: GameSystemRegistry = .bundled
    ) -> Bool {
        if let capabilities = registry.capabilities(for: system.id) {
            if capabilities.requiresFullSurfaceFlag {
                return fullSurfaceEnabled
            }
            if capabilities.homeRowVisible {
                return true
            }
        }
        switch system.id {
        case "wh40k-10e":
            return fullSurfaceEnabled
        default:
            return system.availability == .available
        }
    }
}
