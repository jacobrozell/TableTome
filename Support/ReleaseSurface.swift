import Foundation
import TabletomeDomain
import TabletomeData

public enum ReleaseSurface {
    /// Unlock gated features for CI, dogfood, and internal builds.
    private static var fullSurfaceEnabled: Bool {
        ProcessInfo.processInfo.arguments.contains("-enable_full_product_surface")
    }

    /// Play tab home shows only live play modes (Spearhead) unless this is enabled.
    public static var showsAllPlayModesOnHome: Bool {
        fullSurfaceEnabled
            || ProcessInfo.processInfo.arguments.contains("-enable_all_play_modes")
    }

    /// Live play modes surfaced on Play home for new users (TestFlight focus).
    private static let livePlayHomeGameSystemIds: Set<String> = [
        GameSystemId.aosSpearhead.rawValue,
    ]

    /// Combat Patrol (10th Edition rules) — ships in release defaults.
    public static var showsCombatPatrol: Bool {
        manifestAvailableSystemIds.contains(GameSystemId.wh40k10eCp.rawValue)
            || ProcessInfo.processInfo.arguments.contains("-enable_combat_patrol")
    }

    private static let manifestAvailableSystemIds: Set<String> = {
        guard let manifest = try? GameSystemsManifestLoader.load(from: .main) else {
            return [
                GameSystemId.aosSpearhead.rawValue,
                GameSystemId.wh40k11e.rawValue,
                GameSystemId.wh40k10eCp.rawValue,
            ]
        }
        return Set(
            manifest.systems.compactMap { entry -> String? in
                guard (entry.availability ?? "available") == "available" else { return nil }
                if GameSystemRegistry.seeded.capabilities(for: entry.id)?.requiresFullSurfaceFlag == true {
                    return nil
                }
                return entry.id
            }
        )
    }()

    // MARK: Tabs (1.0.0: Models, Play, Rules, Settings)

    public static var showsBenchTab: Bool { true }
    public static var showsMusterTab: Bool { fullSurfaceEnabled }
    public static var showsPaintsInBench: Bool { true }
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

    /// Spearhead ships physical-dice-only combat; simulated rolls stay available for other systems.
    public static func allowsSimulatedDice(for gameSystemId: GameSystemId) -> Bool {
        gameSystemId != .aosSpearhead
    }

    /// Use the new single-surface battle view for Spearhead (replaces tab-based tracker).
    /// See `ongoing/guided-match-ui-redesign.md`.
    public static var usesSpearheadSingleSurfaceBattle: Bool {
        fullSurfaceEnabled
            || ProcessInfo.processInfo.arguments.contains("-enable_single_surface_battle")
    }

    // MARK: Game systems

    public static func isGameSystemIdVisible(
        _ gameSystemId: String,
        registry: GameSystemRegistry = .bundled(withBoxSetsFrom: .main)
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
        return manifestAvailableSystemIds.contains(gameSystemId)
    }

    /// Play tab home list and new-player chooser — Spearhead-only unless `showsAllPlayModesOnHome`.
    public static func isPlayHomeGameSystemVisible(
        _ gameSystemId: String,
        registry: GameSystemRegistry = .bundled(withBoxSetsFrom: .main)
    ) -> Bool {
        guard isGameSystemIdVisible(gameSystemId, registry: registry) else { return false }
        if showsAllPlayModesOnHome { return true }
        return livePlayHomeGameSystemIds.contains(gameSystemId)
    }

    public static func isPlayHomeGameSystemVisible(
        _ system: GameSystem,
        registry: GameSystemRegistry = .bundled(withBoxSetsFrom: .main)
    ) -> Bool {
        isPlayHomeGameSystemVisible(system.id, registry: registry)
    }

    public static func showsNewEditionBadge(
        for gameSystemId: GameSystemId,
        registry: GameSystemRegistry = .bundled(withBoxSetsFrom: .main)
    ) -> Bool {
        showsNewEditionBadge(for: gameSystemId.rawValue, registry: registry)
    }

    public static func showsNewEditionBadge(
        for gameSystemId: String,
        registry: GameSystemRegistry = .bundled(withBoxSetsFrom: .main)
    ) -> Bool {
        registry.capabilities(for: gameSystemId)?.showsNewEditionBadge == true
    }

    public static func showsGuidedMatch(
        for gameSystemId: GameSystemId,
        registry: GameSystemRegistry = .bundled(withBoxSetsFrom: .main)
    ) -> Bool {
        showsGuidedMatch(for: gameSystemId.rawValue, registry: registry)
    }

    public static func showsGuidedMatch(
        for gameSystemId: String,
        registry: GameSystemRegistry = .bundled(withBoxSetsFrom: .main)
    ) -> Bool {
        guard isGameSystemIdVisible(gameSystemId, registry: registry) else { return false }
        return registry.capabilities(for: gameSystemId)?.showsGuidedMatch == true
    }

    public static func showsCombatResolver(
        for gameSystemId: GameSystemId,
        registry: GameSystemRegistry = .bundled(withBoxSetsFrom: .main)
    ) -> Bool {
        showsCombatResolver(for: gameSystemId.rawValue, registry: registry)
    }

    public static func showsCombatResolver(
        for gameSystemId: String,
        registry: GameSystemRegistry = .bundled(withBoxSetsFrom: .main)
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
        registry: GameSystemRegistry = .bundled(withBoxSetsFrom: .main)
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
