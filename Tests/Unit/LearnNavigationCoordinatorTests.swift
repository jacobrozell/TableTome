import XCTest
@testable import Tabletome

@MainActor
final class LearnNavigationCoordinatorTests: XCTestCase {
    func testOpenGettingStartedQueuesAction() {
        let coordinator = LearnNavigationCoordinator()

        coordinator.openGettingStarted(gameSystemId: "aos-spearhead")

        XCTAssertEqual(
            coordinator.consumePendingAction(),
            .openGettingStarted(gameSystemId: "aos-spearhead")
        )
        XCTAssertNil(coordinator.consumePendingAction())
    }
}
