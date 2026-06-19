import SwiftUI
import TabletomeHobbyData

enum AppearanceStore {
    static let storageKey = AppearancePreferenceStorage.userDefaultsKey

    static func colorScheme(for rawValue: String) -> ColorScheme? {
        (ThemePreference(rawValue: rawValue) ?? .system).colorScheme
    }

    static func localizedLabel(for preference: ThemePreference) -> String {
        switch preference {
        case .system: String(localized: "System")
        case .light: String(localized: "Light")
        case .dark: String(localized: "Dark")
        }
    }
}
