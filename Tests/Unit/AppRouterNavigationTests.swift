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

    func testOpenMusterSelectsMusterTab() {
        let router = AppRouter()
        let rosterId = UUID()

        router.openMuster(rosterId: rosterId)

        XCTAssertEqual(router.selectedTab, .muster)
        XCTAssertEqual(router.pendingRosterId, rosterId)
        XCTAssertEqual(router.selectedRosterId, rosterId)
    }

    func testSetActiveGameSystemPersistsAcrossRouterInstances() {
        let router = AppRouter()
        router.setActiveGameSystem("wh40k-10e-cp")
        XCTAssertEqual(AppRouter().activeGameSystemId, "wh40k-10e-cp")
    }
}
