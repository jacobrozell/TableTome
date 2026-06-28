import XCTest
@testable import TabletomeDomain

final class MatchSyncCodecTests: XCTestCase {
    // MARK: - Paste code codec

    func testEncodeDecodeRoundTripSpearhead() throws {
        var tracker = BattleTrackerState()
        tracker.battleRound = 2
        let snapshot = MatchSyncSnapshot(
            matchState: GuidedMatchState(
                playerOne: PlayerArmySelection(playerName: "Alice", armyId: "gnawfeast-clawpack"),
                playerTwo: PlayerArmySelection(playerName: "Bob", armyId: "vigilant-brotherhood")
            ),
            trackerState: tracker
        )

        let code = try XCTUnwrap(MatchSyncCodec.encode(snapshot))
        XCTAssertTrue(code.hasPrefix("tabletome-match:"))

        let decoded = try XCTUnwrap(MatchSyncCodec.decode(code))
        XCTAssertEqual(decoded.schemaVersion, MatchSyncSchemaPolicy.version)
        XCTAssertEqual(decoded.gameSystemId, "aos-spearhead")
        XCTAssertEqual(decoded.matchState.playerOne.playerName, "Alice")
        XCTAssertEqual(decoded.trackerState.battleRound, 2)
    }

    func testDecodeRejectsInvalidPasteCodes() {
        XCTAssertNil(MatchSyncCodec.decode(""))
        XCTAssertEqual(MatchSyncCodec.decodePasteCode(""), .failure(.missingPrefix))
        XCTAssertNil(MatchSyncCodec.decode("not-a-match-code"))
        XCTAssertEqual(MatchSyncCodec.decodePasteCode("not-a-match-code"), .failure(.missingPrefix))
        XCTAssertNil(MatchSyncCodec.decode("tabletome-match:not-valid-base64!!!"))
        XCTAssertEqual(
            MatchSyncCodec.decodePasteCode("tabletome-match:not-valid-base64!!!"),
            .failure(.invalidBase64)
        )
        XCTAssertNil(MatchSyncCodec.decode("tabletome-match:\(Data([0xFF, 0xFE]).base64EncodedString())"))
        if case .failure(.decodeFailed) = MatchSyncCodec.decodePasteCode(
            "tabletome-match:\(Data([0xFF, 0xFE]).base64EncodedString())"
        ) {
            // expected
        } else {
            XCTFail("Expected decodeFailed for corrupt JSON payload")
        }
    }

    func testDecodeWireDataRejectsInvalidJSON() {
        let result = MatchSyncCodec.decodeWireData(Data([0x00, 0x01]))
        XCTAssertEqual(result, .failure(.decodeFailed))
    }

    func testEncodePasteCodeRoundTrip() throws {
        let snapshot = MatchSyncSnapshot(
            matchState: GuidedMatchState(),
            trackerState: BattleTrackerState(battleRound: 2)
        )
        let code = try MatchSyncCodec.encodePasteCode(snapshot).get()
        let decoded = try MatchSyncCodec.decodePasteCode(code).get()
        XCTAssertEqual(decoded.trackerState.battleRound, 2)
    }

    func testDecodeAcceptsTrimmedWhitespace() throws {
        let snapshot = MatchSyncSnapshot(
            matchState: GuidedMatchState(),
            trackerState: BattleTrackerState()
        )
        let code = try XCTUnwrap(MatchSyncCodec.encode(snapshot))
        XCTAssertNotNil(MatchSyncCodec.decode("  \n\(code)  "))
    }

    // MARK: - MCSession wire format (raw JSON, no paste prefix)

    func testNearbyWireJSONRoundTripAppliesToStores() throws {
        let gameSystemId = "aos-spearhead"
        resetSyncStores(gameSystemId: gameSystemId)

        var tracker = BattleTrackerState(battleRound: 3, currentPhase: .shooting)
        tracker.playerOneVictoryPoints = 8
        tracker.playerTwoVictoryPoints = 5
        tracker.unitWoundsRemaining = ["grey-seer": 3]
        let matchState = GuidedMatchState(
            playerOne: PlayerArmySelection(playerName: "Host", armyId: "gnawfeast-clawpack"),
            playerTwo: PlayerArmySelection(playerName: "Guest", armyId: "vigilant-brotherhood"),
            selectedMissionId: "shifting-frontiers"
        )
        let snapshot = MatchSyncSnapshot(
            gameSystemId: gameSystemId,
            matchState: matchState,
            trackerState: tracker
        )

        let wireData = try MatchSyncCodec.encodeWireData(snapshot).get()
        let decoded = try MatchSyncCodec.decodeWireData(wireData).get()
        MatchSyncCodec.apply(decoded, notifyUI: false)

        XCTAssertEqual(MatchSetupStore.load(gameSystemId: gameSystemId).selectedMissionId, "shifting-frontiers")
        let loadedTracker = BattleTrackerStore.load(gameSystemId: gameSystemId)
        XCTAssertEqual(loadedTracker.battleRound, 3)
        XCTAssertEqual(loadedTracker.currentPhase, .shooting)
        XCTAssertEqual(loadedTracker.playerOneVictoryPoints, 8)
        XCTAssertEqual(loadedTracker.unitWoundsRemaining["grey-seer"], 3)
    }

