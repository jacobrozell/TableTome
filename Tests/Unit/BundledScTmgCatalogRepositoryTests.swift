import XCTest
@testable import TabletomeData
@testable import TabletomeDomain

final class BundledScTmgCatalogRepositoryTests: XCTestCase {
    private var repository: BundledPlayCatalogRepository {
        BundledPlayCatalogRepository(bundle: Bundle(for: BundledScTmgCatalogRepositoryTests.self))
    }

    func testDecodesProductionCatalog() async throws {
        let catalog = try await repository.loadCatalog(for: "sc-tmg")
        XCTAssertEqual(catalog.schemaVersion, 1)
        XCTAssertEqual(catalog.factions.count, 3)
        XCTAssertEqual(catalog.matchSteps.count, 7)
    }

    func testFoundersEditionArmiesExist() async throws {
        let catalog = try await repository.loadCatalog(for: "sc-tmg")
        let armies = catalog.factions.flatMap(\.armies)
        XCTAssertTrue(armies.contains { $0.id == "raynors-raiders" })
        XCTAssertTrue(armies.contains { $0.id == "kerrigans-swarm" })
    }

    func testStarterMatchupFeaturedArmies() {
        XCTAssertTrue(ScTmgFeaturedArmies.isFeatured("raynors-raiders"))
        XCTAssertTrue(ScTmgFeaturedArmies.isFeatured("kerrigans-swarm"))
        XCTAssertFalse(ScTmgFeaturedArmies.isFeatured("artanis-host"))
    }
}

final class ScTmgBattleRulesTests: XCTestCase {
    func testMainPhasesExcludeSpearheadPhases() {
        XCTAssertEqual(
            BattleRules.mainPhases(gameSystemId: "sc-tmg"),
            [BattleTurnPhase.movement, .assault, .combat, .scoring]
        )
    }

    func testFiveRoundBattle() {
        XCTAssertEqual(BattleRules.battleRoundCount(gameSystemId: "sc-tmg"), 5)
    }

    func testInitialPhaseIsMovement() {
        XCTAssertEqual(BattleRules.initialPhase(gameSystemId: "sc-tmg"), .movement)
    }
}
