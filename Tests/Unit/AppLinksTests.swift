import XCTest
@testable import Tabletome

final class AppLinksTests: XCTestCase {
    func testPagesURLsUseGitHubPagesHost() {
        XCTAssertEqual(AppLinks.privacy.host, "jacobrozell.github.io")
        XCTAssertEqual(AppLinks.support.host, "jacobrozell.github.io")
        XCTAssertEqual(AppLinks.accessibility.host, "jacobrozell.github.io")
        XCTAssertTrue(AppLinks.privacy.path.hasSuffix("privacy.html"))
    }

    func testSourceRepositoryURL() {
        XCTAssertEqual(AppLinks.sourceRepository.host, "github.com")
        XCTAssertTrue(AppLinks.sourceRepository.path.contains("TableTome"))
    }
}
