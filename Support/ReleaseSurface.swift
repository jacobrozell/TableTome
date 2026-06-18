import Foundation
import TabletomeDomain

public enum ReleaseSurface {
    private static var fullSurfaceEnabled: Bool {
        ProcessInfo.processInfo.arguments.contains("-enable_full_product_surface")
    }

    public static var shows40kEditions: Bool { true }

    public static var showsRollEvaluator: Bool { true }
    public static var showsRulesAssistant: Bool { true }

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
