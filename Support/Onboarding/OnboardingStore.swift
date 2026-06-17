import Foundation

/// Persists whether the user has finished the first-launch app tour.
enum OnboardingStore: Sendable {
    static let completedKey = "onboarding_completed"
    static let skipLaunchArgument = AppLaunchArguments.skipOnboarding

    private static var isEnabled: Bool {
        !ProcessInfo.processInfo.arguments.contains(skipLaunchArgument)
    }

    static var shouldPresentOnLaunch: Bool {
        isEnabled && !UserDefaults.standard.bool(forKey: completedKey)
    }

    static func markCompleted() {
        UserDefaults.standard.set(true, forKey: completedKey)
    }

    static func clearPersistedState() {
        UserDefaults.standard.removeObject(forKey: completedKey)
    }
}

enum OnboardingPresentationMode: Sendable {
    case firstLaunch
    case replay
}
