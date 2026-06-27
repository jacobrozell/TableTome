import XCTest
@testable import Tabletome
@testable import TabletomeDomain

final class FirstSessionStoreTests: XCTestCase {
    override func setUp() {
        super.setUp()
        FirstSessionStore.clearPersistedState()
        ActiveGameContextStore.clearPersistedState()
        clearMatchPersistence()
    }

    override func tearDown() {
        super.tearDown()
        FirstSessionStore.clearPersistedState()
        ActiveGameContextStore.clearPersistedState()
        clearMatchPersistence()
    }

    private func clearMatchPersistence() {
        for id in GameSystemId.allCases.map(\.rawValue) {
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

    func testEmphasizePlayTabClearsAfterSetupComplete() {
        XCTAssertTrue(FirstSessionStore.shouldEmphasizePlayTab())
        FirstSessionStore.recordSetupComplete()
        XCTAssertFalse(FirstSessionStore.shouldEmphasizePlayTab())
    }

    func testHideAllGamesListUntilEngaged() {
        XCTAssertTrue(FirstSessionStore.shouldHideAllGamesList())

        FirstSessionStore.recordOnboardingChoice(gameSystemId: "aos-spearhead")
        XCTAssertFalse(FirstSessionStore.shouldHideAllGamesList())

        FirstSessionStore.clearPersistedState()
        FirstSessionStore.recordGameGuideOpened()
        XCTAssertFalse(FirstSessionStore.shouldHideAllGamesList())
    }

    func testDeferHobbyTabsUntilPlayEngaged() {
        XCTAssertTrue(FirstSessionStore.shouldDeferHobbyTabs())
        XCTAssertTrue(FirstSessionStore.shouldHideHobbyTabs())

        FirstSessionStore.recordGameGuideOpened()
        XCTAssertFalse(FirstSessionStore.shouldDeferHobbyTabs())
        XCTAssertFalse(FirstSessionStore.shouldHideHobbyTabs())

        FirstSessionStore.clearPersistedState()
        FirstSessionStore.recordSetupComplete()
        XCTAssertFalse(FirstSessionStore.shouldHideHobbyTabs())
    }

    func testRecordsWh40kVariant() {
        FirstSessionStore.recordOnboardingChoice(
            gameSystemId: GameSystemId.wh40k11e.rawValue,
            wh40kVariant: Wh40kChooserVariant.armageddon.rawValue
        )
        XCTAssertEqual(FirstSessionStore.onboardingWh40kVariant, Wh40kChooserVariant.armageddon.rawValue)
    }

    func testRoundOneMilestoneShowsInGuidedMatchAfterFirstRound() {
        XCTAssertFalse(FirstSessionStore.shouldShowRoundOneMilestone(isEmbeddedInGuidedMatch: true))

        FirstSessionStore.recordFirstBattleRound()
        XCTAssertTrue(FirstSessionStore.shouldShowRoundOneMilestone(isEmbeddedInGuidedMatch: true))
        XCTAssertFalse(FirstSessionStore.shouldShowRoundOneMilestone(isEmbeddedInGuidedMatch: false))

        FirstSessionStore.markRoundOneMilestoneSeen()
        XCTAssertFalse(FirstSessionStore.shouldShowRoundOneMilestone(isEmbeddedInGuidedMatch: true))
    }
}
