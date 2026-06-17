import XCTest
@testable import TabletomeDomain

final class WarscrollSheetCatalogTests: XCTestCase {
    func testSheetImageURLReturnsNilWhenMissing() {
        XCTAssertNil(
            WarscrollSheetCatalog.sheetImageURL(
                armyId: "missing-army",
                unitId: "missing-unit",
                bundle: .main
            )
        )
    }

    func testHasSheetImageIsFalseWhenMissing() {
        XCTAssertFalse(
            WarscrollSheetCatalog.hasSheetImage(
                armyId: "missing-army",
                unitId: "missing-unit",
                bundle: .main
            )
        )
    }

    func testSheetImageURLReturnsNilForEmptyIds() {
        XCTAssertNil(WarscrollSheetCatalog.sheetImageURL(armyId: "", unitId: "unit"))
        XCTAssertNil(WarscrollSheetCatalog.sheetImageURL(armyId: "army", unitId: ""))
    }
}
