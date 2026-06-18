import XCTest
@testable import TabletomeData
@testable import TabletomeDomain

final class SpearheadCatalogCompletenessTests: XCTestCase {
    func testAllLegalSpearheadsHaveRostersAndMatchSetup() async throws {
        let catalog = try await BundledSpearheadCatalogRepository().loadCatalog()
        let armies = catalog.factions.flatMap(\.armies)

        XCTAssertEqual(armies.count, 48, "Expected every legal AoS 4e Spearhead in the catalog")

        for army in armies {
            XCTAssertFalse(army.roster.isEmpty, "\(army.id) should list its fixed roster")
            XCTAssertFalse(army.general.isEmpty, "\(army.id) should name its general")
            XCTAssertEqual(army.unitCount, army.roster.count, "\(army.id) unitCount should match roster length")
            XCTAssertNotNil(army.officialRulesURL, "\(army.id) should link faction Spearhead rules")
            XCTAssertEqual(army.regimentAbilities.count, 2, "\(army.id) should offer 2 regiment abilities")
            XCTAssertEqual(army.enhancements.count, 4, "\(army.id) should offer 4 general enhancements")
        }

        let armyIds = Set(armies.map(\.id))
        XCTAssertTrue(armyIds.contains("zenestras-zealots"))
        XCTAssertTrue(armyIds.contains("tzaangor-warflocks"))
        XCTAssertTrue(armyIds.contains("spitewing-flight"))
        XCTAssertTrue(armyIds.contains("bubonic-cell"))
    }
}
