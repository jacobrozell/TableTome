import Foundation

public enum MatchSessionStore: Sendable {
    private static func key(gameSystemId: String) -> String {
        "match_session_started_\(gameSystemId)"
    }

    public static func startedAt(gameSystemId: GameSystemId) -> Date? {
        startedAt(gameSystemId: gameSystemId.rawValue)
    }

    public static func startedAt(gameSystemId: String) -> Date? {
        let interval = UserDefaults.standard.double(forKey: key(gameSystemId: gameSystemId))
        guard interval > 0 else { return nil }
        return Date(timeIntervalSince1970: interval)
    }

    public static func markStartedIfNeeded(gameSystemId: GameSystemId, at date: Date = Date()) {
        markStartedIfNeeded(gameSystemId: gameSystemId.rawValue, at: date)
    }

    public static func markStartedIfNeeded(gameSystemId: String, at date: Date = Date()) {
        guard startedAt(gameSystemId: gameSystemId) == nil else { return }
        UserDefaults.standard.set(date.timeIntervalSince1970, forKey: key(gameSystemId: gameSystemId))
    }

    public static func clear(gameSystemId: GameSystemId) {
        clear(gameSystemId: gameSystemId.rawValue)
    }

    public static func clear(gameSystemId: String) {
        UserDefaults.standard.removeObject(forKey: key(gameSystemId: gameSystemId))
    }
}
