import XCTest
@testable import TabletomeDomain

final class Wh40k11eCombatRollEngineTests: XCTestCase {
    func testRouterUsesDedicated11eEngineNotCombatPatrol() {
        let input = AttackRollInput(
            hitTarget: 3, woundTarget: 3, saveTarget: 3, rend: 2, damage: 1,
            hitRoll: 4, woundRoll: 4, saveRoll: 4
        )
        let cpResult = CombatRollEngineRouter.evaluate(input, gameSystemId: "wh40k-10e-cp")
        let eleventhResult = CombatRollEngineRouter.evaluate(input, gameSystemId: "wh40k-11e")
        XCTAssertEqual(cpResult.damageDealt, 1)
        XCTAssertEqual(eleventhResult.damageDealt, 1)
        XCTAssertEqual(CombatRollEngineRouter.rulesEdition(for: "wh40k-10e-cp"), .wh40k10e)
        XCTAssertEqual(CombatRollEngineRouter.rulesEdition(for: "wh40k-11e"), .wh40k11e)
    }

    func testArmourSaveStepLabel() {
        let input = AttackRollInput(
            hitTarget: 3, woundTarget: 3, saveTarget: 3, rend: 0, damage: 1,
            hitRoll: 4, woundRoll: 4, saveRoll: 2
        )
        let result = Wh40k11eCombatRollEngine.evaluate(input)
        XCTAssertEqual(result.steps.first { $0.id == "save" }?.name, "Armour Save")
    }

    func testInvulnerableSavePreventsDamageWhenArmourFails() {
        let input = AttackRollInput(
            hitTarget: 3, woundTarget: 3, saveTarget: 3, rend: 2, damage: 1,
            hitRoll: 4, woundRoll: 4, saveRoll: 2,
            wardTarget: 4, wardRoll: 4
        )
        let result = Wh40k11eCombatRollEngine.evaluate(input)
        XCTAssertEqual(result.damageDealt, 0)
        XCTAssertEqual(result.steps.first { $0.id == "invuln" }?.name, "Invulnerable Save")
    }

    func testDamageWhenBothSavesFail() {
        let input = AttackRollInput(
            hitTarget: 3, woundTarget: 3, saveTarget: 3, rend: 2, damage: 2,
            hitRoll: 4, woundRoll: 4, saveRoll: 2,
            wardTarget: 4, wardRoll: 2
        )
        let result = Wh40k11eCombatRollEngine.evaluate(input)
        XCTAssertEqual(result.damageDealt, 2)
    }
}
