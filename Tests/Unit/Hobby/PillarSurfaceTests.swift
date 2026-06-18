import XCTest
@testable import Tabletome

final class PillarSurfaceTests: XCTestCase {
    func testPlayAndRulesPillarsOnByDefault() {
        XCTAssertTrue(ReleaseSurface.showsPlayTab)
        XCTAssertTrue(ReleaseSurface.showsRulesTab)
    }

    func testBenchAndMusterPillarsHiddenWithoutLaunchArg() {
        XCTAssertFalse(ReleaseSurface.showsBenchTab)
        XCTAssertFalse(ReleaseSurface.showsMusterTab)
    }

    func testCrossPillarLinksHiddenWithoutLaunchArg() {
        XCTAssertFalse(ReleaseSurface.showsPlayFromRoster)
        XCTAssertFalse(ReleaseSurface.showsPaintStatusInMatch)
    }
}
