import Foundation
import TabletomeDomain

public final class BundledPlayCatalogRepository: PlayCatalogRepository, @unchecked Sendable {
    private let bundle: Bundle
    private let registry: GameSystemRegistry
    private var cachedCatalogs: [String: SpearheadCatalog] = [:]

    public init(
        bundle: Bundle = .main,
        registry: GameSystemRegistry = .bundled
    ) {
        self.bundle = bundle
        self.registry = registry
    }

    public func loadCatalog(for gameSystemId: String) async throws -> SpearheadCatalog {
        if let cached = cachedCatalogs[gameSystemId] {
            return cached
        }
        guard let descriptor = registry.descriptor(for: gameSystemId) else {
            throw SpearheadCatalogRepositoryError.bundleNotFound
        }
        guard let bundleName = descriptor.catalogBundleName else {
            throw SpearheadCatalogRepositoryError.bundleNotFound
        }
        let loader = BundledSpearheadCatalogRepository(
            bundle: bundle,
            resourceName: bundleName,
            armyDetailsSubdirectories: descriptor.armyDetailsSubdirectories
        )
        let catalog = try await loader.loadCatalog()
        cachedCatalogs[gameSystemId] = catalog
        return catalog
    }
}
