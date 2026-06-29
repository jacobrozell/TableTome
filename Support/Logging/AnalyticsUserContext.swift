import FirebaseAnalytics
import Foundation
import TabletomeHobbyData

/// Privacy-safe user properties for retention and product-health segmentation.
@MainActor
enum AnalyticsUserContext {
    static func sync(activeGameSystemId: String? = nil) {
        guard FirebaseBootstrap.shouldConfigure, FirebaseBootstrap.isAnalyticsCollectionEnabled else { return }

        for (name, value) in userPropertyValues(activeGameSystemId: activeGameSystemId) {
            Analytics.setUserProperty(value, forName: name)
        }
    }

    static func syncOnboardingCompleted() {
        sync()
    }

    static func userPropertyValues(activeGameSystemId: String? = nil) -> [String: String] {
        var values: [String: String] = [
            "onboarding_complete": boolString(OnboardingStore.hasCompletedAppTour),
            "app_locale": appLocaleCode(),
            "appearance_mode": UserDefaults.standard.string(forKey: AppearanceStore.storageKey) ?? ThemePreference.system.rawValue
        ]

        values.merge(AnalyticsFeatureUsageStore.userPropertyValues(activeGameSystemId: activeGameSystemId)) { _, new in new }

        if let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String, !buildNumber.isEmpty {
            values["build_number"] = buildNumber
        }

        if let choice = FirstSessionStore.onboardingChoice {
            values["onboarding_choice"] = choice
        }

        if ReleaseSurface.showsMusterTab {
            values["product_surface"] = "full"
        } else {
            values["product_surface"] = "release"
        }

        return values
    }

    private static func appLocaleCode() -> String {
        if let preferred = Bundle.main.preferredLocalizations.first, !preferred.isEmpty {
            return preferred
        }
        if let languageCode = Locale.current.language.languageCode?.identifier, !languageCode.isEmpty {
            return languageCode
        }
        return "unknown"
    }

    private static func boolString(_ value: Bool) -> String {
        value ? "true" : "false"
    }
}
