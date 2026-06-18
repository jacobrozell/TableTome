import XCTest
@testable import TabletomeData
@testable import TabletomeDomain

final class BundledSpearheadCatalogRepositoryTests: XCTestCase {
    private var repository: BundledSpearheadCatalogRepository {
        BundledSpearheadCatalogRepository(bundle: Bundle(for: BundledSpearheadCatalogRepositoryTests.self))
    }

    func testDecodesProductionCatalog() async throws {
        let catalog = try await repository.loadCatalog()
        XCTAssertEqual(catalog.schemaVersion, 1)
        XCTAssertFalse(catalog.factions.isEmpty)
        XCTAssertEqual(catalog.matchSteps.count, 6)
    }

    func testVigilantBrotherhoodAndGnawfeastExist() async throws {
        let catalog = try await repository.loadCatalog()
        let stormcast = try XCTUnwrap(catalog.factions.first { $0.id == "stormcast-eternals" })
        let skaven = try XCTUnwrap(catalog.factions.first { $0.id == "skaven" })

        XCTAssertTrue(stormcast.armies.contains { $0.id == "vigilant-brotherhood" })
        XCTAssertTrue(skaven.armies.contains { $0.id == "gnawfeast-clawpack" })

        let vigilant = try XCTUnwrap(stormcast.armies.first { $0.id == "vigilant-brotherhood" })
        let gnawfeast = try XCTUnwrap(skaven.armies.first { $0.id == "gnawfeast-clawpack" })

        XCTAssertEqual(vigilant.battleTraitName, "Holy Orders")
        XCTAssertEqual(vigilant.regimentAbilities.count, 2)
        XCTAssertEqual(vigilant.enhancements.count, 4)
        XCTAssertEqual(gnawfeast.regimentAbilities.count, 2)
        XCTAssertEqual(gnawfeast.enhancements.count, 4)
        XCTAssertNotNil(vigilant.officialRulesURL)
        XCTAssertNotNil(gnawfeast.officialRulesURL)
    }

    func testYndrastasSpearheadFromOfficialPdf() async throws {
        let catalog = try await repository.loadCatalog()
        let stormcast = try XCTUnwrap(catalog.factions.first { $0.id == "stormcast-eternals" })
        let yndrasta = try XCTUnwrap(stormcast.armies.first { $0.id == "yndrastas-spearhead" })

        XCTAssertEqual(yndrasta.general, "Yndrasta, the Celestial Spear")
        XCTAssertEqual(yndrasta.battleTraitName, "Scions of the Storm")
        XCTAssertEqual(yndrasta.regimentAbilities.count, 2)
        XCTAssertEqual(yndrasta.enhancements.count, 4)
    }

    func testFactionsWithMultipleArmies() async throws {
        let catalog = try await repository.loadCatalog()
        let multiArmyFactions = catalog.factions.filter { $0.armies.count > 1 }
        XCTAssertGreaterThan(multiArmyFactions.count, 10)
    }

    func testArmyDetailOverlaysMergeAtLoadTime() async throws {
        let catalog = try await repository.loadCatalog()
        XCTAssertGreaterThanOrEqual(catalog.battleTrackerArmyCount, 48)

        let vigilant = try XCTUnwrap(
            catalog.factions.flatMap(\.armies).first { $0.id == "vigilant-brotherhood" }
        )
        XCTAssertTrue(vigilant.supportsBattleTracker)
        XCTAssertFalse(vigilant.units.isEmpty)
        XCTAssertEqual(vigilant.battleTraits.first?.phases, [.charge])
    }

    func testRatOgorsIncludeWarpfireGun() async throws {
        let catalog = try await repository.loadCatalog()
        let gnawfeast = try XCTUnwrap(
            catalog.factions.flatMap(\.armies).first { $0.id == "gnawfeast-clawpack" }
        )
        let ratOgors = try XCTUnwrap(gnawfeast.units.first { $0.id == "rat-ogors" })

        XCTAssertEqual(ratOgors.weapons.map(\.id), ["warpfire-gun", "claws-blades-fangs"])

        let warpfire = try XCTUnwrap(ratOgors.weapons.first { $0.id == "warpfire-gun" })
        XCTAssertEqual(warpfire.name, "Warpfire Gun")
        XCTAssertEqual(warpfire.rangeInches, 10)
        XCTAssertEqual(warpfire.attacks, "2D6")
        XCTAssertEqual(warpfire.modelsWithWeapon, 1)
        XCTAssertTrue(warpfire.isRollEvaluable)
        XCTAssertTrue(ratOgors.canShoot)
    }

    func testImportedArmiesDecodeWithMatchSetupLoadouts() async throws {
        let catalog = try await repository.loadCatalog()
        let crixxit = try XCTUnwrap(
            catalog.factions.first { $0.id == "skaven" }?
                .armies.first { $0.id == "crixxits-kill-pack" }
        )
        XCTAssertEqual(crixxit.regimentAbilities.count, 2)
        XCTAssertEqual(crixxit.enhancements.count, 4)
        XCTAssertFalse(crixxit.battleTraits.isEmpty)
    }

    func testDecodesMinimalFixture() async throws {
        let fixtureRepository = BundledSpearheadCatalogRepository(
            bundle: Bundle(for: BundledSpearheadCatalogRepositoryTests.self),
            resourceName: "spearhead-catalog-minimal"
        )
        let catalog = try await fixtureRepository.loadCatalog()
        XCTAssertEqual(catalog.factions.count, 1)
        XCTAssertEqual(catalog.factions[0].armies[0].id, "stub-army")
        XCTAssertEqual(catalog.matchSteps.count, 1)
    }
}
