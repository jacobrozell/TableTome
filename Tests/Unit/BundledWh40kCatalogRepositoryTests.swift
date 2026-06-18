import XCTest
@testable import TabletomeData
@testable import TabletomeDomain

final class BundledWh40kCatalogRepositoryTests: XCTestCase {
    private var repository: BundledPlayCatalogRepository {
        BundledPlayCatalogRepository(bundle: Bundle(for: BundledWh40kCatalogRepositoryTests.self))
    }

    func testDecodesProductionCatalog() async throws {
        let catalog = try await repository.loadCatalog(for: "wh40k-11e")
        XCTAssertEqual(catalog.schemaVersion, 1)
        XCTAssertEqual(catalog.factions.count, 23)
        XCTAssertEqual(catalog.matchSteps.count, 6)
    }

    func testArmageddonArmiesExistWithDetails() async throws {
        let catalog = try await repository.loadCatalog(for: "wh40k-11e")
        let marines = try XCTUnwrap(catalog.factions.first { $0.id == "space-marines" })
        let orks = try XCTUnwrap(catalog.factions.first { $0.id == "orks" })

        let imperator = try XCTUnwrap(marines.armies.first { $0.id == "operation-imperator" })
        let waaagh = try XCTUnwrap(orks.armies.first { $0.id == "waaagh-armageddon" })

        XCTAssertEqual(imperator.unitCount, 23)
        XCTAssertEqual(waaagh.unitCount, 38)
        XCTAssertFalse(imperator.regimentAbilities.isEmpty)
        XCTAssertFalse(imperator.enhancements.isEmpty)
        XCTAssertFalse(imperator.units.isEmpty)
        XCTAssertFalse(waaagh.units.isEmpty)
        XCTAssertTrue(imperator.supportsBattleTracker)
        XCTAssertTrue(waaagh.supportsBattleTracker)
    }

    func testFeaturedArmiesApplyStarterMatchup() {
        var state = GuidedMatchState()
        FortyKFeaturedArmies.applyStarterMatchup(to: &state)
        XCTAssertEqual(state.playerOne.factionId, "space-marines")
        XCTAssertEqual(state.playerOne.armyId, "operation-imperator")
        XCTAssertEqual(state.playerTwo.factionId, "orks")
        XCTAssertEqual(state.playerTwo.armyId, "waaagh-armageddon")
    }
}
