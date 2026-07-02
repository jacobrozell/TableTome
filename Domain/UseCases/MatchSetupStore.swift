import Foundation

public enum MatchSetupStore: Sendable {
    private static func stateKey(for gameSystemId: String) -> String {
        "guided_match_state_\(gameSystemId)"
    }

    public static func load(gameSystemId: GameSystemId) -> GuidedMatchState {
        load(gameSystemId: gameSystemId.rawValue)
    }

    public static func load(gameSystemId: String = GameSystemId.default.rawValue) -> GuidedMatchState {
        let key = stateKey(for: gameSystemId)
        guard var state = loadPersistedState(forKey: key) else {
            return GuidedMatchState()
        }
        if gameSystemId == GameSystemId.aosSpearhead.rawValue {
            SpearheadSetupStepId.migrateLegacyCompletedStepIds(&state.completedStepIds)
        }
        return state
    }

    private static func loadPersistedState(forKey key: String) -> GuidedMatchState? {
        guard let data = UserDefaults.standard.data(forKey: key),
              let state = try? JSONDecoder().decode(GuidedMatchState.self, from: data) else {
            return nil
        }
        return state
    }

    public static func save(
        _ state: GuidedMatchState,
        gameSystemId: GameSystemId,
        notifySync: Bool = true
    ) {
        save(state, gameSystemId: gameSystemId.rawValue, notifySync: notifySync)
    }

    public static func save(_ state: GuidedMatchState, gameSystemId: String = GameSystemId.default.rawValue, notifySync: Bool = true) {
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
