import Foundation
import SwiftData

/// UserDefaults-backed app appearance. Single source of truth for light/dark/system.
/// `AppConfiguration.theme` is kept in sync for hobby backup export/import.
public enum AppearancePreferenceStorage {
    public static let userDefaultsKey = "appearance"
    private static let migratedKey = "appearance_synced_from_hobby"

    public static func current() -> ThemePreference {
        ThemePreference(rawValue: UserDefaults.standard.string(forKey: userDefaultsKey) ?? "") ?? .system
    }

    public static func set(_ theme: ThemePreference) {
        UserDefaults.standard.set(theme.rawValue, forKey: userDefaultsKey)
    }

    /// One-time: prefer an existing hobby-config theme when Tabletome has never set appearance.
    @MainActor
    public static func migrateFromHobbyConfigurationIfNeeded(_ context: ModelContext) {
        guard !UserDefaults.standard.bool(forKey: migratedKey) else { return }
        UserDefaults.standard.set(true, forKey: migratedKey)
        if UserDefaults.standard.object(forKey: userDefaultsKey) == nil {
            set(HobbyConfig.current(context).theme)
        } else {
            syncToHobbyConfiguration(context)
        }
    }

    @MainActor
    public static func syncToHobbyConfiguration(_ context: ModelContext) {
        let cfg = HobbyConfig.current(context)
        let theme = current()
        guard cfg.theme != theme else { return }
        cfg.theme = theme
        try? context.save()
    }
}
