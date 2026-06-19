import XCTest
@testable import Tabletome
@testable import TabletomeDomain

final class FirstSessionStoreTests: XCTestCase {
    override func tearDown() {
        super.tearDown()
        FirstSessionStore.clearPersistedState()
        ActiveGameContextStore.clearPersistedState()
        clearMatchPersistence()
    }

    private func clearMatchPersistence() {
        for id in ["wh40k-10e-cp", GameSystemId.aosSpearhead.rawValue, GameSystemId.default.rawValue] {
            UserDefaults.standard.removeObject(forKey: "guided_match_state_\(id)")
            UserDefaults.standard.removeObject(forKey: "battle_tracker_state_\(id)")
            UserDefaults.standard.removeObject(forKey: "match_session_started_\(id)")
        }
    }

    func testContinueCardRequiresChoiceAndNoGuide() {
        FirstSessionStore.recordOnboardingChoice(gameSystemId: "wh40k-10e-cp")
        XCTAssertTrue(FirstSessionStore.shouldShowContinueCard())

        FirstSessionStore.recordGameGuideOpened()
        XCTAssertFalse(FirstSessionStore.shouldShowContinueCard())
    }

    func testContinueCardReturnsAfterGuideWhenMatchInProgress() {
        let gameSystemId = "wh40k-10e-cp"

        FirstSessionStore.recordOnboardingChoice(gameSystemId: gameSystemId)
        FirstSessionStore.recordGameGuideOpened()

        var state = GuidedMatchState()
        state.completedStepIds = ["choose-armies"]
        MatchSetupStore.save(state, gameSystemId: gameSystemId)

        XCTAssertTrue(FirstSessionStore.shouldShowContinueCard())
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
