import Foundation

/// Persists whether the user has finished the first-launch app tour.
enum OnboardingStore: Sendable {
    static let completedKey = "onboarding_completed"
    static let skipLaunchArgument = AppLaunchArguments.skipOnboarding

    private static var isEnabled: Bool {
        !ProcessInfo.processInfo.arguments.contains(skipLaunchArgument)
    }

    static var shouldPresentOnLaunch: Bool {
        isEnabled && !hasCompletedAppTour
    }

    static var hasCompletedAppTour: Bool {
        UserDefaults.standard.bool(forKey: completedKey)
    }

    static func markCompleted() {
        UserDefaults.standard.set(true, forKey: completedKey)
    }

    static func clearPersistedState() {
        UserDefaults.standard.removeObject(forKey: completedKey)
    }
}

/// Furthest welcome page reached in the current presentation. Read when logging completion.
@MainActor
enum OnboardingSessionAnalytics {
    static var furthestPageIndex: Int = 0
}

enum OnboardingPresentationMode: Sendable {
    case firstLaunch
    case replay
}
