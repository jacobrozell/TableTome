import XCTest
@testable import TabletomeDomain

final class WarscrollStatSummaryTests: XCTestCase {
    func testWeaponCombatProfileIncludesCoreStats() {
        let weapon = SpearheadWeapon(
            id: "hammer",
            name: "Grand Hammer",
            attacks: "2",
            hit: 3,
            wound: 3,
            rend: 2,
            damage: "2"
        )
        let profile = WarscrollStatSummary.weaponCombatProfile(weapon)
        XCTAssertTrue(profile.contains("A 2"))
        XCTAssertTrue(profile.contains("Hit 3+"))
        XCTAssertTrue(profile.contains("Wound 3+"))
        XCTAssertTrue(profile.contains("Rend 2"))
        XCTAssertTrue(profile.contains("Dmg 2"))
    }

    func testUnitChoiceSubtextShowsSaveAndWoundsPerModel() {
        let unit = SpearheadUnit(
            id: "unit",
            name: "Liberator",
            move: "5",
            save: 4,
            health: 2
        )
        let subtext = WarscrollStatSummary.unitChoiceSubtext(unit)
        XCTAssertEqual(subtext, "Save 4+ · 2 wounds/model")
    }

    func testUnitChoiceSubtextIncludesRemainingWounds() {
        let unit = SpearheadUnit(id: "unit", name: "Liberator", save: 4, health: 2, modelCount: 5)
        let subtext = WarscrollStatSummary.unitChoiceSubtext(unit, woundsRemaining: 7)
        XCTAssertTrue(subtext?.contains("7/10 wounds left") == true)
    }

    func testUnitPickerLabelUsesNameOnly() {
        let unit = SpearheadUnit(id: "unit", name: "Liberator", save: 4, health: 2)
        XCTAssertEqual(WarscrollStatSummary.unitPickerLabel(unit), "Liberator")
    }

    func testUnitPickerLabelMarksDestroyed() {
        let unit = SpearheadUnit(id: "unit", name: "Liberator", save: 4, health: 2)
        let label = WarscrollStatSummary.unitPickerLabel(unit, destroyed: true)
        XCTAssertTrue(label.contains("Liberator"))
        XCTAssertTrue(label.contains("Destroyed"))
    }
}
