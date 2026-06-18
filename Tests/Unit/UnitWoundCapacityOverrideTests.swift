import XCTest
@testable import TabletomeDomain

final class UnitWoundCapacityOverrideTests: XCTestCase {
    func testHealthOverrideChangesCapacity() {
        let unit = SpearheadUnit(id: "rat-ogors", name: "Rat Ogors", health: 5, modelCount: 3)
        XCTAssertEqual(UnitWoundCapacity.capacity(for: unit), 15)
        XCTAssertEqual(UnitWoundCapacity.capacity(for: unit, healthPerModelOverride: 4), 12)
    }

    func testClearingOverrideUsesCatalogHealth() {
        let unit = SpearheadUnit(id: "rat-ogors", name: "Rat Ogors", health: 4, modelCount: 3)
        XCTAssertEqual(UnitWoundCapacity.capacity(for: unit, healthPerModelOverride: nil), 12)
    }
}

final class WarscrollTrustFeedbackTests: XCTestCase {
    func testReportTextIncludesUnitAndArmy() {
        let army = SpearheadArmy(
            id: "gnawfeast-clawpack",
            name: "Gnawfeast Clawpack",
            general: "General",
            tagline: "Tag",
            playstyle: "Play",
            unitCount: 1,
            units: [
                SpearheadUnit(id: "rat-ogors", name: "Rat Ogors", health: 4, modelCount: 3)
            ]
        )
        let unit = army.units[0]
        let text = WarscrollTrustFeedback.reportText(
            army: army,
            unit: unit,
            catalogHealthPerModel: 4,
            matchHealthOverride: 5
        )
        XCTAssertTrue(text.contains("Rat Ogors"))
        XCTAssertTrue(text.contains("Gnawfeast Clawpack"))
        XCTAssertTrue(text.contains("Match override health per model: 5"))
    }
}
