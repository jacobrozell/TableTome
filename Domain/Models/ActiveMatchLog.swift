import Foundation

public struct ActiveMatchLog: Codable, Sendable, Equatable {
    public var matchId: UUID
    public var startedAt: Date
    public var events: [MatchLogEvent]

    public init(
        matchId: UUID = UUID(),
        startedAt: Date = Date(),
        events: [MatchLogEvent] = []
    ) {
        self.matchId = matchId
        self.startedAt = startedAt
        self.events = events
    }
}
