import Foundation
import TabletomeDomain

extension GameSystemRegistry {
    /// The bundled registry with each descriptor's `featuredArmies` sourced
    /// from its `*-boxsets-v1.json` instead of the hardcoded literal in
    /// `GameSystemId+Bundled.swift` (Phase 4). Behaviour is identical — the
    /// parity test `BoxSetCatalogTests.testLoadsBundledBoxSetsForEverySystem`
    /// asserts the JSON matches the literals — but the data now flows from the
    /// content plane, so the literals can be deleted in a follow-up.
    ///
    /// Falls back to the hardcoded literal for any system whose box-set JSON is
    /// missing or fails to decode, so a packaging slip can never strip featured
    /// armies from a shipped system.
    public static func bundled(withBoxSetsFrom bundle: Bundle) -> GameSystemRegistry {
        let manifest = try? GameSystemsManifestLoader.load(from: bundle)
        let entriesById = Dictionary(
            uniqueKeysWithValues: (manifest?.systems ?? []).map { ($0.id, $0) }
        )

        let descriptors = GameSystemRegistry.bundled.allDescriptors.map { descriptor -> GameSystemDescriptor in
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
