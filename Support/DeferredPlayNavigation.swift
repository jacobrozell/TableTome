import Foundation

/// Defers Play-tab navigation until after onboarding dismiss or tab shell layout settles.
@MainActor
enum DeferredPlayNavigation {
    private static let onboardingDismissDelayMs = 500
    private static let launchDeepLinkDelayMs = 150

    static func afterOnboardingDismiss(perform action: @escaping () -> Void) {
        Task {
            try? await Task.sleep(for: .milliseconds(onboardingDismissDelayMs))
            action()
        }
    }

    static func afterLaunchShellReady(perform action: @escaping () -> Void) {
        Task {
            try? await Task.sleep(for: .milliseconds(launchDeepLinkDelayMs))
            action()
        }
    }
}
