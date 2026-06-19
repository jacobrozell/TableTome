import XCTest
@testable import Tabletome

final class PillarSurfaceTests: XCTestCase {
    func testPlayAndRulesPillarsOnByDefault() {
        XCTAssertTrue(ReleaseSurface.showsPlayTab)
        XCTAssertTrue(ReleaseSurface.showsRulesTab)
    }

    func testBenchAndMusterPillarsVisibleDuringPort() {
        XCTAssertTrue(ReleaseSurface.showsBenchTab)
        XCTAssertTrue(ReleaseSurface.showsMusterTab)
    }

    func testCrossPillarLinksVisibleDuringPort() {
        XCTAssertTrue(ReleaseSurface.showsPlayFromRoster)
        XCTAssertTrue(ReleaseSurface.showsPaintStatusInMatch)
    }
}