    // MARK: - Store round-trips per game system

    func testCurrentSnapshotReflectsSavedStores() throws {
        let gameSystemId = "wh40k-11e"
        resetSyncStores(gameSystemId: gameSystemId)

        var matchState = GuidedMatchState()
        matchState.playerOne = PlayerArmySelection(
            playerName: "Alex",
            factionId: "space-marines",
            armyId: "space-marines-strike-force"
        )
        matchState.playerTwo = PlayerArmySelection(
            playerName: "Jordan",
            factionId: "necrons",
            armyId: "necrons-strike-force"
        )
        matchState.selectedMissionId = "only-war"
        matchState.attackerIsPlayerOne = true
        matchState.firstTurnIsPlayerOne = true

        var tracker = BattleTrackerState(battleRound: 2, currentPhase: .command)
        tracker.playerOneVictoryPoints = 15
        tracker.playerTwoVictoryPoints = 10
        tracker.usedOncePerBattleAbilityIds = ["space-marines-strike-force:captain:grimoire"]

        MatchSetupStore.save(matchState, gameSystemId: gameSystemId, notifySync: false)
        BattleTrackerStore.save(tracker, gameSystemId: gameSystemId, notifySync: false)

        let current = MatchSyncCodec.current(gameSystemId: gameSystemId)
        XCTAssertEqual(current.gameSystemId, gameSystemId)
        XCTAssertEqual(current.matchState, matchState)
        XCTAssertEqual(current.trackerState, tracker)
    }

    func testWh40k11eApplyRoundTripUsesGameSystemId() throws {
        let gameSystemId = "wh40k-11e"
        resetSyncStores(gameSystemId: gameSystemId)

        var tracker = BattleTrackerState(battleRound: 4, currentPhase: .movement)
        tracker.playerOneVictoryPoints = 22
        tracker.playerTwoVictoryPoints = 18
        tracker.completedRoundChecklistSteps = ["4": ["score-primary", "score-secondary"]]
        let snapshot = MatchSyncSnapshot(
            gameSystemId: gameSystemId,
            matchState: GuidedMatchState(
                playerOne: PlayerArmySelection(playerName: "P1", armyId: "space-marines-strike-force"),
                playerTwo: PlayerArmySelection(playerName: "P2", armyId: "necrons-strike-force"),
                firstTurnIsPlayerOne: false,
                selectedMissionId: "only-war"
            ),
            trackerState: tracker
        )

        MatchSetupStore.save(snapshot.matchState, gameSystemId: gameSystemId, notifySync: false)
        BattleTrackerStore.save(snapshot.trackerState, gameSystemId: gameSystemId, notifySync: false)

        let code = try XCTUnwrap(MatchSyncCodec.encode(snapshot))
        resetSyncStores(gameSystemId: gameSystemId)

        let decoded = try XCTUnwrap(MatchSyncCodec.decode(code))
        MatchSyncCodec.apply(decoded, notifyUI: false)

        let loadedMatch = MatchSetupStore.load(gameSystemId: gameSystemId)
        XCTAssertEqual(loadedMatch.selectedMissionId, "only-war")
        XCTAssertEqual(loadedMatch.firstTurnIsPlayerOne, false)

        let loadedTracker = BattleTrackerStore.load(gameSystemId: gameSystemId)
        XCTAssertEqual(loadedTracker.battleRound, 4)
        XCTAssertEqual(loadedTracker.currentPhase, .movement)
        XCTAssertEqual(loadedTracker.playerOneVictoryPoints, 22)
        XCTAssertEqual(loadedTracker.completedRoundChecklistSteps["4"], ["score-primary", "score-secondary"])
    }

