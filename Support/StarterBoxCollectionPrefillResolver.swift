import Foundation
import TabletomeData
import TabletomeDomain

/// Maps starter-box play catalogs into collection unit rows for a chosen faction.
enum StarterBoxCollectionPrefillResolver {
    struct UnitSeed: Equatable, Sendable {
        let name: String
        let qty: Int
        let source: String
        let spearhead: Bool?
    }

    static func unitSeeds(
        onboardingChoice: String?,
        activeGameSystemId: String,
        game: String,
        factionLabel: String,
        catalogRepository: PlayCatalogRepository = BundledPlayCatalogRepository()
    ) async -> [UnitSeed]? {
        guard let gameSystemId = resolvedGameSystemId(
            onboardingChoice: onboardingChoice,
            activeGameSystemId: activeGameSystemId
        ),
              let gameSystem = GameSystemId(knownRawValue: gameSystemId),
              NewRosterPrefillResolver.isFixedRosterGameSystem(gameSystemId),
              let factionSlug = factionSlug(for: factionLabel, game: game, gameSystemId: gameSystemId),
              let armyId = armyId(for: factionSlug, gameSystemId: gameSystemId),
              let featured = GameSystemRegistry.bundled.featuredArmies(for: gameSystem) else {
            return nil
        }

        let catalog: SpearheadCatalog
        do {
            catalog = try await catalogRepository.loadCatalog(for: gameSystemId)
        } catch {
            return nil
        }

        guard let army = catalog.army(factionId: factionSlug, armyId: armyId), !army.units.isEmpty else {
            return nil
        }

        let source = featured.starterSetBadge
        let defaultSpearhead: Bool? = gameSystem == .aosSpearhead ? true : nil
        return army.units.map { unit in
            UnitSeed(
                name: collectionDisplayName(for: unit),
                qty: 1,
                source: source,
                spearhead: defaultSpearhead
            )
        }
    }

    static func collectionDisplayName(for unit: SpearheadUnit) -> String {
        if let count = unit.modelCount, count > 1 {
            return "\(unit.name) (\(count))"
        }
        return unit.name
    }

    static func factionSlug(for label: String, game: String, gameSystemId: String) -> String? {
        guard let featured = GameSystemRegistry.bundled.featuredArmies(for: GameSystemId(resolving: gameSystemId)) else {
            return nil
        }
        let normalized = FactionResolver.normalize(label)
        for slug in [featured.playerOne.factionId, featured.playerTwo.factionId] {
            if CollectionArmyPrefillResolver.factionLabel(forSlug: slug, game: game) == normalized {
                return slug
            }
        }
        return nil
    }

    private static func armyId(for factionSlug: String, gameSystemId: String) -> String? {
        guard let featured = GameSystemRegistry.bundled.featuredArmies(for: GameSystemId(resolving: gameSystemId)) else {
            return nil
        }
        if featured.playerOne.factionId == factionSlug { return featured.playerOne.armyId }
        if featured.playerTwo.factionId == factionSlug { return featured.playerTwo.armyId }
        return nil
    }

    private static func resolvedGameSystemId(
        onboardingChoice: String?,
        activeGameSystemId: String
    ) -> String? {
        if let onboardingChoice, GameSystemId(knownRawValue: onboardingChoice) != nil {
            return onboardingChoice
        }
        if GameSystemId(knownRawValue: activeGameSystemId) != nil {
            return activeGameSystemId
        }
        return onboardingChoice ?? activeGameSystemId
    }
}
