import XCTest
@testable import TabletomeData
@testable import TabletomeDomain

final class BundledCombatPatrolCatalogRepositoryTests: XCTestCase {
    private var repository: BundledPlayCatalogRepository {
        BundledPlayCatalogRepository(bundle: Bundle(for: BundledCombatPatrolCatalogRepositoryTests.self))
    }

    func testDecodesProductionCatalog() async throws {
        let catalog = try await repository.loadCatalog(for: "wh40k-10e-cp")
        XCTAssertEqual(catalog.schemaVersion, 1)
        XCTAssertEqual(catalog.factions.count, 23)
        XCTAssertEqual(catalog.matchSteps.count, 8)
        XCTAssertEqual(catalog.missions.count, 6)
    }

    func testLeviathanArmiesExistWithLoadouts() async throws {
        let catalog = try await repository.loadCatalog(for: "wh40k-10e-cp")
        let marines = try XCTUnwrap(catalog.factions.first { $0.id == "space-marines" })
        let tyranids = try XCTUnwrap(catalog.factions.first { $0.id == "tyranids" })

        let octavius = try XCTUnwrap(marines.armies.first { $0.id == "space-marines-combat-patrol" })
        let vardenghast = try XCTUnwrap(tyranids.armies.first { $0.id == "tyranids-combat-patrol" })

        XCTAssertEqual(octavius.enhancements.count, 2)
        XCTAssertEqual(octavius.secondaryObjectives.count, 2)
        XCTAssertEqual(octavius.stratagems.count, 3)
        XCTAssertEqual(vardenghast.enhancements.count, 2)
        XCTAssertEqual(vardenghast.secondaryObjectives.count, 2)
        XCTAssertEqual(vardenghast.stratagems.count, 3)
        XCTAssertFalse(octavius.units.isEmpty)
        XCTAssertFalse(vardenghast.units.isEmpty)
        XCTAssertTrue(octavius.units.contains { $0.hasWarscroll })
        XCTAssertTrue(vardenghast.units.contains { $0.hasWarscroll })
        XCTAssertTrue(octavius.supportsBattleTracker)
        XCTAssertTrue(vardenghast.supportsBattleTracker)
    }

    func testMissionsIncludeClashOfPatrols() async throws {
        let catalog = try await repository.loadCatalog(for: "wh40k-10e-cp")
        let clash = try XCTUnwrap(catalog.missions.first { $0.id == "clash-of-patrols" })
        XCTAssertEqual(clash.d6Result, 1)
        XCTAssertEqual(clash.recommendedForFirstGame, true)
    }

    func testFeaturedArmiesApplyStarterMatchup() {
        var state = GuidedMatchState()
        CombatPatrolFeaturedArmies.applyStarterMatchup(to: &state)
        XCTAssertEqual(state.playerOne.factionId, "space-marines")
        XCTAssertEqual(state.playerOne.armyId, "space-marines-combat-patrol")
        XCTAssertEqual(state.playerTwo.factionId, "tyranids")
        XCTAssertEqual(state.playerTwo.armyId, "tyranids-combat-patrol")
        XCTAssertEqual(state.selectedMissionId, "clash-of-patrols")
    }
}
