import XCTest
@testable import TabletomeDomain

final class MatchSetupStoreTests: XCTestCase {
    private let stateKey = "guided_match_state_aos_spearhead"

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: stateKey)
        super.tearDown()
    }

    func testRoundTripMatchState() {
        var state = GuidedMatchState()
        state.playerOne = PlayerArmySelection(
            playerName: "Alex",
            factionId: "stormcast-eternals",
            armyId: "vigilant-brotherhood",
            regimentAbilityId: "strike-where-needed",
            enhancementId: "hallowed-scrolls"
        )
        state.playerTwo = PlayerArmySelection(
            playerName: "Friend",
            factionId: "skaven",
            armyId: "gnawfeast-clawpack"
        )
        state.attackerIsPlayerOne = true
        state.completedStepIds = ["choose-armies", "roll-attacker"]

        MatchSetupStore.save(state)
        let loaded = MatchSetupStore.load()

        XCTAssertEqual(loaded.playerOne.playerName, "Alex")
        XCTAssertEqual(loaded.playerOne.factionId, "stormcast-eternals")
        XCTAssertEqual(loaded.playerOne.armyId, "vigilant-brotherhood")
        XCTAssertEqual(loaded.playerTwo.factionId, "skaven")
        XCTAssertEqual(loaded.playerTwo.armyId, "gnawfeast-clawpack")
        XCTAssertEqual(loaded.attackerIsPlayerOne, true)
        XCTAssertTrue(loaded.completedStepIds.contains("choose-armies"))
    }

    func testResetClearsState() {
        MatchSetupStore.save(GuidedMatchState(
            playerOne: PlayerArmySelection(playerName: "A", factionId: "skaven", armyId: "gnawfeast-clawpack")
        ))
        MatchSetupStore.reset()
        let loaded = MatchSetupStore.load()
        XCTAssertFalse(loaded.hasBothArmies)
    }

    func testCombatPatrolRoundTripMatchState() {
        let cpKey = "guided_match_state_wh40k-10e-cp"
        defer { UserDefaults.standard.removeObject(forKey: cpKey) }

        var state = GuidedMatchState()
        state.playerOne = PlayerArmySelection(
            playerName: "Alex",
            factionId: "space-marines",
            armyId: "space-marines-combat-patrol",
            enhancementId: "champion-duellist",
            secondaryObjectiveId: "wrath-of-the-emperor"
        )
        state.playerTwo = PlayerArmySelection(
            playerName: "Friend",
            factionId: "tyranids",
            armyId: "tyranids-combat-patrol",
            enhancementId: "psychostatic-veil",
            secondaryObjectiveId: "alpha-xenoform"
        )
        state.selectedMissionId = "clash-of-patrols"
        state.attackerIsPlayerOne = true
        state.firstTurnIsPlayerOne = false
        state.completedStepIds = ["choose-armies", "pick-enhancement"]

        MatchSetupStore.save(state, gameSystemId: "wh40k-10e-cp")
        let loaded = MatchSetupStore.load(gameSystemId: "wh40k-10e-cp")

        XCTAssertEqual(loaded.playerOne.enhancementId, "champion-duellist")
        XCTAssertEqual(loaded.playerOne.secondaryObjectiveId, "wrath-of-the-emperor")
        XCTAssertEqual(loaded.playerTwo.secondaryObjectiveId, "alpha-xenoform")
        XCTAssertEqual(loaded.selectedMissionId, "clash-of-patrols")
        XCTAssertEqual(loaded.firstTurnIsPlayerOne, false)
    }
}
