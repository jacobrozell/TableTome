import Foundation
import SpearheadDomain

public enum ReleaseSurface {
    private static var fullSurfaceEnabled: Bool {
        ProcessInfo.processInfo.arguments.contains("-enable_full_product_surface")
    }

    public static var shows40kEditions: Bool { fullSurfaceEnabled }
    public static var showsRollEvaluator: Bool { false }
    public static var showsRulesAssistant: Bool { false }

    public static func isGameSystemVisible(_ system: GameSystem) -> Bool {
        switch system.id {
        case "aos-spearhead":
            return true
        case "wh40k-10e", "wh40k-11e":
            return fullSurfaceEnabled
        default:
            return system.availability == .available
        }
    }
}
