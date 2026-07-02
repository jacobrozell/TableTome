import Foundation

public enum MatchHistoryRepositoryError: Error, Equatable, Sendable {
    case writeFailed
    case readFailed
    case recordNotFound
}

public protocol MatchHistoryRepository: Sendable {
    func fetchRecords(limit: Int?, gameSystemId: String?, involvingProfileId: UUID?) async throws -> [MatchRecord]
    func fetchRecord(id: UUID) async throws -> MatchRecord?
    func fetchLog(matchId: UUID) async throws -> [MatchLogEvent]
    func archive(record: MatchRecord, log: [MatchLogEvent]) async throws
    func deleteRecord(id: UUID) async throws
}

public extension MatchHistoryRepository {
    func fetchRecords(limit: Int?, gameSystemId: String?) async throws -> [MatchRecord] {
        try await fetchRecords(limit: limit, gameSystemId: gameSystemId, involvingProfileId: nil)
    }
}
