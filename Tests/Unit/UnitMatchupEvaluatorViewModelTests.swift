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
}
