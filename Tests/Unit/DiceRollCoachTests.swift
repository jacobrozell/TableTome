import XCTest
@testable import TabletomeDomain

final class DiceRollCoachTests: XCTestCase {
    private func sampleInput(
        hitRoll: Int = 4,
        woundRoll: Int = 4,
        saveRoll: Int = 4,
        wardRoll: Int? = nil,
        wardTarget: Int? = nil
    ) -> AttackRollInput {
        AttackRollInput(
            hitTarget: 4,
            woundTarget: 4,
            saveTarget: 4,
            rend: -1,
            damage: 1,
            hitRoll: hitRoll,
            woundRoll: woundRoll,
            saveRoll: saveRoll,
            hitModifier: 0,
            woundModifier: 0,
            saveModifier: 0,
            wardTarget: wardTarget,
            wardRoll: wardRoll,
            critAutoWound: false,
            critMortal: false,
            mortalDamage: false
        )
    }

    func testHitHintFailsOnNaturalOne() {
        let hint = DiceRollCoach.hitHint(input: sampleInput(hitRoll: 1))
        XCTAssertFalse(hint.passed)
        XCTAssertTrue(hint.text.localizedCaseInsensitiveContains("1"))
    }

    func testHitHintPassesAtTarget() {
        let hint = DiceRollCoach.hitHint(input: sampleInput(hitRoll: 4))
        XCTAssertTrue(hint.passed)
        XCTAssertTrue(hint.text.localizedCaseInsensitiveContains("Pass"))
    }

    func testWoundHintFailsBelowTarget() {
        let hint = DiceRollCoach.woundHint(input: sampleInput(woundRoll: 3))
        XCTAssertFalse(hint.passed)
    }

    func testSaveHintAccountsForRend() {
        let input = sampleInput(saveRoll: 4)
        let hint = DiceRollCoach.saveHint(input: input)
        XCTAssertFalse(hint.passed)
    }

    func testWardHintWhenPresent() {
        let hint = DiceRollCoach.wardHint(input: sampleInput(wardRoll: 5, wardTarget: 5))
        XCTAssertNotNil(hint)
        XCTAssertTrue(hint?.passed == true)
    }

    func testWardHintNilWithoutTarget() {
        XCTAssertNil(DiceRollCoach.wardHint(input: sampleInput()))
    }
}
