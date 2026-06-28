import Foundation
import TabletomeDomain

extension GameSystemRegistry {
    /// Bundled registry with featured armies sourced from each system's `*-boxsets-v1.json`
    /// (Phase 4). Hardcoded literals were removed from `GameSystemId+Bundled.swift`.
    public static func bundled(withBoxSetsFrom bundle: Bundle) -> GameSystemRegistry {
        let manifest = try? GameSystemsManifestLoader.load(from: bundle)
        let entriesById = Dictionary(
            uniqueKeysWithValues: (manifest?.systems ?? []).map { ($0.id, $0) }
        )

        let descriptors = GameSystemRegistry.seeded.allDescriptors.map { descriptor -> GameSystemDescriptor in
            guard
                let entry = entriesById[descriptor.gameSystemId],
                let boxSets = try? BoxSetCatalogLoader.load(for: entry, from: bundle),
                let featured = boxSets.primaryFeaturedArmies
            else {
                return descriptor
            }
            return descriptor.replacingFeaturedArmies(featured)
        }

        return GameSystemRegistry(descriptors: descriptors)
    }
}
