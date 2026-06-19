import Foundation

/// Debug / automation launch arguments (simulator, UI tests, MCP).
enum AppLaunchArguments: Sendable {
    static let skipOnboarding = "-skip_onboarding"
    static let openGuidedMatch = "-open_guided_match"
    static let applyStarterMatchup = "-apply_starter_matchup"
    static let enableFullProductSurface = "-enable_full_product_surface"

    static var shouldOpenGuidedMatch: Bool {
        ProcessInfo.processInfo.arguments.contains(openGuidedMatch)
    }

    static var shouldApplyStarterMatchup: Bool {
        ProcessInfo.processInfo.arguments.contains(applyStarterMatchup)
    }
}
