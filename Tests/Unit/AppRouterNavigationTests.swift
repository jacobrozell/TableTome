import XCTest
@testable import Tabletome

@MainActor
final class AppRouterNavigationTests: XCTestCase {
    override func tearDown() {
        ActiveGameContextPersistence.resetForTests()
        super.tearDown()
    }

    func testOpenGuidedMatchSetsTabPathAndActiveGameSystem() {
        let router = AppRouter()

        router.openGuidedMatch(gameSystemId: "aos-spearhead")

        XCTAssertEqual(router.selectedTab, .learn)
        XCTAssertEqual(router.activeGameSystemId, "aos-spearhead")
        XCTAssertEqual(router.learnPath.count, 1)
    }

    func testOpenGameGuideSetsTabPathAndActiveGameSystem() {
        let router = AppRouter()

        router.openGameGuide(gameSystemId: "wh40k-11e")

        XCTAssertEqual(router.selectedTab, .learn)
        XCTAssertEqual(router.activeGameSystemId, "wh40k-11e")
        XCTAssertEqual(router.learnPath.count, 1)
    }

    func testOpenRulesSearchQueuesQueryAndSwitchesTab() {
        let router = AppRouter()

        router.openRulesSearch(gameSystemId: "wh40k-10e-cp", query: "Command Phase")

        XCTAssertEqual(router.selectedTab, .search)
        XCTAssertEqual(router.activeGameSystemId, "wh40k-10e-cp")
        XCTAssertEqual(router.consumePendingRulesSearchQuery(), "Command Phase")
        XCTAssertNil(router.consumePendingRulesSearchQuery())
    }

    func testOpenMusterRedirectsToCollectionWhenMusterGated() {
        // Default release surface (no -enable_full_product_surface): the Lists/Muster tab is
        // gated, so muster routing must fall back to Collection rather than select a tab that
        // isn't rendered in RootTabView.
        XCTAssertFalse(ReleaseSurface.showsMusterTab)

        let router = AppRouter()
        router.openMuster(rosterId: UUID())

        XCTAssertEqual(router.selectedTab, .bench)
        XCTAssertEqual(router.hobbyTab, .armies)
        XCTAssertNil(router.pendingRosterId)
        XCTAssertNil(router.selectedRosterId)
    }

    func testOpenMusterHomeDeepLinkRedirectsToCollectionWhenGated() {
        XCTAssertFalse(ReleaseSurface.showsMusterTab)

        let router = AppRouter()
        router.open(.musterHome)

        XCTAssertEqual(router.selectedTab, .bench)
        XCTAssertEqual(router.hobbyTab, .armies)
    }

    func testSetActiveGameSystemPersistsAcrossRouterInstances() {
        let router = AppRouter()
        router.setActiveGameSystem("wh40k-10e-cp")
        XCTAssertEqual(AppRouter().activeGameSystemId, "wh40k-10e-cp")
    }
}
