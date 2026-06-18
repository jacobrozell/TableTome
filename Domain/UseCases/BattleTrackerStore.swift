import Foundation

public enum BattleTrackerStore: Sendable {
    private static let stateKey = "battle_tracker_state_aos_spearhead"

    public static func load() -> BattleTrackerState {
        guard let data = UserDefaults.standard.data(forKey: stateKey),
              let state = try? JSONDecoder().decode(BattleTrackerState.self, from: data) else {
            return BattleTrackerState()
        }
        return state
    }

    public static func save(_ state: BattleTrackerState, notifySync: Bool = true) {
        guard let data = try? JSONEncoder().encode(state) else { return }
        UserDefaults.standard.set(data, forKey: stateKey)
        if notifySync {
            MatchSyncNotifications.postStateDidChange()
        }
    }

    public static func reset() {
        UserDefaults.standard.removeObject(forKey: stateKey)
    }
}
