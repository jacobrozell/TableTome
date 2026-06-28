import XCTest
@testable import Tabletome
@testable import TabletomeData
@testable import TabletomeDomain

final class StarterBoxCollectionPrefillResolverTests: XCTestCase {
    private var repository: BundledPlayCatalogRepository {
        BundledPlayCatalogRepository(bundle: Bundle(for: StarterBoxCollectionPrefillResolverTests.self))
    }

    func testSpearheadStormcastStarterUnits() async {
        let seeds = await StarterBoxCollectionPrefillResolver.unitSeeds(
            onboardingChoice: GameSystemId.aosSpearhead.rawValue,
            activeGameSystemId: GameSystemId.default.rawValue,
            game: "AoS",
            factionLabel: "Stormcast Eternals",
            catalogRepository: repository
        )

        XCTAssertNotNil(seeds)
        XCTAssertEqual(seeds?.count, 4)
        XCTAssertTrue(seeds?.contains(where: { $0.name == "Liberators (5)" }) == true)
        XCTAssertTrue(seeds?.allSatisfy { $0.spearhead == true } == true)
    }

    func testCombatPatrolSpaceMarinesStarterUnits() async {
        let seeds = await StarterBoxCollectionPrefillResolver.unitSeeds(
            onboardingChoice: GameSystemId.wh40k10eCp.rawValue,
            activeGameSystemId: GameSystemId.default.rawValue,
            game: "40k",
            factionLabel: "Space Marines",
            catalogRepository: repository
        )

        XCTAssertNotNil(seeds)
        XCTAssertEqual(seeds?.count, 4)
        XCTAssertTrue(seeds?.contains(where: { $0.name == "Terminator Squad (5)" }) == true)
        XCTAssertTrue(seeds?.allSatisfy { $0.spearhead == nil } == true)
    }

    func testReturnsNilForNonFixedRosterGameSystem() async {
        let seeds = await StarterBoxCollectionPrefillResolver.unitSeeds(
            onboardingChoice: GameSystemId.wh40k11e.rawValue,
            activeGameSystemId: GameSystemId.wh40k11e.rawValue,
            game: "40k",
            factionLabel: "Space Marines",
            catalogRepository: repository
        )

        XCTAssertNil(seeds)
    }

    func testCollectionDisplayNameAddsModelCount() {
        let unit = SpearheadUnit(id: "test", name: "Clanrats", modelCount: 10)
        XCTAssertEqual(StarterBoxCollectionPrefillResolver.collectionDisplayName(for: unit), "Clanrats (10)")
    }

    func testFactionSlugMapsFeaturedFactions() {
        XCTAssertEqual(
            StarterBoxCollectionPrefillResolver.factionSlug(
                for: "Stormcast Eternals",
                game: "AoS",
                gameSystemId: GameSystemId.aosSpearhead.rawValue
            ),
            "stormcast-eternals"
        )
        XCTAssertEqual(
            StarterBoxCollectionPrefillResolver.factionSlug(
                for: "Space Marines",
                game: "40k",
                gameSystemId: GameSystemId.wh40k10eCp.rawValue
            ),
            "space-marines"
        )
    }
}
