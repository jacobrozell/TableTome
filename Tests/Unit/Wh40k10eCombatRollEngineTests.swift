import XCTest
@testable import TabletomeDomain

final class Wh40k10eCombatRollEngineTests: XCTestCase {
    func testHitFailsOnUnmodifiedOne() {
        let input = AttackRollInput(
            hitTarget: 3, woundTarget: 4, saveTarget: 4, rend: 2, damage: 1,
            hitRoll: 1, woundRoll: 4, saveRoll: 4
        )
        let result = Wh40k10eCombatRollEngine.evaluate(input)
        XCTAssertEqual(result.damageDealt, 0)
        XCTAssertEqual(result.steps.count, 1)
        XCTAssertEqual(result.steps[0].outcome, .failure)
    }

    func testUnmodifiedSixAutoHits() {
        let input = AttackRollInput(
            hitTarget: 2, woundTarget: 4, saveTarget: 4, rend: 0, damage: 1,
            hitRoll: 6, woundRoll: 1, saveRoll: 4
        )
        let result = Wh40k10eCombatRollEngine.evaluate(input)
        XCTAssertEqual(result.steps[0].outcome, .success)
        XCTAssertEqual(result.steps[1].outcome, .failure)
    }

    func testUnmodifiedSixAutoWounds() {
        let input = AttackRollInput(
            hitTarget: 3, woundTarget: 5, saveTarget: 3, rend: 0, damage: 2,
            hitRoll: 4, woundRoll: 6, saveRoll: 2
        )
        let result = Wh40k10eCombatRollEngine.evaluate(input)
        XCTAssertEqual(result.damageDealt, 2)
        XCTAssertEqual(result.steps[1].outcome, .success)
    }

    func testAPWorsensSave() {
        let saved = AttackRollInput(
            hitTarget: 3, woundTarget: 3, saveTarget: 3, rend: 2, damage: 1,
            hitRoll: 4, woundRoll: 4, saveRoll: 5
        )
        XCTAssertEqual(Wh40k10eCombatRollEngine.evaluate(saved).damageDealt, 0)

        let failed = AttackRollInput(
            hitTarget: 3, woundTarget: 3, saveTarget: 3, rend: 2, damage: 1,
            hitRoll: 4, woundRoll: 4, saveRoll: 4
        )
        XCTAssertEqual(Wh40k10eCombatRollEngine.evaluate(failed).damageDealt, 1)
        XCTAssertTrue(
            Wh40k10eCombatRollEngine.evaluate(failed).steps.first { $0.id == "save" }?
                .explanation.contains("AP 2") == true
        )
    }

    func testMortalDamageSkipsSave() {
        let input = AttackRollInput(
            hitTarget: 3, woundTarget: 3, saveTarget: 3, rend: 0, damage: 1,
            hitRoll: 4, woundRoll: 4, saveRoll: 6,
            mortalDamage: true
        )
        let result = Wh40k10eCombatRollEngine.evaluate(input)
        XCTAssertEqual(result.damageDealt, 1)
        XCTAssertTrue(result.steps.contains { $0.id == "save" && $0.explanation.contains("Mortal") })
    }

    func testRouterUsesWh40kEngineForCombatPatrol() {
        let input = AttackRollInput(
            hitTarget: 3, woundTarget: 3, saveTarget: 3, rend: 2, damage: 1,
            hitRoll: 4, woundRoll: 4, saveRoll: 4
        )
        let result = CombatRollEngineRouter.evaluate(input, gameSystemId: "wh40k-10e-cp")
        XCTAssertEqual(result.damageDealt, 1)
    }

    func testSaveNeededUsesAPNotRendSign() {
        let needed = CombatRollEngineRouter.saveNeededOnDice(
            saveTarget: 3,
            rend: 2,
            saveModifier: 0,
            gameSystemId: "wh40k-10e-cp"
        )
        XCTAssertEqual(needed, 5)
    }
}
