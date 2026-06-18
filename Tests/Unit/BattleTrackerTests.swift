import XCTest
@testable import TabletomeData
@testable import TabletomeDomain

final class BattleTrackerTests: XCTestCase {
    func testGreySeerAbilitiesAvailableInHeroPhase() async throws {
        let catalog = try await BundledSpearheadCatalogRepository(
            bundle: Bundle(for: BattleTrackerTests.self)
        ).loadCatalog()
        let army = try XCTUnwrap(
            catalog.factions.flatMap(\.armies).first { $0.id == "gnawfeast-clawpack" }
        )
        let abilities = BattleAbilityCatalog.abilities(for: army)

        XCTAssertFalse(army.units.isEmpty)
        let wither = try XCTUnwrap(abilities.first { $0.name == "Wither" })
        XCTAssertTrue(wither.matches(phase: .hero))
        XCTAssertEqual(wither.id, "gnawfeast-clawpack:grey-seer:wither")
        XCTAssertEqual(wither.kind, .spell)
        XCTAssertNotNil(wither.declare)
    }

    func testOncePerBattleAbilityMarkedUsed() {
        let ability = TriggeredAbility(
            id: "vigilant-brotherhood:lord-vigilant:deliver-judgement",
            name: "Deliver Judgement",
            source: "Lord-Vigilant",
            phases: [.anyCombat],
            usageLimit: .oncePerBattle,
            effect: "Fight twice."
        )

        XCTAssertTrue(ability.isAvailableIn(phase: .combat, usedOncePerBattle: []))
        XCTAssertFalse(ability.isAvailableIn(
            phase: .combat,
            usedOncePerBattle: ["vigilant-brotherhood:lord-vigilant:deliver-judgement"]
        ))
    }

    func testAnyCombatMatchesCombatPhase() {
        let ability = TriggeredAbility(
            id: "test",
            name: "Test",
            source: "Unit",
            phases: [.anyCombat],
            usageLimit: .eachTurn,
            effect: "Effect"
        )
        XCTAssertTrue(ability.matches(phase: .combat))
        XCTAssertFalse(ability.matches(phase: .hero))
        XCTAssertTrue(ability.suggestsCombatResolution)
    }

    func testShootingAbilitySuggestsCombatResolution() {
        let ability = TriggeredAbility(
            id: "test-shoot",
            name: "Volley",
            source: "Archers",
            phases: [.shooting],
            usageLimit: .eachTurn,
            effect: "Shoot."
        )
        XCTAssertTrue(ability.suggestsCombatResolution)
    }

    func testHeroPhaseHasNewPlayerSummary() {
        XCTAssertFalse(BattleTurnPhase.hero.newPlayerSummary.isEmpty)
        XCTAssertTrue(
            BattleTurnPhase.shooting.newPlayerSummary.localizedCaseInsensitiveContains("shoot")
        )
    }

    func testMainTurnPhasesIncludeDeployment() {
        XCTAssertEqual(BattleTurnPhase.mainTurnPhases.first, .deployment)
        XCTAssertTrue(BattleTurnPhase.mainTurnPhases.contains(.hero))
    }

    func testDefaultPhaseIsDeployment() {
        let state = BattleTrackerState()
        XCTAssertEqual(state.currentPhase, .deployment)
    }

    func testSpearheadBattleRoundCountIsFour() {
        XCTAssertEqual(SpearheadBattleRules.battleRoundCount, 4)
        XCTAssertEqual(SpearheadBattleRules.clampBattleRound(0), 1)
        XCTAssertEqual(SpearheadBattleRules.clampBattleRound(5), 4)
    }

    func testBattleTrackerStoreRoundTrip() {
        var state = BattleTrackerState()
        state.battleRound = 2
        state.currentPhase = .shooting
        state.usedOncePerBattleAbilityIds = ["storm-charge"]
        state.playerOneVictoryPoints = 3
        state.playerTwoVictoryPoints = 1
        state.completedRoundChecklistSteps = ["round-2": ["drawTwistCard"]]
        state.unitWoundsRemaining = ["vigilant-brotherhood:liberators": 7]
        state.unitHealthPerModelOverrides = ["gnawfeast-clawpack:rat-ogors": 4]

        BattleTrackerStore.save(state)
        let loaded = BattleTrackerStore.load()

        XCTAssertEqual(loaded.battleRound, 2)
        XCTAssertEqual(loaded.currentPhase, .shooting)
        XCTAssertTrue(loaded.usedOncePerBattleAbilityIds.contains("storm-charge"))
        XCTAssertEqual(loaded.playerOneVictoryPoints, 3)
        XCTAssertEqual(loaded.playerTwoVictoryPoints, 1)
        XCTAssertEqual(loaded.completedRoundChecklistSteps["round-2"], ["drawTwistCard"])
        XCTAssertEqual(loaded.unitWoundsRemaining["vigilant-brotherhood:liberators"], 7)
        XCTAssertEqual(loaded.unitHealthPerModelOverrides["gnawfeast-clawpack:rat-ogors"], 4)
    }

    func testCombatPatrolTrackerStoreRoundTrip() {
        var state = BattleTrackerState()
        state.battleRound = 3
        state.currentPhase = .command
        state.playerOneBattleReady = true
        state.playerTwoBattleReady = false
        state.securedObjectiveIds = ["A", "C"]
        state.usedStratagemIds = ["space-marines-combat-patrol:duty-and-honour"]
        state.intelRecoveredObjectiveIds = ["B"]

        BattleTrackerStore.save(state, gameSystemId: "wh40k-10e-cp")
        defer { BattleTrackerStore.reset(gameSystemId: "wh40k-10e-cp") }
        let loaded = BattleTrackerStore.load(gameSystemId: "wh40k-10e-cp")

        XCTAssertEqual(loaded.playerOneBattleReady, true)
        XCTAssertEqual(loaded.playerTwoBattleReady, false)
        XCTAssertEqual(loaded.securedObjectiveIds, ["A", "C"])
        XCTAssertTrue(loaded.usedStratagemIds.contains("space-marines-combat-patrol:duty-and-honour"))
        XCTAssertEqual(loaded.intelRecoveredObjectiveIds, ["B"])
    }
}
