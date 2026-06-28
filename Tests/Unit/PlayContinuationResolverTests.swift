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
        ActiveGameContextPersistence.resetForTests()
        MatchSessionStore.clear(gameSystemId: gameSystemId)
        UserDefaults.standard.removeObject(forKey: matchKey)
        UserDefaults.standard.removeObject(forKey: trackerKey)
        UserDefaults.standard.removeObject(forKey: sessionKey)
        for id in GameSystemId.allCases.map(\.rawValue) {
            UserDefaults.standard.removeObject(forKey: "guided_match_state_\(id)")
            UserDefaults.standard.removeObject(forKey: "battle_tracker_state_\(id)")
            UserDefaults.standard.removeObject(forKey: "match_session_started_\(id)")
        }
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

    func testResumeBattleWhenTrackerHasProgress() {
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

        let continuation = PlayContinuationResolver.current()

        XCTAssertEqual(continuation?.destination, .guidedMatch)
        XCTAssertTrue(continuation?.message.contains("Alex") == true)
        XCTAssertEqual(continuation?.buttonTitle, String(localized: "Return to battle"))
        XCTAssertEqual(continuation?.opensBattleTab, true)
    }

    func testShouldOpenBattleTabWhenTrackerHasProgress() {
        FirstSessionStore.recordOnboardingChoice(gameSystemId: gameSystemId)
        var state = GuidedMatchState()
        state.playerOne.armyId = "vigilant-brotherhood"
        state.playerOne.factionId = "stormcast-eternals"
        state.playerTwo.armyId = "gnawfeast-clawpack"
        state.playerTwo.factionId = "skaven"
        MatchSetupStore.save(state, gameSystemId: gameSystemId)

        var tracker = BattleTrackerStore.load(gameSystemId: gameSystemId)
        tracker.battleRound = 2
        tracker.currentPhase = .movement
        BattleTrackerStore.save(tracker, gameSystemId: gameSystemId)

        XCTAssertTrue(PlayContinuationResolver.shouldOpenBattleTab(gameSystemId: gameSystemId))
    }

    func testSessionAloneDoesNotOpenBattleTab() {
        FirstSessionStore.recordOnboardingChoice(gameSystemId: gameSystemId)
        var state = GuidedMatchState()
        state.playerOne.armyId = "vigilant-brotherhood"
        state.playerOne.factionId = "stormcast-eternals"
        state.playerTwo.armyId = "gnawfeast-clawpack"
        state.playerTwo.factionId = "skaven"
        MatchSetupStore.save(state, gameSystemId: gameSystemId)
        MatchSessionStore.markStartedIfNeeded(gameSystemId: gameSystemId)

        XCTAssertFalse(PlayContinuationResolver.shouldOpenBattleTab(gameSystemId: gameSystemId))
    }

    func testSessionAloneResumesSetupNotBattle() {
        FirstSessionStore.recordOnboardingChoice(gameSystemId: gameSystemId)
        FirstSessionStore.recordGameGuideOpened()
        var state = GuidedMatchState()
        state.playerOne.armyId = "vigilant-brotherhood"
        state.playerOne.factionId = "stormcast-eternals"
        MatchSetupStore.save(state, gameSystemId: gameSystemId)
        MatchSessionStore.markStartedIfNeeded(gameSystemId: gameSystemId)

        let continuation = PlayContinuationResolver.current()

        XCTAssertEqual(continuation?.opensBattleTab, false)
        XCTAssertEqual(continuation?.buttonTitle, String(localized: "Resume Spearhead match"))
    }

    func testOnboardingBattleProgressPreferredOverActiveSetupProgress() {
        let otherSystemId = GameSystemId.wh40k10eCp.rawValue
        FirstSessionStore.recordOnboardingChoice(gameSystemId: gameSystemId)
        FirstSessionStore.recordGameGuideOpened()
        ActiveGameContextPersistence.gameSystemId = otherSystemId

        var cpState = GuidedMatchState()
        cpState.playerOne.armyId = "space-marines"
        cpState.playerOne.factionId = "space-marines"
        MatchSetupStore.save(cpState, gameSystemId: otherSystemId)

        var spearheadState = GuidedMatchState()
        spearheadState.playerOne = PlayerArmySelection(
            playerName: "Alex",
            factionId: "stormcast-eternals",
            armyId: "vigilant-brotherhood"
        )
        spearheadState.playerTwo = PlayerArmySelection(
            playerName: "Friend",
            factionId: "skaven",
            armyId: "gnawfeast-clawpack"
        )
        MatchSetupStore.save(spearheadState, gameSystemId: gameSystemId)
        var tracker = BattleTrackerStore.load(gameSystemId: gameSystemId)
        tracker.battleRound = 2
        tracker.currentPhase = .movement
        BattleTrackerStore.save(tracker, gameSystemId: gameSystemId)

        let continuation = PlayContinuationResolver.current()

        XCTAssertEqual(continuation?.gameSystemId, gameSystemId)
        XCTAssertEqual(continuation?.opensBattleTab, true)
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
        ActiveGameContextPersistence.gameSystemId = gameSystemId
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
