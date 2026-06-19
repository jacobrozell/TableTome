import Foundation
import TabletomeDomain

/// Persists the game mode the user is actively playing so Rules Search and references stay in sync.
enum ActiveGameContextStore: Sendable {
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

    static func setActiveGameSystem(_ id: String) {
        gameSystemId = id
    }

    static func clearPersistedState() {
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
}
