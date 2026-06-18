import Foundation

public enum BattleTrackerStore: Sendable {
    private static func stateKey(for gameSystemId: String) -> String {
        "battle_tracker_state_\(gameSystemId)"
    }

    public static func load(gameSystemId: GameSystemId) -> BattleTrackerState {
        load(gameSystemId: gameSystemId.rawValue)
    }

    public static func load(gameSystemId: String = GameSystemId.default.rawValue) -> BattleTrackerState {
        let key = stateKey(for: gameSystemId)
        guard let data = UserDefaults.standard.data(forKey: key),
              let state = try? JSONDecoder().decode(BattleTrackerState.self, from: data) else {
            return BattleTrackerState()
        }
        return state
    }

    public static func save(
        _ state: BattleTrackerState,
        gameSystemId: GameSystemId,
        notifySync: Bool = true
    ) {
        save(state, gameSystemId: gameSystemId.rawValue, notifySync: notifySync)
    }

    public static func save(
        _ state: BattleTrackerState,
        gameSystemId: String = GameSystemId.default.rawValue,
        notifySync: Bool = true
    ) {
        guard let data = try? JSONEncoder().encode(state) else { return }
        UserDefaults.standard.set(data, forKey: stateKey(for: gameSystemId))
        if notifySync {
            MatchSyncNotifications.postStateDidChange()
        }
    }

    public static func reset(gameSystemId: GameSystemId) {
        reset(gameSystemId: gameSystemId.rawValue)
    }

    public static func reset(gameSystemId: String = GameSystemId.default.rawValue) {
        UserDefaults.standard.removeObject(forKey: stateKey(for: gameSystemId))
    }
}
