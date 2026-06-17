import XCTest
@testable import Tabletome
@testable import TabletomeData
@testable import TabletomeDomain

@MainActor
final class UnitMatchupEvaluatorViewModelTests: XCTestCase {
    func testLoadFeaturedArmiesAndDefaultOpposingSelection() async throws {
        let viewModel = UnitMatchupEvaluatorViewModel(
            catalogRepository: BundledSpearheadCatalogRepository(bundle: Bundle(for: type(of: self)))
        )
        await viewModel.load()

        XCTAssertEqual(viewModel.armies.count, 2)
        XCTAssertNotEqual(viewModel.attackerArmyId, viewModel.defenderArmyId)
        XCTAssertNotNil(viewModel.selectedAttackerUnit)
        XCTAssertNotNil(viewModel.selectedDefenderUnit)
    }

    func testPrefillAttackerUnit() async throws {
        let viewModel = UnitMatchupEvaluatorViewModel(
            catalogRepository: BundledSpearheadCatalogRepository(bundle: Bundle(for: type(of: self))),
            attackerPrefill: MatchupUnitPrefill(
                armyId: "vigilant-brotherhood",
                unitId: "liberators",
                weaponId: "warhammer"
            ),
            defenderPrefill: MatchupUnitPrefill(
                armyId: "gnawfeast-clawpack",
                unitId: "grey-seer"
            )
        )
        await viewModel.load()

        XCTAssertEqual(viewModel.attackerUnitId, "liberators")
        XCTAssertEqual(viewModel.defenderUnitId, "grey-seer")
        XCTAssertEqual(viewModel.evaluateDamageButtonTitle, "Evaluate Damage: Liberators vs Grey Seer")
    }

    func testEvaluateLiberatorVsGreySeer() async throws {
        let viewModel = UnitMatchupEvaluatorViewModel(
            catalogRepository: BundledSpearheadCatalogRepository(bundle: Bundle(for: type(of: self))),
            attackerPrefill: MatchupUnitPrefill(
                armyId: "vigilant-brotherhood",
                unitId: "liberators",
                weaponId: "warhammer"
            ),
            defenderPrefill: MatchupUnitPrefill(
                armyId: "gnawfeast-clawpack",
                unitId: "grey-seer"
            )
        )
        await viewModel.load()
        viewModel.hitRoll = 4
        viewModel.woundRoll = 4
        viewModel.saveRoll = 2

        viewModel.evaluate()

        XCTAssertNotNil(viewModel.evaluation)
        XCTAssertEqual(viewModel.evaluation?.damageDealt, 1)
    }

    func testRefreshEvaluationAutoResolvesLiberatorVsClanrat() async throws {
        let viewModel = UnitMatchupEvaluatorViewModel(
            catalogRepository: BundledSpearheadCatalogRepository(bundle: Bundle(for: type(of: self))),
            attackerPrefill: MatchupUnitPrefill(
                armyId: "vigilant-brotherhood",
                unitId: "liberators",
                weaponId: "warhammer"
            ),
            defenderPrefill: MatchupUnitPrefill(
                armyId: "gnawfeast-clawpack",
                unitId: "clanrats"
            )
        )
        await viewModel.load()
        viewModel.hitRoll = 6
        viewModel.woundRoll = 6
        viewModel.saveRoll = 1

        viewModel.refreshEvaluation()

        XCTAssertEqual(viewModel.attackerUnitId, "liberators")
        XCTAssertEqual(viewModel.defenderUnitId, "clanrats")
        XCTAssertNotNil(viewModel.evaluation)
        XCTAssertEqual(viewModel.evaluation?.damageDealt, 1)
    }

    func testRefreshEvaluationClearsWhenIncomplete() async throws {
        let viewModel = UnitMatchupEvaluatorViewModel(
            catalogRepository: BundledSpearheadCatalogRepository(bundle: Bundle(for: type(of: self)))
        )
        await viewModel.load()
        viewModel.attackerUnitId = ""

        viewModel.refreshEvaluation()

        XCTAssertNil(viewModel.evaluation)
    }

    func testSyncBattleContextSwapsArmiesWithActivePlayer() async throws {
        let viewModel = UnitMatchupEvaluatorViewModel(
            catalogRepository: BundledSpearheadCatalogRepository(bundle: Bundle(for: type(of: self)))
        )
        await viewModel.load()

        viewModel.syncBattleContext(
            activePlayerIsOne: true,
            playerOneArmyId: "vigilant-brotherhood",
            playerTwoArmyId: "gnawfeast-clawpack"
        )
        XCTAssertEqual(viewModel.attackerArmyId, "vigilant-brotherhood")
        XCTAssertEqual(viewModel.defenderArmyId, "gnawfeast-clawpack")

        viewModel.syncBattleContext(
            activePlayerIsOne: false,
            playerOneArmyId: "vigilant-brotherhood",
            playerTwoArmyId: "gnawfeast-clawpack"
        )
        XCTAssertEqual(viewModel.attackerArmyId, "gnawfeast-clawpack")
        XCTAssertEqual(viewModel.defenderArmyId, "vigilant-brotherhood")
    }

    func testRemembersUnitSelectionsPerArmy() async throws {
        MatchupSelectionMemory.resetAll()
        defer { MatchupSelectionMemory.resetAll() }

        let viewModel = UnitMatchupEvaluatorViewModel(
            catalogRepository: BundledSpearheadCatalogRepository(bundle: Bundle(for: type(of: self)))
        )
        await viewModel.load()

        viewModel.setAttackerArmy("vigilant-brotherhood")
        viewModel.setAttackerUnit("liberators")
        viewModel.setAttackerWeapon("warhammer")
        viewModel.setDefenderArmy("gnawfeast-clawpack")
        viewModel.setDefenderUnit("grey-seer")

        viewModel.setAttackerArmy("gnawfeast-clawpack")
        viewModel.setDefenderArmy("vigilant-brotherhood")

        viewModel.setAttackerArmy("vigilant-brotherhood")
        viewModel.setDefenderArmy("gnawfeast-clawpack")

        XCTAssertEqual(viewModel.attackerUnitId, "liberators")
        XCTAssertEqual(viewModel.attackerWeaponId, "warhammer")
        XCTAssertEqual(viewModel.defenderUnitId, "grey-seer")
    }
}
