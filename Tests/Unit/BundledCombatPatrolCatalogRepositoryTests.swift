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

    func testAllPatrolsExistWithRosterMetadata() async throws {
        let catalog = try await repository.loadCatalog(for: "wh40k-10e-cp")
        let armies = catalog.factions.flatMap(\.armies)
        XCTAssertEqual(armies.count, 23)

        for army in armies {
            XCTAssertEqual(army.enhancements.count, 2, army.id)
            XCTAssertEqual(army.secondaryObjectives.count, 2, army.id)
            XCTAssertEqual(army.stratagems.count, 3, army.id)
            XCTAssertFalse(army.roster.isEmpty, army.id)
        }

        let leviathanIds = ["space-marines-combat-patrol", "tyranids-combat-patrol"]
        let p1Ids = [
            "orks-combat-patrol",
            "necrons-combat-patrol",
            "adeptus-custodes-combat-patrol",
            "astra-militarum-combat-patrol"
        ]
        let fullTrackerIds = leviathanIds + p1Ids + armies.map(\.id).filter { id in
            !(leviathanIds + p1Ids).contains(id)
        }

        for armyId in fullTrackerIds {
            let army = try XCTUnwrap(armies.first { $0.id == armyId })
            XCTAssertTrue(army.supportsBattleTracker, armyId)
            XCTAssertTrue(army.units.contains { $0.hasWarscroll }, armyId)
        }

        let rosterOnlyCount = armies.filter { !$0.supportsBattleTracker }.count
        XCTAssertEqual(rosterOnlyCount, 0)
    }

    func testMissionsIncludeClashOfPatrols() async throws {
        let catalog = try await repository.loadCatalog(for: "wh40k-10e-cp")
        let clash = try XCTUnwrap(catalog.missions.first { $0.id == "clash-of-patrols" })
        XCTAssertEqual(clash.d6Result, 1)
        XCTAssertEqual(clash.recommendedForFirstGame, true)
    }

    func testFeaturedArmiesApplyStarterMatchup() {
        var state = GuidedMatchState()
        GuidedMatchFeaturedArmies.resolved(for: .wh40k10eCp).applyStarterMatchup(to: &state)
        XCTAssertEqual(state.playerOne.factionId, "space-marines")
        XCTAssertEqual(state.playerOne.armyId, "space-marines-combat-patrol")
        XCTAssertEqual(state.playerTwo.factionId, "tyranids")
        XCTAssertEqual(state.playerTwo.armyId, "tyranids-combat-patrol")
        XCTAssertEqual(state.selectedMissionId, "clash-of-patrols")
    }
}
