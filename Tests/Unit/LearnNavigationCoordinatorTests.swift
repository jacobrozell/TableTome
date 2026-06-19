import XCTest
@testable import Tabletome

@MainActor
final class LearnNavigationCoordinatorTests: XCTestCase {
    func testOpenGuidedMatchQueuesAction() {
        let coordinator = LearnNavigationCoordinator()

        coordinator.openGuidedMatch(gameSystemId: "aos-spearhead")

        XCTAssertEqual(
            coordinator.consumePendingAction(),
            .openGuidedMatch(gameSystemId: "aos-spearhead")
        )
        XCTAssertNil(coordinator.consumePendingAction())
    }

    func testOpenGameGuideQueuesAction() {
        let coordinator = LearnNavigationCoordinator()

        coordinator.openGameGuide(gameSystemId: "wh40k-11e")

        XCTAssertEqual(
            coordinator.consumePendingAction(),
            .openGameGuide(gameSystemId: "wh40k-11e")
        )
        XCTAssertNil(coordinator.consumePendingAction())
    }

    func testOpenRulesSearchQueuesActionAndQuery() {
        let coordinator = LearnNavigationCoordinator()

        coordinator.openRulesSearch(gameSystemId: "wh40k-10e-cp", query: "Command Phase")

        XCTAssertEqual(
            coordinator.consumePendingAction(),
            .openRulesSearch(gameSystemId: "wh40k-10e-cp", query: "Command Phase")
        )
        XCTAssertEqual(coordinator.consumePendingRulesSearchQuery(), "Command Phase")
        XCTAssertNil(coordinator.consumePendingRulesSearchQuery())
    }
}
