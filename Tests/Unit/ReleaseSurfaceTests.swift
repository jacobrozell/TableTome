import XCTest
@testable import Tabletome
@testable import TabletomeData
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

    func testGuidedMatchForSpearhead40k11eAndCombatPatrolInRelease() {
        XCTAssertTrue(ReleaseSurface.showsGuidedMatch(for: "aos-spearhead"))
        XCTAssertTrue(ReleaseSurface.showsGuidedMatch(for: "wh40k-11e"))
        XCTAssertTrue(ReleaseSurface.showsGuidedMatch(for: "wh40k-10e-cp"))
        XCTAssertFalse(ReleaseSurface.showsGuidedMatch(for: "sc-tmg"))
        XCTAssertFalse(ReleaseSurface.showsGuidedMatch(for: "wh40k-10e"))
    }

    func testScTmgHiddenInRelease() {
        let system = GameSystem(
            id: "sc-tmg",
            name: "StarCraft",
            tagline: "",
            edition: "",
            availability: .available,
            gettingStartedSteps: [],
            ruleSections: []
        )
        XCTAssertFalse(ReleaseSurface.isGameSystemVisible(system))
    }

    func testReleasePlayFeatures() {
        XCTAssertTrue(ReleaseSurface.showsRollEvaluator)
        XCTAssertFalse(ReleaseSurface.showsRulesAssistant)
        XCTAssertTrue(ReleaseSurface.showsMatchHistory)
    }

    func testCombatResolverEnabledForSpearhead() {
        XCTAssertTrue(ReleaseSurface.showsCombatResolver(for: "aos-spearhead"))
    }

    func testCombatResolverEnabledForCombatPatrolInRelease() {
        XCTAssertTrue(ReleaseSurface.showsCombatResolver(for: "wh40k-10e-cp"))
    }

    func testCombatResolverEnabledForWh40k11eInRelease() {
        XCTAssertTrue(ReleaseSurface.showsCombatResolver(for: "wh40k-11e"))
    }

    func testCombatPatrolVisibleInRelease() {
        XCTAssertTrue(ReleaseSurface.showsCombatPatrol)
    }

    func testReleaseTabs() {
        XCTAssertTrue(ReleaseSurface.showsBenchTab)
        XCTAssertFalse(ReleaseSurface.showsMusterTab)
        XCTAssertTrue(ReleaseSurface.showsPaintsInBench)
        XCTAssertTrue(ReleaseSurface.showsPlayTab)
        XCTAssertTrue(ReleaseSurface.showsRulesTab)
    }

    func testReleaseDefaultVisibleGameSystems() async throws {
        let repo = BundledRulesRepository(bundle: Bundle(for: ReleaseSurfaceTests.self))
        let bundle = try await repo.loadBundle()
        let visibleIds = Set(
            bundle.gameSystems
                .filter { ReleaseSurface.isGameSystemVisible($0) }
                .map(\.id)
        )
        XCTAssertEqual(
            visibleIds,
            Set([
                GameSystemId.aosSpearhead.rawValue,
                GameSystemId.wh40k11e.rawValue,
                GameSystemId.wh40k10eCp.rawValue
            ])
        )
    }

    func testCombatPatrolVisibleWithoutLaunchArguments() {
        let args = ProcessInfo.processInfo.arguments
        XCTAssertFalse(args.contains("-enable_combat_patrol"))
        XCTAssertFalse(args.contains("-enable_full_product_surface"))
        XCTAssertFalse(args.contains("-enable_all_play_modes"))
        XCTAssertTrue(ReleaseSurface.showsCombatPatrol)
        XCTAssertTrue(ReleaseSurface.isGameSystemIdVisible(GameSystemId.wh40k10eCp.rawValue))
        XCTAssertTrue(ReleaseSurface.showsGuidedMatch(for: GameSystemId.wh40k10eCp.rawValue))
        XCTAssertTrue(ReleaseSurface.showsCombatResolver(for: GameSystemId.wh40k10eCp.rawValue))
    }

    func testPlayHomeShowsSpearheadOnlyByDefault() {
        XCTAssertFalse(ReleaseSurface.showsAllPlayModesOnHome)
        XCTAssertTrue(ReleaseSurface.isPlayHomeGameSystemVisible(GameSystemId.aosSpearhead.rawValue))
        XCTAssertFalse(ReleaseSurface.isPlayHomeGameSystemVisible(GameSystemId.wh40k11e.rawValue))
        XCTAssertFalse(ReleaseSurface.isPlayHomeGameSystemVisible(GameSystemId.wh40k10eCp.rawValue))
    }

    func testPlayHomeIncludesAllBundledModesWhenAllPlayModesEnabled() {
        guard ProcessInfo.processInfo.arguments.contains("-enable_all_play_modes")
            || ProcessInfo.processInfo.arguments.contains("-enable_full_product_surface") else {
            return
        }
        XCTAssertTrue(ReleaseSurface.showsAllPlayModesOnHome)
        XCTAssertTrue(ReleaseSurface.isPlayHomeGameSystemVisible(GameSystemId.wh40k11e.rawValue))
        XCTAssertTrue(ReleaseSurface.isPlayHomeGameSystemVisible(GameSystemId.wh40k10eCp.rawValue))
    }
}
