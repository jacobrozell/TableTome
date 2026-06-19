import Foundation

/// Debug / automation launch arguments (simulator, UI tests, MCP).
enum AppLaunchArguments: Sendable {
    static let skipOnboarding = "-skip_onboarding"
    static let openGuidedMatch = "-open_guided_match"
    static let applyStarterMatchup = "-apply_starter_matchup"
    /// Applies starter armies, completes setup, and opens the Battle tab tracker (simulator / UI tests).
    static let openBattleTracker = "-open_battle_tracker"
    static let enableFullProductSurface = "-enable_full_product_surface"

    static var shouldOpenGuidedMatch: Bool {
        ProcessInfo.processInfo.arguments.contains(openGuidedMatch)
    }

    static var shouldApplyStarterMatchup: Bool {
        ProcessInfo.processInfo.arguments.contains(applyStarterMatchup)
    }

    static var shouldOpenBattleTracker: Bool {
        ProcessInfo.processInfo.arguments.contains(openBattleTracker)
    }
}
