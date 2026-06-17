import Foundation

public enum MatchSetupStore: Sendable {
    private static let stateKey = "guided_match_state_aos_spearhead"

    public static func load() -> GuidedMatchState {
        guard let data = UserDefaults.standard.data(forKey: stateKey),
              let state = try? JSONDecoder().decode(GuidedMatchState.self, from: data) else {
            return GuidedMatchState()
        }
        return state
    }

    public static func save(_ state: GuidedMatchState) {
        guard let data = try? JSONEncoder().encode(state) else { return }
        UserDefaults.standard.set(data, forKey: stateKey)
    }

    public static func reset() {
        UserDefaults.standard.removeObject(forKey: stateKey)
    }
}
