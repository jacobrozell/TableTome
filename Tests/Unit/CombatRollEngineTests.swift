import XCTest
@testable import Tabletome
@testable import TabletomeDomain

final class CombatRollEngineTests: XCTestCase {
    func testHitFailsOnUnmodifiedOne() {
        let input = AttackRollInput(
            hitTarget: 3, woundTarget: 4, saveTarget: 4, rend: -1, damage: 1,
            hitRoll: 1, woundRoll: 4, saveRoll: 4
        )
        let result = CombatRollEngine.evaluate(input)
        XCTAssertEqual(result.damageDealt, 0)
        XCTAssertEqual(result.steps.count, 1)
        XCTAssertEqual(result.steps[0].outcome, .failure)
    }

    func testSuccessfulAttackDealsDamage() {
        let input = AttackRollInput(
            hitTarget: 3, woundTarget: 4, saveTarget: 5, rend: -1, damage: 2,
            hitRoll: 4, woundRoll: 5, saveRoll: 3
        )
        let result = CombatRollEngine.evaluate(input)
        XCTAssertEqual(result.damageDealt, 2)
        XCTAssertEqual(result.steps.count, 4)
    }

    func testHitModifierCappedAtPlusOne() {
        let input = AttackRollInput(
            hitTarget: 3, woundTarget: 4, saveTarget: 4, rend: 0, damage: 1,
            hitRoll: 2, woundRoll: 4, saveRoll: 4,
            hitModifier: 5
        )
        let result = CombatRollEngine.evaluate(input)
        XCTAssertTrue(result.steps[0].explanation.contains("capped"))
        XCTAssertEqual(result.steps[0].outcome, .success)
    }

    func testSaveSuccessPreventsDamage() {
        let input = AttackRollInput(
            hitTarget: 3, woundTarget: 3, saveTarget: 4, rend: 0, damage: 3,
            hitRoll: 4, woundRoll: 4, saveRoll: 5
        )
        let result = CombatRollEngine.evaluate(input)
        XCTAssertEqual(result.damageDealt, 0)
        XCTAssertEqual(result.steps.last?.id, "save")
    }
}
