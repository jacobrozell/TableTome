import XCTest
@testable import Tabletome

final class AppDeepLinkTests: XCTestCase {
    func testCollectionBacklogURL() {
        let destination = AppDeepLink.destination(from: AppDeepLink.collectionBacklogURL)
        XCTAssertEqual(destination, .collectionBacklog)
    }

    func testMusterHomeURL() {
        let url = URL(string: "minimuster://muster")!
        XCTAssertEqual(AppDeepLink.destination(from: url), .musterHome)
    }

    func testMusterRosterURL() {
        let id = UUID(uuidString: "A1B2C3D4-E5F6-7890-ABCD-EF1234567890")!
        let url = AppDeepLink.musterURL(rosterId: id)
        XCTAssertEqual(AppDeepLink.destination(from: url), .musterRoster(id))
    }

    func testInvalidSchemeIgnored() {
        let url = URL(string: "https://example.com/muster")!
        XCTAssertNil(AppDeepLink.destination(from: url))
    }
}
