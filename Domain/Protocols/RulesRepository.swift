import Foundation

public enum RulesRepositoryError: Error, Equatable, Sendable {
    case bundleNotFound
    case decodeFailed
    case gameSystemNotFound(id: String)
}

public protocol RulesRepository: Sendable {
    func loadBundle() async throws -> RulesBundle
    func gameSystem(id: String) async throws -> GameSystem
    func availableGameSystems() async throws -> [GameSystem]
}
