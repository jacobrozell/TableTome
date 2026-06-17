import Foundation

public enum SpearheadCatalogRepositoryError: Error, Equatable, Sendable {
    case bundleNotFound
    case decodeFailed(underlying: String)
    case invalidContent(path: String, message: String)
}

public protocol SpearheadCatalogRepository: Sendable {
    func loadCatalog() async throws -> SpearheadCatalog
}
