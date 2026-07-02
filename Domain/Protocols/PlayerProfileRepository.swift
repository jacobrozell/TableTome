import Foundation

public enum PlayerProfileRepositoryError: Error, Equatable, Sendable {
    case readFailed
    case writeFailed
    case profileNotFound
    case cannotDeleteLastProfile
    case invalidDisplayName
}

public protocol PlayerProfileRepository: Sendable {
    func loadHousehold() async throws -> HouseholdPlayersState
    func saveHousehold(_ state: HouseholdPlayersState) async throws
    func profile(id: UUID) async throws -> PlayerProfile?
}
