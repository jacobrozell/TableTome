import XCTest
@testable import TabletomeDomain

final class HobbyTagsTests: XCTestCase {
    func testExtractsLowercasedHashTags() {
        XCTAssertEqual(Tags.extract("on the table #wip #ToPaint"), ["wip", "topaint"])
    }

    func testIgnoresPlainText() {
        XCTAssertEqual(Tags.extract("no tags here"), [])
    }

    func testKeepsHyphensInsideTag() {
        XCTAssertEqual(Tags.extract("#kill-team has a hyphen"), ["kill-team"])
    }
}
