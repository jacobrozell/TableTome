import XCTest
@testable import TabletomeDomain

final class GuideProgressStoreTests: XCTestCase {
    private let gameSystemId = "aos-spearhead"
    private let stepId = "pick-army"

    override func tearDown() {
        GuideProgressStore.setComplete(false, gameSystemId: gameSystemId, stepId: stepId)
        super.tearDown()
    }

    func testPersistsCompletionAcrossReads() {
        XCTAssertFalse(GuideProgressStore.isComplete(gameSystemId: gameSystemId, stepId: stepId))

        GuideProgressStore.setComplete(true, gameSystemId: gameSystemId, stepId: stepId)
        XCTAssertTrue(GuideProgressStore.isComplete(gameSystemId: gameSystemId, stepId: stepId))

        // Simulates relaunch: fresh read from UserDefaults should restore state.
        XCTAssertTrue(GuideProgressStore.isComplete(gameSystemId: gameSystemId, stepId: stepId))
    }

    func testResetAllClearsGuideProgress() {
        GuideProgressStore.setComplete(true, gameSystemId: gameSystemId, stepId: stepId)
        GuideProgressStore.setComplete(true, gameSystemId: gameSystemId, stepId: "choose-realm")

        GuideProgressStore.resetAll()

        XCTAssertFalse(GuideProgressStore.isComplete(gameSystemId: gameSystemId, stepId: stepId))
        XCTAssertFalse(GuideProgressStore.isComplete(gameSystemId: gameSystemId, stepId: "choose-realm"))
    }
}
