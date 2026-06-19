import XCTest
@testable import Tabletome
@testable import TabletomeData
@testable import TabletomeDomain

@MainActor
final class BatchCombatEvaluatorViewModelTests: XCTestCase {
    func testSyncClearsEvaluationWhenMatchupIncomplete() async {
        let matchup = UnitMatchupEvaluatorViewModel(
            catalogRepository: BundledSpearheadCatalogRepository(bundle: Bundle(for: type(of: self)))
        )
        await matchup.load()
        matchup.attackerArmyId = ""
        matchup.defenderArmyId = ""

        let batch = BatchCombatEvaluatorViewModel()
        batch.sync(from: matchup)

        XCTAssertNil(batch.evaluation)
    }

    func testEvaluateComputesDamageFromCounts() {
        let batch = BatchCombatEvaluatorViewModel()
        batch.successfulHits = 1
        batch.successfulWounds = 1
        batch.failedSaves = 1
        batch.damagePerWound = 2

        batch.evaluate()

        XCTAssertEqual(batch.evaluation?.totalDamage, 2)
    }

    func testClampCountsLimitsToHitDice() async {
        let matchup = UnitMatchupEvaluatorViewModel(
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
        await matchup.load()

        let batch = BatchCombatEvaluatorViewModel()
        batch.sync(from: matchup)
        let hitDice = batch.hitDiceCount
        batch.successfulHits = hitDice + 3
        batch.successfulWounds = hitDice + 3
        batch.failedSaves = hitDice + 3
        batch.damagePerWound = 1

        batch.evaluate()

        XCTAssertEqual(batch.evaluation?.totalDamage, hitDice)
    }

    func testSyncFromLoadedMatchupPopulatesSaveTarget() async throws {
        let matchup = UnitMatchupEvaluatorViewModel(
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
        await matchup.load()

        let batch = BatchCombatEvaluatorViewModel()
        batch.sync(from: matchup)

        XCTAssertNotNil(batch.evaluation)
        XCTAssertGreaterThan(batch.hitDiceCount, 0)
        XCTAssertGreaterThan(batch.saveTarget, 0)
    }
}
