import Foundation

public enum MatchLogEventKind: String, Codable, Sendable {
    case matchStarted
    case matchEnded
    case setupStepCompleted
    case deploymentStepCompleted
    case phaseChanged
    case roundAdvanced
    case activePlayerChanged
    case victoryPointsChanged
    case abilityUsed
    case damageApplied
    case combatBatchResolved
    case unitDestroyed
    case userNote
    case scActivation
    case scSupplyChanged
}

public struct MatchLogEvent: Codable, Sendable, Identifiable, Equatable {
    public let id: UUID
    public let matchId: UUID
    public let timestamp: Date
    public let kind: MatchLogEventKind
    public var payload: MatchLogEventPayload

    public init(
        id: UUID = UUID(),
        matchId: UUID,
        timestamp: Date = Date(),
        kind: MatchLogEventKind,
        payload: MatchLogEventPayload = MatchLogEventPayload()
    ) {
        self.id = id
        self.matchId = matchId
        self.timestamp = timestamp
        self.kind = kind
        self.payload = payload
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        matchId = try container.decode(UUID.self, forKey: .matchId)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        kind = try container.decode(MatchLogEventKind.self, forKey: .kind)
        payload = try container.decodeIfPresent(MatchLogEventPayload.self, forKey: .payload) ?? MatchLogEventPayload()
    }

    public static func == (lhs: MatchLogEvent, rhs: MatchLogEvent) -> Bool {
        lhs.id == rhs.id
            && lhs.matchId == rhs.matchId
            && lhs.timestamp == rhs.timestamp
            && lhs.kind == rhs.kind
            && lhs.payload == rhs.payload
    }
}
