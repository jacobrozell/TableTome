import Foundation

public protocol PlayCatalogRepository: Sendable {
    func loadCatalog(for gameSystemId: String) async throws -> SpearheadCatalog
}

/// Adapts a play catalog repository to the legacy single-catalog protocol for one game system.
public struct GameSystemCatalogRepository: SpearheadCatalogRepository, Sendable {
    private let gameSystemId: String
    private let repository: any PlayCatalogRepository

    public init(gameSystemId: String, repository: any PlayCatalogRepository) {
        self.gameSystemId = gameSystemId
        self.repository = repository
    }

    public func loadCatalog() async throws -> SpearheadCatalog {
        try await repository.loadCatalog(for: gameSystemId)
    }
}
