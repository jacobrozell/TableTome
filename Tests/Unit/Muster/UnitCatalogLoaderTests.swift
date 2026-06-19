import XCTest
@testable import TabletomeDomain

final class UnitCatalogLoaderTests: XCTestCase {
    override func setUp() {
        super.setUp()
        UnitCatalogLoader.loadIfNeeded()
    }

    func testSearchFindsUnitByName() {
        let results = UnitCatalogLoader.search(game: "40k", faction: "Space Marines", query: "captain")

        XCTAssertTrue(results.contains { $0.id == "40k:space-marines:captain" })
    }

    func testSearchFindsUnitByAlias() {
        let results = UnitCatalogLoader.search(game: "40k", faction: "Space Marines", query: "intercessors")

        XCTAssertTrue(results.contains { $0.id == "40k:space-marines:intercessor-squad" })
    }

    func testSearchReturnsAllWhenQueryEmpty() {
        let filtered = UnitCatalogLoader.search(game: "40k", faction: "Space Marines", query: "captain")
        let all = UnitCatalogLoader.search(game: "40k", faction: "Space Marines", query: "")

        XCTAssertGreaterThan(all.count, filtered.count)
    }

    func testUnitLookupById() {
        let unit = UnitCatalogLoader.unit(id: "40k:space-marines:captain")

        XCTAssertEqual(unit?.name, "Captain")
        XCTAssertEqual(unit?.basePoints, 80)
    }
}
