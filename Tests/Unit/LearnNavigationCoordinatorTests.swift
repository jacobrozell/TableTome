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
}
