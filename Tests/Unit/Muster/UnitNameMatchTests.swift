import XCTest
@testable import TabletomeDomain

final class UnitNameMatchTests: XCTestCase {
    func testNormalizeLowercasesAndCollapsesWhitespace() {
        XCTAssertEqual(UnitNameMatch.normalize("  Captain  "), "captain")
        XCTAssertEqual(UnitNameMatch.normalize("Intercessor   Squad"), "intercessor squad")
    }

    func testNormalizeStripsFirstParentheticalGroup() {
        XCTAssertEqual(UnitNameMatch.normalize("Intercessors (5)"), "intercessors")
        XCTAssertEqual(UnitNameMatch.normalize("Terminators (5) (Champions)"), "terminators (champions)")
    }

    func testMatchesExactCatalogName() {
        XCTAssertTrue(UnitNameMatch.matches(
            collectionUnitName: "Captain",
            catalogName: "Captain",
            aliases: []
        ))
    }

    func testMatchesAliasCaseInsensitively() {
        XCTAssertTrue(UnitNameMatch.matches(
            collectionUnitName: "intercessors",
            catalogName: "Intercessor Squad",
            aliases: ["Intercessors"]
        ))
    }

    func testMatchesPartialContainsEitherDirection() {
        XCTAssertTrue(UnitNameMatch.matches(
            collectionUnitName: "Assault Intercessors with Jump Packs",
            catalogName: "Assault Intercessors",
            aliases: []
        ))
    }

    func testMatchesRejectsEmptyCollectionName() {
        XCTAssertFalse(UnitNameMatch.matches(
            collectionUnitName: "   ",
            catalogName: "Captain",
            aliases: []
        ))
    }
}
