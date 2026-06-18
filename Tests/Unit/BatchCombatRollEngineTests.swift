import XCTest
@testable import TabletomeDomain

final class BatchCombatRollEngineTests: XCTestCase {
    func testFixedDamageBatch() {
        let evaluation = BatchCombatRollEngine.evaluate(
            BatchCombatRollInput(
                successfulHits: 10,
                successfulWounds: 4,
                failedSaves: 2,
                damagePerWound: 3
            )
        )
        XCTAssertEqual(evaluation.totalDamage, 6)
        XCTAssertTrue(evaluation.summarySteps.contains { $0.id == "damage" })
    }

    func testMortalDamageSkipsSaveRolls() {
        let evaluation = BatchCombatRollEngine.evaluate(
            BatchCombatRollInput(
                successfulHits: 5,
                successfulWounds: 3,
                failedSaves: 0,
                damagePerWound: 2,
                mortalDamage: true
            )
        )
        XCTAssertEqual(evaluation.totalDamage, 6)
    }

    func testWardReducesDamageInstances() {
        let evaluation = BatchCombatRollEngine.evaluate(
            BatchCombatRollInput(
                successfulHits: 6,
                successfulWounds: 4,
                failedSaves: 3,
                damagePerWound: 2,
                wardNegatedCount: 1
            )
        )
        XCTAssertEqual(evaluation.totalDamage, 4)
    }

    func testManualTotalDamageOverride() {
        let evaluation = BatchCombatRollEngine.evaluate(
            BatchCombatRollInput(
                successfulHits: 2,
                successfulWounds: 2,
                failedSaves: 2,
                damagePerWound: 1,
                manualTotalDamage: 7
            )
        )
        XCTAssertEqual(evaluation.totalDamage, 7)
    }

    func testClampsWoundsToHitsAndFailedSavesToWounds() {
        let evaluation = BatchCombatRollEngine.evaluate(
            BatchCombatRollInput(
                successfulHits: 2,
                successfulWounds: 9,
                failedSaves: 9,
                damagePerWound: 1
            )
        )
        XCTAssertEqual(evaluation.totalDamage, 2)
    }

    func testSaveNeededOnDiceWithRend() {
        XCTAssertEqual(
            BatchCombatRollEngine.saveNeededOnDice(saveTarget: 6, rend: 2, saveModifier: 0),
            4
        )
        XCTAssertEqual(
            BatchCombatRollEngine.saveNeededOnDice(saveTarget: 6, rend: 2, saveModifier: -1),
            5
        )
    }
}
