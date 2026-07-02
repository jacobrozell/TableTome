import XCTest
@testable import TabletomeData
@testable import TabletomeDomain

final class ReinforcementsTrackingTests: XCTestCase {
    func testIdentifiesReinforcementKeywordUnits() async throws {
        let catalog = try await BundledSpearheadCatalogRepository(
            bundle: Bundle(for: ReinforcementsTrackingTests.self)
        ).loadCatalog()
        let army = try XCTUnwrap(
            catalog.factions.flatMap(\.armies).first { $0.id == "vigilant-brotherhood" }
        )

        let reinforcements = ReinforcementsTracking.reinforcementUnits(in: army)
        XCTAssertFalse(reinforcements.isEmpty)
        XCTAssertTrue(reinforcements.contains { $0.name.localizedCaseInsensitiveContains("Liberator") })
    }

    func testCallPromptWhenEnemyDestroyedDuringMovement() async throws {
        let context = try await movementPromptContext(calledUnitKeys: [])
        let prompt = ReinforcementsTracking.callPrompt(context: context)

        XCTAssertNotNil(prompt)
        XCTAssertEqual(prompt?.activePlayerName, "Alice")
        XCTAssertFalse(prompt?.availableUnits.isEmpty ?? true)
    }

    func testNoCallPromptWhenReinforcementAlreadyOnTable() async throws {
        let catalog = try await BundledSpearheadCatalogRepository(
            bundle: Bundle(for: ReinforcementsTrackingTests.self)
        ).loadCatalog()
        let stormcast = try XCTUnwrap(
            catalog.factions.flatMap(\.armies).first { $0.id == "vigilant-brotherhood" }
        )
        let calledKeys = Set(
            ReinforcementsTracking.reinforcementUnits(in: stormcast).map {
                UnitWoundTracker.unitKey(armyId: stormcast.id, unitId: $0.id)
            }
        )

        let context = try await movementPromptContext(calledUnitKeys: calledKeys)
        XCTAssertNil(ReinforcementsTracking.callPrompt(context: context))
    }

    func testNoCallPromptOutsideMovementPhase() async throws {
        var context = try await movementPromptContext(calledUnitKeys: [])
        context = ReinforcementCallContext(
            gameSystemId: context.gameSystemId,
            phase: .shooting,
            activePlayerIsOne: context.activePlayerIsOne,
            destroyedArmyId: context.destroyedArmyId,
            playerOneArmyId: context.playerOneArmyId,
            playerTwoArmyId: context.playerTwoArmyId,
            playerOneArmy: context.playerOneArmy,
            playerTwoArmy: context.playerTwoArmy,
            playerOneName: context.playerOneName,
            playerTwoName: context.playerTwoName,
            destroyedUnitName: context.destroyedUnitName,
            calledUnitKeys: context.calledUnitKeys
        )

        XCTAssertNil(ReinforcementsTracking.callPrompt(context: context))
    }

    private func movementPromptContext(calledUnitKeys: Set<String>) async throws -> ReinforcementCallContext {
        let catalog = try await BundledSpearheadCatalogRepository(
            bundle: Bundle(for: ReinforcementsTrackingTests.self)
        ).loadCatalog()
        let stormcast = try XCTUnwrap(
            catalog.factions.flatMap(\.armies).first { $0.id == "vigilant-brotherhood" }
        )
        let skaven = try XCTUnwrap(
            catalog.factions.flatMap(\.armies).first { $0.id == "gnawfeast-clawpack" }
        )

        return ReinforcementCallContext(
            gameSystemId: .aosSpearhead,
            phase: .movement,
            activePlayerIsOne: true,
            destroyedArmyId: skaven.id,
            playerOneArmyId: stormcast.id,
            playerTwoArmyId: skaven.id,
            playerOneArmy: stormcast,
            playerTwoArmy: skaven,
            playerOneName: "Alice",
            playerTwoName: "Bob",
            destroyedUnitName: "Rat Ogors",
            calledUnitKeys: calledUnitKeys
        )
    }
}
