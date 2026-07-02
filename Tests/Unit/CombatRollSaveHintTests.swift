import XCTest
@testable import TabletomeDomain

final class CombatRollSaveHintTests: XCTestCase {
    func testSaveThreePlusRendOneNeedsFourOnDice() {
        let needed = CombatRollResolution.saveNeededOnDice(saveTarget: 3, rend: 1, saveModifier: 0)
        XCTAssertEqual(needed, 4)
    }

    func testSaveHintExampleStringUsesFourPlus() {
        let saveTarget = 3
        let rend = 1
        let needed = CombatRollResolution.saveNeededOnDice(saveTarget: saveTarget, rend: rend, saveModifier: 0)
        let hint = String(
            localized: "Save \(saveTarget)+ vs Rend +\(rend) — roll \(needed)+ or higher on each save dice."
        )
        XCTAssertTrue(hint.contains("4"))
        XCTAssertFalse(hint.contains("2+"))
    }

    func testBatchSaveReferenceLineSaveThreePlusRendOne() {
        let needed = CombatRollResolution.saveNeededOnDice(saveTarget: 3, rend: 1, saveModifier: 0)
        let line = BatchCombatSaveHint.saveReferenceLine(
            saveTarget: 3,
            rend: 1,
            saveNeededOnDice: needed,
            usesWh40kRules: false
        )
        XCTAssertTrue(line.contains("Save 3+"))
        XCTAssertTrue(line.contains("Rend +1"))
        XCTAssertTrue(line.contains("4+"))
        XCTAssertFalse(line.contains("2+"))
    }
}
