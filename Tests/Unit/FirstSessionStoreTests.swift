import XCTest
@testable import Tabletome

final class FirstSessionStoreTests: XCTestCase {
    override func tearDown() {
        super.tearDown()
        FirstSessionStore.clearPersistedState()
    }

    func testContinueCardRequiresChoiceAndNoGuide() {
        FirstSessionStore.recordOnboardingChoice(gameSystemId: "wh40k-10e-cp")
        XCTAssertTrue(FirstSessionStore.shouldShowContinueCard())

        FirstSessionStore.recordGameGuideOpened()
        XCTAssertFalse(FirstSessionStore.shouldShowContinueCard())
    }

    func testSampleDataPromotedAfterGuideOrSecondVisit() {
        XCTAssertFalse(FirstSessionStore.shouldPromoteSampleData())

        _ = FirstSessionStore.incrementCollectionVisits()
        XCTAssertFalse(FirstSessionStore.shouldPromoteSampleData())

        _ = FirstSessionStore.incrementCollectionVisits()
        XCTAssertTrue(FirstSessionStore.shouldPromoteSampleData())
    }

    func testModelsNudgeAfterSetup() {
        XCTAssertFalse(FirstSessionStore.shouldShowModelsNudge())

        FirstSessionStore.recordSetupComplete()
        XCTAssertTrue(FirstSessionStore.shouldShowModelsNudge())

        FirstSessionStore.markModelsNudgeSeen()
        XCTAssertFalse(FirstSessionStore.shouldShowModelsNudge())
    }

    func testEmphasizePlayTabUntilGuideOpened() {
        XCTAssertTrue(FirstSessionStore.shouldEmphasizePlayTab())
        FirstSessionStore.recordGameGuideOpened()
        XCTAssertFalse(FirstSessionStore.shouldEmphasizePlayTab())
    }
}
