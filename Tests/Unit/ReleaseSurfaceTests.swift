import XCTest
@testable import Tabletome
@testable import TabletomeDomain

final class ReleaseSurfaceTests: XCTestCase {
    func testSpearheadVisibleInRelease() {
        let system = GameSystem(
            id: "aos-spearhead",
            name: "Spearhead",
            tagline: "",
            edition: "",
            availability: .available,
            gettingStartedSteps: [],
            ruleSections: []
        )
        XCTAssertTrue(ReleaseSurface.isGameSystemVisible(system))
    }

    func test40kHiddenWithoutLaunchArg() {
        let system = GameSystem(
            id: "wh40k-10e",
            name: "40k",
            tagline: "",
            edition: "",
            availability: .comingSoon,
            gettingStartedSteps: [],
            ruleSections: []
        )
        XCTAssertFalse(ReleaseSurface.isGameSystemVisible(system))
    }

    func testRollEvaluatorGatedOff() {
        XCTAssertFalse(ReleaseSurface.showsRollEvaluator)
        XCTAssertFalse(ReleaseSurface.showsRulesAssistant)
    }
}
