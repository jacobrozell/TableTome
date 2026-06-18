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

    func testWh40k10eCpVisibleInRelease() {
        let system = GameSystem(
            id: "wh40k-10e-cp",
            name: "Combat Patrol",
            tagline: "",
            edition: "10th Edition",
            availability: .available,
            gettingStartedSteps: [],
            ruleSections: []
        )
        XCTAssertTrue(ReleaseSurface.isGameSystemVisible(system))
    }

    func test40k10eHiddenWithoutLaunchArg() {
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

    func testWh40k11eVisibleInRelease() {
        let system = GameSystem(
            id: "wh40k-11e",
            name: "Warhammer 40,000",
            tagline: "",
            edition: "11th Edition",
            availability: .available,
            gettingStartedSteps: [],
            ruleSections: []
        )
        XCTAssertTrue(ReleaseSurface.isGameSystemVisible(system))
    }

    func testShowsNewEditionBadgeForWh40k11e() {
        XCTAssertTrue(ReleaseSurface.showsNewEditionBadge(for: "wh40k-11e"))
        XCTAssertFalse(ReleaseSurface.showsNewEditionBadge(for: "aos-spearhead"))
    }

    func testGuidedMatchForSpearheadAnd40k11e() {
        XCTAssertTrue(ReleaseSurface.showsGuidedMatch(for: "aos-spearhead"))
        XCTAssertTrue(ReleaseSurface.showsGuidedMatch(for: "wh40k-11e"))
        XCTAssertTrue(ReleaseSurface.showsGuidedMatch(for: "wh40k-10e-cp"))
        XCTAssertTrue(ReleaseSurface.showsGuidedMatch(for: "sc-tmg"))
        XCTAssertFalse(ReleaseSurface.showsGuidedMatch(for: "wh40k-10e"))
    }

    func testScTmgVisibleInRelease() {
        let system = GameSystem(
            id: "sc-tmg",
            name: "StarCraft",
            tagline: "",
            edition: "",
            availability: .available,
            gettingStartedSteps: [],
            ruleSections: []
        )
        XCTAssertTrue(ReleaseSurface.isGameSystemVisible(system))
    }

    func testRollEvaluatorEnabledInRelease() {
        XCTAssertTrue(ReleaseSurface.showsRollEvaluator)
        XCTAssertTrue(ReleaseSurface.showsRulesAssistant)
        XCTAssertTrue(ReleaseSurface.showsMatchHistory)
    }

    func testCombatResolverEnabledForCombatPatrol() {
        XCTAssertTrue(ReleaseSurface.showsCombatResolver(for: "wh40k-10e-cp"))
        XCTAssertTrue(ReleaseSurface.showsCombatResolver(for: "aos-spearhead"))
    }

    func testCombatResolverHiddenForWh40k11eByDefault() {
        XCTAssertFalse(ReleaseSurface.showsCombatResolver(for: "wh40k-11e"))
    }

    func testWh40kCombatResolverGateRequiresLaunchArg() {
        XCTAssertFalse(ReleaseSurface.showsWh40kCombatResolver)
    }
}
