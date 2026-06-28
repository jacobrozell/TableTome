import Foundation
import TabletomeDomain

/// UserDefaults backing for the active game system — shared by `AppRouter` and DI defaults.
enum ActiveGameContextPersistence: Sendable {
    static let storageKey = "active_game_system_id"

    static var gameSystemId: String {
        get {
            UserDefaults.standard.string(forKey: storageKey)
                ?? GameSystemRulesLabels.defaultGameSystemId
        }
        set {
            UserDefaults.standard.set(newValue, forKey: storageKey)
        }
    }

    static func resetForTests() {
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
}
