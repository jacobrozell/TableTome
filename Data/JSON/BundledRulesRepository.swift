import Foundation
import SpearheadDomain

public final class BundledRulesRepository: RulesRepository, @unchecked Sendable {
    private let bundle: Bundle
    private let resourceName: String
    private var cachedBundle: RulesBundle?

    public init(bundle: Bundle = .main, resourceName: String = "rules-v1") {
        self.bundle = bundle
        self.resourceName = resourceName
    }

    public func loadBundle() async throws -> RulesBundle {
        if let cachedBundle {
            return cachedBundle
        }
        guard let url = bundle.url(forResource: resourceName, withExtension: "json") else {
            throw RulesRepositoryError.bundleNotFound
        }
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        do {
            let decoded = try decoder.decode(RulesBundle.self, from: data)
            cachedBundle = decoded
            return decoded
        } catch {
            throw RulesRepositoryError.decodeFailed
        }
    }

    public func gameSystem(id: String) async throws -> GameSystem {
        let bundle = try await loadBundle()
        guard let system = bundle.gameSystems.first(where: { $0.id == id }) else {
            throw RulesRepositoryError.gameSystemNotFound(id: id)
        }
        return system
    }

    public func availableGameSystems() async throws -> [GameSystem] {
        try await loadBundle().gameSystems
    }
}