    func testCombatPatrolSyncRoundTripUsesGameSystemId() throws {
        let gameSystemId = "wh40k-10e-cp"
        resetSyncStores(gameSystemId: gameSystemId)

        var tracker = BattleTrackerState()
        tracker.securedObjectiveIds = ["A", "B"]
        tracker.usedStratagemIds = ["space-marines-combat-patrol:duty-and-honour"]
        let snapshot = MatchSyncSnapshot(
            gameSystemId: gameSystemId,
            matchState: GuidedMatchState(selectedMissionId: "clash-of-patrols"),
            trackerState: tracker
        )

        MatchSetupStore.save(snapshot.matchState, gameSystemId: gameSystemId, notifySync: false)
        BattleTrackerStore.save(snapshot.trackerState, gameSystemId: gameSystemId, notifySync: false)

        let code = try XCTUnwrap(MatchSyncCodec.encode(snapshot))
        resetSyncStores(gameSystemId: gameSystemId)

        let decoded = try XCTUnwrap(MatchSyncCodec.decode(code))
        MatchSyncCodec.apply(decoded, notifyUI: false)

        XCTAssertEqual(MatchSetupStore.load(gameSystemId: gameSystemId).selectedMissionId, "clash-of-patrols")
        let loaded = BattleTrackerStore.load(gameSystemId: gameSystemId)
        XCTAssertEqual(loaded.securedObjectiveIds, ["A", "B"])
        XCTAssertTrue(loaded.usedStratagemIds.contains("space-marines-combat-patrol:duty-and-honour"))
    }

    func testStarCraftSyncRoundTripPreservesMarkerFields() throws {
        var tracker = BattleTrackerState(
            currentPhase: .movement,
            scFirstPlayerMarkerIsPlayerOne: true,
            scPhasePassClaimedByPlayerOne: false
        )
        tracker.activePlayerIsOne = false
        let snapshot = MatchSyncSnapshot(
            gameSystemId: "sc-tmg",
            matchState: GuidedMatchState(
                playerOne: PlayerArmySelection(playerName: "Raynor", factionId: "terran", armyId: "raynors-raiders"),
                playerTwo: PlayerArmySelection(playerName: "Kerrigan", factionId: "zerg", armyId: "kerrigans-swarm")
            ),
            trackerState: tracker
        )

        let code = try XCTUnwrap(MatchSyncCodec.encode(snapshot))
        let decoded = try XCTUnwrap(MatchSyncCodec.decode(code))
        XCTAssertEqual(decoded.gameSystemId, "sc-tmg")
        XCTAssertEqual(decoded.matchState.playerOne.playerName, "Raynor")
        XCTAssertEqual(decoded.trackerState.scFirstPlayerMarkerIsPlayerOne, true)
        XCTAssertEqual(decoded.trackerState.scPhasePassClaimedByPlayerOne, false)
        XCTAssertFalse(decoded.trackerState.activePlayerIsOne)
    }

    func testApplyDoesNotCrossContaminateGameSystems() throws {
        resetSyncStores(gameSystemId: "aos-spearhead")
        resetSyncStores(gameSystemId: "wh40k-11e")

        MatchSetupStore.save(
            GuidedMatchState(playerOne: PlayerArmySelection(playerName: "Keep", armyId: "gnawfeast-clawpack")),
            gameSystemId: "aos-spearhead",
            notifySync: false
        )

        let snapshot = MatchSyncSnapshot(
            gameSystemId: "wh40k-11e",
            matchState: GuidedMatchState(
                playerOne: PlayerArmySelection(playerName: "Import", armyId: "space-marines-strike-force")
            ),
            trackerState: BattleTrackerState(battleRound: 5)
        )
        MatchSyncCodec.apply(snapshot, notifyUI: false)

        XCTAssertEqual(MatchSetupStore.load(gameSystemId: "aos-spearhead").playerOne.playerName, "Keep")
        XCTAssertEqual(MatchSetupStore.load(gameSystemId: "wh40k-11e").playerOne.playerName, "Import")
        XCTAssertEqual(BattleTrackerStore.load(gameSystemId: "wh40k-11e").battleRound, 5)
    }

    // MARK: - Notifications

    func testApplyPostsStateDidChangeWhenNotifyUIEnabled() {
        let expectation = expectation(forNotification: .matchSyncStateDidChange, object: nil) { notification in
            (notification.userInfo?[MatchSyncNotifications.shouldBroadcastToPeersKey] as? Bool) == false
        }

        let snapshot = MatchSyncSnapshot(
            matchState: GuidedMatchState(),
            trackerState: BattleTrackerState(battleRound: 2)
        )
        MatchSyncCodec.apply(snapshot, notifyUI: true)

        wait(for: [expectation], timeout: 1)
    }

