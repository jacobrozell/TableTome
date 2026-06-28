import XCTest
@testable import Tabletome
@testable import TabletomeDomain

final class FirstSessionStoreTests: XCTestCase {
    override func setUp() {
        super.setUp()
        FirstSessionStore.clearPersistedState()
        ActiveGameContextPersistence.resetForTests()
        clearMatchPersistence()
    }

    override func tearDown() {
        super.tearDown()
        FirstSessionStore.clearPersistedState()
        ActiveGameContextPersistence.resetForTests()
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
        XCTAssertFalse(FirstSessionStore.shouldPromoteSampleData(hasSeenCollectionIntro: false))

        _ = FirstSessionStore.incrementCollectionVisits()
        XCTAssertFalse(FirstSessionStore.shouldPromoteSampleData(hasSeenCollectionIntro: false))

        _ = FirstSessionStore.incrementCollectionVisits()
        XCTAssertFalse(FirstSessionStore.shouldPromoteSampleData(hasSeenCollectionIntro: false))
        XCTAssertTrue(FirstSessionStore.shouldPromoteSampleData(hasSeenCollectionIntro: true))
    }

    func testSampleDataPromotedAfterGuideWithoutSecondVisit() {
        FirstSessionStore.recordGameGuideOpened()
        XCTAssertTrue(FirstSessionStore.shouldPromoteSampleData(hasSeenCollectionIntro: true))
        XCTAssertFalse(FirstSessionStore.shouldPromoteSampleData(hasSeenCollectionIntro: false))
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

    func testEmphasizePlayTabClearsWhenMatchInProgress() {
        let gameSystemId = GameSystemId.aosSpearhead.rawValue
        var state = GuidedMatchState()
        state.completedStepIds = ["choose-armies"]
        MatchSetupStore.save(state, gameSystemId: gameSystemId)

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

    func testCollectionIntroDeferredUntilSecondVisitOrGuide() {
        XCTAssertFalse(
            FirstSessionStore.shouldOfferCollectionIntro(
                hasSeenCollectionIntro: false,
                onboardingComplete: true
            )
        )

        _ = FirstSessionStore.incrementCollectionVisits()
        XCTAssertFalse(
            FirstSessionStore.shouldOfferCollectionIntro(
                hasSeenCollectionIntro: false,
                onboardingComplete: true
            )
        )

        _ = FirstSessionStore.incrementCollectionVisits()
        XCTAssertTrue(
            FirstSessionStore.shouldOfferCollectionIntro(
                hasSeenCollectionIntro: false,
                onboardingComplete: true
            )
        )

        FirstSessionStore.clearPersistedState()
        FirstSessionStore.recordGameGuideOpened()
        XCTAssertTrue(
            FirstSessionStore.shouldOfferCollectionIntro(
                hasSeenCollectionIntro: false,
                onboardingComplete: true
            )
        )
    }

    func testCollectionIntroNotOfferedAfterSeen() {
        FirstSessionStore.recordGameGuideOpened()
        XCTAssertFalse(
            FirstSessionStore.shouldOfferCollectionIntro(
                hasSeenCollectionIntro: true,
                onboardingComplete: true
            )
        )
    }

    func testCollectionFirstStepsCoachRequiresIntroAndNoUnits() {
        XCTAssertFalse(
            FirstSessionStore.shouldShowCollectionFirstStepsCoach(
                hasSeenCollectionIntro: false,
                hasDismissedCoach: false,
                totalUnitCount: 0
            )
        )

        XCTAssertTrue(
            FirstSessionStore.shouldShowCollectionFirstStepsCoach(
                hasSeenCollectionIntro: true,
                hasDismissedCoach: false,
                totalUnitCount: 0
            )
        )

        XCTAssertFalse(
            FirstSessionStore.shouldShowCollectionFirstStepsCoach(
                hasSeenCollectionIntro: true,
                hasDismissedCoach: false,
                totalUnitCount: 3
            )
        )

        XCTAssertFalse(
            FirstSessionStore.shouldShowCollectionFirstStepsCoach(
                hasSeenCollectionIntro: true,
                hasDismissedCoach: true,
                totalUnitCount: 0
            )
        )
    }
}
