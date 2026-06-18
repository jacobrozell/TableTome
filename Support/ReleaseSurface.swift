import Foundation
import TabletomeDomain

public enum ReleaseSurface {
    private static var fullSurfaceEnabled: Bool {
        ProcessInfo.processInfo.arguments.contains("-enable_full_product_surface")
    }

    public static var shows40kEditions: Bool { true }

    public static var showsRollEvaluator: Bool { true }
    public static var showsRulesAssistant: Bool { true }

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

    public static func showsNewEditionBadge(for gameSystemId: String) -> Bool {
        gameSystemId == "wh40k-11e"
    }

    public static func showsGuidedMatch(for gameSystemId: String) -> Bool {
        gameSystemId == "aos-spearhead"
    }

    public static func showsCombatResolver(for gameSystemId: String) -> Bool {
        showsRollEvaluator && gameSystemId == "aos-spearhead"
    }

    public static func isGameSystemVisible(_ system: GameSystem) -> Bool {
        switch system.id {
        case "aos-spearhead", "wh40k-11e":
            return true
        case "wh40k-10e":
            return fullSurfaceEnabled
        default:
            return system.availability == .available
        }
    }
}