    func testStoreSavePostsBroadcastNotification() {
        let expectation = expectation(forNotification: .matchSyncStateDidChange, object: nil) { notification in
            (notification.userInfo?[MatchSyncNotifications.shouldBroadcastToPeersKey] as? Bool) == true
        }

        MatchSetupStore.save(
            GuidedMatchState(playerOne: PlayerArmySelection(playerName: "Local", armyId: "gnawfeast-clawpack")),
            notifySync: true
        )

        wait(for: [expectation], timeout: 1)
    }

    func testApplySkipsStateDidChangeWhenNotifyUIDisabled() {
        let expectation = expectation(forNotification: .matchSyncStateDidChange, object: nil)
        expectation.isInverted = true

        let snapshot = MatchSyncSnapshot(
            matchState: GuidedMatchState(),
            trackerState: BattleTrackerState(battleRound: 2)
        )
        MatchSyncCodec.apply(snapshot, notifyUI: false)

        wait(for: [expectation], timeout: 0.2)
    }

    func testApplyDoesNotRebroadcastViaStoreSave() {
        let expectation = expectation(forNotification: .matchSyncStateDidChange, object: nil)
        expectation.isInverted = true

        let snapshot = MatchSyncSnapshot(
            matchState: GuidedMatchState(),
            trackerState: BattleTrackerState(playerOneVictoryPoints: 3)
        )
        // Stores use notifySync: false inside apply — receiving a sync must not ping peers again.
        MatchSyncCodec.apply(snapshot, notifyUI: false)

        wait(for: [expectation], timeout: 0.2)
    }

    // MARK: - Validation

    func testApplyRejectsIncompatibleSchema() {
        let snapshot = MatchSyncSnapshot(
            schemaVersion: 99,
            matchState: GuidedMatchState(),
            trackerState: BattleTrackerState(battleRound: 2)
        )

        let error = MatchSyncCodec.apply(snapshot, expectedGameSystemId: "aos-spearhead", notifyUI: false)
        XCTAssertEqual(error, .incompatibleSchema(received: 99, expected: MatchSyncSchemaPolicy.version))
        XCTAssertEqual(BattleTrackerStore.load().battleRound, 1)
    }

    func testApplyRejectsWrongGameSystem() {
        let snapshot = MatchSyncSnapshot(
            gameSystemId: "wh40k-11e",
            matchState: GuidedMatchState(
                playerOne: PlayerArmySelection(playerName: "Wrong", armyId: "space-marines-strike-force")
            ),
            trackerState: BattleTrackerState(battleRound: 3)
        )

        let error = MatchSyncCodec.apply(snapshot, expectedGameSystemId: "aos-spearhead", notifyUI: false)
        XCTAssertEqual(error, .wrongGameSystem(received: "wh40k-11e", expected: "aos-spearhead"))
        XCTAssertFalse(MatchSetupStore.load(gameSystemId: "wh40k-11e").hasBothArmies)
    }

    func testValidateAllowsMissingExpectedGameSystem() {
        let snapshot = MatchSyncSnapshot(
            gameSystemId: "wh40k-11e",
            matchState: GuidedMatchState(),
            trackerState: BattleTrackerState()
        )
        XCTAssertNil(MatchSyncCodec.validate(snapshot, expectedGameSystemId: nil))
    }

    // MARK: - Schema

    func testSnapshotDecodesMissingSchemaVersionAsOne() throws {
        let json = """
        {
          "gameSystemId": "aos-spearhead",
          "matchState": {
            "playerOne": { "playerName": "A", "factionId": "", "armyId": "", "regimentAbilityId": null, "enhancementId": null, "secondaryObjectiveId": null },
            "playerTwo": { "playerName": "B", "factionId": "", "armyId": "", "regimentAbilityId": null, "enhancementId": null, "secondaryObjectiveId": null },
            "completedStepIds": []
          },
          "trackerState": { "battleRound": 1, "activePlayerIsOne": true, "currentPhase": "deployment" }
        }
        """
        let data = try XCTUnwrap(json.data(using: .utf8))
        let snapshot = try JSONDecoder().decode(MatchSyncSnapshot.self, from: data)
        XCTAssertEqual(snapshot.schemaVersion, 1)
    }

    // MARK: - Helpers

    private func resetSyncStores(gameSystemId: String) {
        MatchSetupStore.reset(gameSystemId: gameSystemId)
        BattleTrackerStore.reset(gameSystemId: gameSystemId)
    }

    override func tearDown() {
        resetSyncStores(gameSystemId: "aos-spearhead")
        resetSyncStores(gameSystemId: "wh40k-11e")
        resetSyncStores(gameSystemId: "wh40k-10e-cp")
        resetSyncStores(gameSystemId: "sc-tmg")
        super.tearDown()
    }
}
