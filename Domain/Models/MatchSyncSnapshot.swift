import Foundation

/// Combined match + tracker payload for sharing between two devices.
public struct MatchSyncSnapshot: Codable, Sendable, Equatable {
    public var matchState: GuidedMatchState
    public var trackerState: BattleTrackerState
    public var updatedAt: Date

    public init(
        matchState: GuidedMatchState,
        trackerState: BattleTrackerState,
        updatedAt: Date = Date()
    ) {
        self.matchState = matchState
        self.trackerState = trackerState
        self.updatedAt = updatedAt
    }
}

public enum MatchSyncCodec {
    private static let prefix = "tabletome-match:"

    public static func encode(_ snapshot: MatchSyncSnapshot) -> String? {
        guard let data = try? JSONEncoder().encode(snapshot) else { return nil }
        return prefix + data.base64EncodedString()
    }

    public static func decode(_ code: String) -> MatchSyncSnapshot? {
        let trimmed = code.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.hasPrefix(prefix) else { return nil }
        let payload = String(trimmed.dropFirst(prefix.count))
        guard let data = Data(base64Encoded: payload),
              let snapshot = try? JSONDecoder().decode(MatchSyncSnapshot.self, from: data) else {
            return nil
        }
        return snapshot
    }

    public static func current() -> MatchSyncSnapshot {
        MatchSyncSnapshot(
            matchState: MatchSetupStore.load(),
            trackerState: BattleTrackerStore.load()
        )
    }

    public static func apply(_ snapshot: MatchSyncSnapshot, notifyUI: Bool = true) {
        MatchSetupStore.save(snapshot.matchState, notifySync: false)
        BattleTrackerStore.save(snapshot.trackerState, notifySync: false)
        if notifyUI {
            MatchSyncNotifications.postStateDidChange()
        }
    }
}
