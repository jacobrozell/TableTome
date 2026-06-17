import XCTest
@testable import TabletomeDomain

final class GuideProgressStoreTests: XCTestCase {
    private let gameSystemId = "aos-spearhead-test"
    private var stepId = ""

    override func setUp() {
        super.setUp()
        stepId = "test-step-\(UUID().uuidString)"
        GuideProgressStore.setComplete(false, gameSystemId: gameSystemId, stepId: stepId)
    }

    override func tearDown() {
        GuideProgressStore.setComplete(false, gameSystemId: gameSystemId, stepId: stepId)
        super.tearDown()
    }

    func testPersistsCompletionAcrossReads() {
        XCTAssertFalse(GuideProgressStore.isComplete(gameSystemId: gameSystemId, stepId: stepId))

        GuideProgressStore.setComplete(true, gameSystemId: gameSystemId, stepId: stepId)
        XCTAssertTrue(GuideProgressStore.isComplete(gameSystemId: gameSystemId, stepId: stepId))
        XCTAssertTrue(GuideProgressStore.isComplete(gameSystemId: gameSystemId, stepId: stepId))
    }

    func testResetAllClearsGuideProgress() {
        let otherStepId = "other-step-\(UUID().uuidString)"
        GuideProgressStore.setComplete(true, gameSystemId: gameSystemId, stepId: stepId)
        GuideProgressStore.setComplete(true, gameSystemId: gameSystemId, stepId: otherStepId)

        GuideProgressStore.resetAll()

        XCTAssertFalse(GuideProgressStore.isComplete(gameSystemId: gameSystemId, stepId: stepId))
        XCTAssertFalse(GuideProgressStore.isComplete(gameSystemId: gameSystemId, stepId: otherStepId))
    }
}
