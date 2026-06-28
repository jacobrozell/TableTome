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

        XCTAssertTrue(imperator.units.allSatisfy(\.hasWarscroll))
        XCTAssertTrue(waaagh.units.allSatisfy(\.hasWarscroll))
        XCTAssertTrue(imperator.units.allSatisfy { !$0.weapons.isEmpty })
        XCTAssertTrue(waaagh.units.allSatisfy { !$0.weapons.isEmpty })
    }

    func testBattleforceArmiesExistWithDetails() async throws {
        let catalog = try await repository.loadCatalog(for: "wh40k-11e")
        let battleforces: [(faction: String, army: String)] = [
            ("astra-militarum", "astra-militarum-platoon"),
            ("tyranids", "tyranid-swarm"),
            ("chaos-space-marines", "chaos-space-marines-warband"),
            ("necrons", "necron-host")
        ]

        for entry in battleforces {
            let faction = try XCTUnwrap(catalog.factions.first { $0.id == entry.faction })
            let army = try XCTUnwrap(faction.armies.first { $0.id == entry.army })
            XCTAssertFalse(army.roster.isEmpty)
            XCTAssertFalse(army.units.isEmpty)
            XCTAssertTrue(army.supportsBattleTracker)
        }

        XCTAssertEqual(catalog.battleTrackerArmyCount, 6)
    }

    func testFeaturedArmiesApplyStarterMatchup() {
        var state = GuidedMatchState()
        GuidedMatchFeaturedArmies.resolved(for: .wh40k11e).applyStarterMatchup(to: &state)
        XCTAssertEqual(state.playerOne.factionId, "space-marines")
        XCTAssertEqual(state.playerOne.armyId, "operation-imperator")
        XCTAssertEqual(state.playerTwo.factionId, "orks")
        XCTAssertEqual(state.playerTwo.armyId, "waaagh-armageddon")
    }
}
