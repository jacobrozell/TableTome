import XCTest
@testable import Tabletome
@testable import TabletomeDomain

final class PlayContinuationResolverTests: XCTestCase {
    private let gameSystemId = GameSystemId.aosSpearhead.rawValue
    private let matchKey = "guided_match_state_aos-spearhead"
    private let trackerKey = "battle_tracker_state_aos-spearhead"
    private let sessionKey = "match_session_started_aos-spearhead"

    override func setUp() {
        super.setUp()
        clearPersistedMatchState()
    }

    override func tearDown() {
        clearPersistedMatchState()
        super.tearDown()
    }

    private func clearPersistedMatchState() {
        FirstSessionStore.clearPersistedState()
        ActiveGameContextStore.clearPersistedState()
        MatchSessionStore.clear(gameSystemId: gameSystemId)
        UserDefaults.standard.removeObject(forKey: matchKey)
        UserDefaults.standard.removeObject(forKey: trackerKey)
        UserDefaults.standard.removeObject(forKey: sessionKey)
        UserDefaults.standard.removeObject(forKey: "guided_match_state_\(GameSystemId.default.rawValue)")
        UserDefaults.standard.removeObject(forKey: "battle_tracker_state_\(GameSystemId.default.rawValue)")
        UserDefaults.standard.removeObject(forKey: "match_session_started_\(GameSystemId.default.rawValue)")
    }

    func testOpenGuideWhenChoiceRecordedAndGuideNotOpened() {
        FirstSessionStore.recordOnboardingChoice(gameSystemId: gameSystemId)

        let continuation = PlayContinuationResolver.current()

        XCTAssertEqual(continuation?.destination, .gameGuide)
        XCTAssertEqual(continuation?.gameSystemId, gameSystemId)
    }

    func testResumeGuidedMatchTakesPriorityOverOpenGuide() {
        FirstSessionStore.recordOnboardingChoice(gameSystemId: gameSystemId)
        var state = GuidedMatchState()
        state.playerOne.armyId = "vigilant-brotherhood"
        state.playerOne.factionId = "stormcast-eternals"
        MatchSetupStore.save(state, gameSystemId: gameSystemId)

        let continuation = PlayContinuationResolver.current()

        XCTAssertEqual(continuation?.destination, .guidedMatch)
        XCTAssertEqual(continuation?.gameSystemId, gameSystemId)
    }

    func testResumeBattleWhenSessionStarted() {
        FirstSessionStore.recordOnboardingChoice(gameSystemId: gameSystemId)
        FirstSessionStore.recordGameGuideOpened()

        var state = GuidedMatchState()
        state.playerOne = PlayerArmySelection(
            playerName: "Alex",
            factionId: "stormcast-eternals",
            armyId: "vigilant-brotherhood"
        )
        state.playerTwo = PlayerArmySelection(
            playerName: "Friend",
            factionId: "skaven",
            armyId: "gnawfeast-clawpack"
        )
        MatchSetupStore.save(state, gameSystemId: gameSystemId)

        var tracker = BattleTrackerStore.load(gameSystemId: gameSystemId)
        tracker.battleRound = 2
        tracker.currentPhase = .movement
        BattleTrackerStore.save(tracker, gameSystemId: gameSystemId)
        MatchSessionStore.markStartedIfNeeded(gameSystemId: gameSystemId)

        let continuation = PlayContinuationResolver.current()

        XCTAssertEqual(continuation?.destination, .guidedMatch)
        XCTAssertTrue(continuation?.message.contains("Alex") == true)
        XCTAssertEqual(continuation?.buttonTitle, String(localized: "Return to battle"))
        XCTAssertEqual(continuation?.opensBattleTab, true)
    }

    func testShouldOpenBattleTabWhenSessionStarted() {
        FirstSessionStore.recordOnboardingChoice(gameSystemId: gameSystemId)
        var state = GuidedMatchState()
        state.playerOne.armyId = "vigilant-brotherhood"
        state.playerOne.factionId = "stormcast-eternals"
        state.playerTwo.armyId = "gnawfeast-clawpack"
        state.playerTwo.factionId = "skaven"
        MatchSetupStore.save(state, gameSystemId: gameSystemId)
        MatchSessionStore.markStartedIfNeeded(gameSystemId: gameSystemId)

        XCTAssertTrue(PlayContinuationResolver.shouldOpenBattleTab(gameSystemId: gameSystemId))
    }

    func testShouldNotOpenBattleTabForSetupOnlyProgress() {
        FirstSessionStore.recordOnboardingChoice(gameSystemId: gameSystemId)
        var state = GuidedMatchState()
        state.playerOne.armyId = "vigilant-brotherhood"
        state.playerOne.factionId = "stormcast-eternals"
        MatchSetupStore.save(state, gameSystemId: gameSystemId)

        XCTAssertFalse(PlayContinuationResolver.shouldOpenBattleTab(gameSystemId: gameSystemId))
    }

    func testNoContinuationAfterFreshInstallPathCompletes() {
        FirstSessionStore.recordOnboardingChoice(gameSystemId: gameSystemId)
        FirstSessionStore.recordGameGuideOpened()
        MatchSetupStore.save(GuidedMatchState(), gameSystemId: gameSystemId)
        ActiveGameContextStore.setActiveGameSystem(gameSystemId)
        XCTAssertNil(PlayContinuationResolver.current())
    }
}

final class GuidedMatchStateProgressTests: XCTestCase {
    func testFreshStateHasNoProgress() {
        XCTAssertFalse(GuidedMatchState().hasGuidedMatchProgress)
    }

    func testPartialArmySelectionCountsAsProgress() {
        var state = GuidedMatchState()
        state.playerOne.factionId = "stormcast-eternals"
        XCTAssertTrue(state.hasGuidedMatchProgress)
    }
}
