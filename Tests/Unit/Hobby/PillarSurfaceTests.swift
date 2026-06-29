import XCTest
@testable import Tabletome

final class PillarSurfaceTests: XCTestCase {
    func testPlayAndRulesPillarsOnByDefault() {
        XCTAssertTrue(ReleaseSurface.showsPlayTab)
        XCTAssertTrue(ReleaseSurface.showsRulesTab)
    }

    func testBenchVisibleMusterHiddenForRelease() {
        XCTAssertTrue(ReleaseSurface.showsBenchTab)
        XCTAssertFalse(ReleaseSurface.showsMusterTab)
    }

    func testPaintsVisibleForRelease() {
        XCTAssertTrue(ReleaseSurface.showsPaintsInBench)
    }

    func testCrossPillarLinksHiddenForRelease() {
        XCTAssertFalse(ReleaseSurface.showsPlayFromRoster)
        XCTAssertTrue(ReleaseSurface.showsPaintStatusInMatch)
    }
}
