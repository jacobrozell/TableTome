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

        BattleTrackerStore.save(state)
        let loaded = BattleTrackerStore.load()

        XCTAssertEqual(loaded.battleRound, 2)
        XCTAssertEqual(loaded.currentPhase, .shooting)
        XCTAssertTrue(loaded.usedOncePerBattleAbilityIds.contains("storm-charge"))
        XCTAssertEqual(loaded.playerOneVictoryPoints, 3)
        XCTAssertEqual(loaded.playerTwoVictoryPoints, 1)
        XCTAssertEqual(loaded.completedRoundChecklistSteps["round-2"], ["drawTwistCard"])
        XCTAssertEqual(loaded.unitWoundsRemaining["vigilant-brotherhood:liberators"], 7)
    }
}
