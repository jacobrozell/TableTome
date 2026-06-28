import Foundation

/// Combined match + tracker payload for sharing between two devices.
public struct MatchSyncSnapshot: Codable, Sendable, Equatable {
    public var schemaVersion: Int
    public var gameSystemId: String
    public var matchState: GuidedMatchState
    public var trackerState: BattleTrackerState
    public var updatedAt: Date

    public init(
        schemaVersion: Int = MatchSyncSchemaPolicy.version,
        gameSystemId: String = "aos-spearhead",
        matchState: GuidedMatchState,
        trackerState: BattleTrackerState,
        updatedAt: Date = Date()
    ) {
        self.schemaVersion = schemaVersion
        self.gameSystemId = gameSystemId
        self.matchState = matchState
        self.trackerState = trackerState
        self.updatedAt = updatedAt
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        schemaVersion = try container.decodeIfPresent(Int.self, forKey: .schemaVersion) ?? 1
        gameSystemId = try container.decodeIfPresent(String.self, forKey: .gameSystemId) ?? "aos-spearhead"
        matchState = try container.decode(GuidedMatchState.self, forKey: .matchState)
        trackerState = try container.decode(BattleTrackerState.self, forKey: .trackerState)
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt) ?? Date()
    }
}

/// Version for nearby match sync payloads — bump when tracker or match state shapes change.
public enum MatchSyncSchemaPolicy {
    public static let version = 1
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

    public static func current(gameSystemId: String = "aos-spearhead") -> MatchSyncSnapshot {
        MatchSyncSnapshot(
            gameSystemId: gameSystemId,
            matchState: MatchSetupStore.load(gameSystemId: gameSystemId),
            trackerState: BattleTrackerStore.load(gameSystemId: gameSystemId)
        )
    }

    public static func apply(_ snapshot: MatchSyncSnapshot, notifyUI: Bool = true) {
        MatchSetupStore.save(snapshot.matchState, gameSystemId: snapshot.gameSystemId, notifySync: false)
        BattleTrackerStore.save(snapshot.trackerState, gameSystemId: snapshot.gameSystemId, notifySync: false)
        if notifyUI {
            MatchSyncNotifications.postStateDidChange()
        }
    }
}
