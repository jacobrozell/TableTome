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

public enum MatchSyncCodecError: Equatable, Error, Sendable {
    case missingPrefix
    case invalidBase64
    case decodeFailed
    case encodeFailed

    public var localizedMessage: String {
        switch self {
        case .missingPrefix, .invalidBase64, .decodeFailed:
            String(localized: "Could not read that code.")
        case .encodeFailed:
            String(localized: "Could not create a match code to share.")
        }
    }
}

extension MatchSyncCodecError {
    public var logDescription: String {
        switch self {
        case .missingPrefix: "missingPrefix"
        case .invalidBase64: "invalidBase64"
        case .decodeFailed: "decodeFailed"
        case .encodeFailed: "encodeFailed"
        }
    }
}

public enum MatchSyncApplyError: Equatable, Sendable {
    case incompatibleSchema(received: Int, expected: Int)
    case wrongGameSystem(received: String, expected: String)

    public var localizedMessage: String {
        switch self {
        case let .incompatibleSchema(received, expected):
            String(
                localized: """
                This match code needs a different version of Tabletome (format \(received), expected \(expected)). \
                Update both devices and try again.
                """
            )
        case .wrongGameSystem:
            String(
                localized: """
                This match code is for a different game mode. Both players need the same Guided Match open on each device.
                """
            )
        }
    }
}

extension MatchSyncApplyError {
    public var logDescription: String {
        switch self {
        case let .incompatibleSchema(received, expected):
            "incompatibleSchema received=\(received) expected=\(expected)"
        case let .wrongGameSystem(received, expected):
            "wrongGameSystem received=\(received) expected=\(expected)"
        }
    }
}

public enum MatchSyncCodec {
    private static let prefix = "tabletome-match:"

    public static func encode(_ snapshot: MatchSyncSnapshot) -> String? {
        switch encodePasteCode(snapshot) {
        case let .success(code): return code
        case .failure: return nil
        }
    }

    public static func encodePasteCode(_ snapshot: MatchSyncSnapshot) -> Result<String, MatchSyncCodecError> {
        do {
            let data = try JSONEncoder().encode(snapshot)
            return .success(prefix + data.base64EncodedString())
        } catch {
            MatchSyncLogger.codecError("Paste encode failed", error: error)
            return .failure(.encodeFailed)
        }
    }

    public static func decode(_ code: String) -> MatchSyncSnapshot? {
        switch decodePasteCode(code) {
        case let .success(snapshot): return snapshot
        case .failure: return nil
        }
    }

    public static func decodePasteCode(_ code: String) -> Result<MatchSyncSnapshot, MatchSyncCodecError> {
        let trimmed = code.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.hasPrefix(prefix) else {
            MatchSyncLogger.codecError("Paste decode failed — \(MatchSyncCodecError.missingPrefix.logDescription)")
            return .failure(.missingPrefix)
        }
        let payload = String(trimmed.dropFirst(prefix.count))
        guard let data = Data(base64Encoded: payload) else {
            MatchSyncLogger.codecError("Paste decode failed — \(MatchSyncCodecError.invalidBase64.logDescription)")
            return .failure(.invalidBase64)
        }
        do {
            let snapshot = try JSONDecoder().decode(MatchSyncSnapshot.self, from: data)
            return .success(snapshot)
        } catch {
            MatchSyncLogger.codecError("Paste decode failed — \(MatchSyncCodecError.decodeFailed.logDescription)", error: error)
            return .failure(.decodeFailed)
        }
    }

    public static func decodeWireData(_ data: Data) -> Result<MatchSyncSnapshot, MatchSyncCodecError> {
        do {
            let snapshot = try JSONDecoder().decode(MatchSyncSnapshot.self, from: data)
            return .success(snapshot)
        } catch {
            MatchSyncLogger.codecError("Wire decode failed — \(MatchSyncCodecError.decodeFailed.logDescription)", error: error)
            return .failure(.decodeFailed)
        }
    }

    public static func encodeWireData(_ snapshot: MatchSyncSnapshot) -> Result<Data, MatchSyncCodecError> {
        do {
            return .success(try JSONEncoder().encode(snapshot))
        } catch {
            MatchSyncLogger.codecError("Wire encode failed", error: error)
            return .failure(.encodeFailed)
        }
    }

    public static func current(gameSystemId: String = "aos-spearhead") -> MatchSyncSnapshot {
        MatchSyncSnapshot(
            gameSystemId: gameSystemId,
            matchState: MatchSetupStore.load(gameSystemId: gameSystemId),
            trackerState: BattleTrackerStore.load(gameSystemId: gameSystemId)
        )
    }

    public static func validate(
        _ snapshot: MatchSyncSnapshot,
        expectedGameSystemId: String?
    ) -> MatchSyncApplyError? {
        if snapshot.schemaVersion != MatchSyncSchemaPolicy.version {
            return .incompatibleSchema(
                received: snapshot.schemaVersion,
                expected: MatchSyncSchemaPolicy.version
            )
        }
        if let expectedGameSystemId, snapshot.gameSystemId != expectedGameSystemId {
            return .wrongGameSystem(received: snapshot.gameSystemId, expected: expectedGameSystemId)
        }
        return nil
    }

    @discardableResult
    public static func apply(
        _ snapshot: MatchSyncSnapshot,
        expectedGameSystemId: String? = nil,
        notifyUI: Bool = true,
        source: String = "unknown"
    ) -> MatchSyncApplyError? {
        if let error = validate(snapshot, expectedGameSystemId: expectedGameSystemId) {
            MatchSyncLogger.logApplyFailure(error, source: source)
            return error
        }
        MatchSetupStore.save(snapshot.matchState, gameSystemId: snapshot.gameSystemId, notifySync: false)
        BattleTrackerStore.save(snapshot.trackerState, gameSystemId: snapshot.gameSystemId, notifySync: false)
        MatchSyncLogger.logApplySuccess(
            gameSystemId: snapshot.gameSystemId,
            battleRound: snapshot.trackerState.battleRound,
            source: source
        )
        if notifyUI {
            MatchSyncNotifications.postStateDidChange(shouldBroadcastToPeers: false)
        }
        return nil
    }
}
