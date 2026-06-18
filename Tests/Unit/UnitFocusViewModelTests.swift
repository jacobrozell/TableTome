import XCTest
@testable import Tabletome
@testable import TabletomeData
@testable import TabletomeDomain

@MainActor
final class UnitFocusViewModelTests: XCTestCase {
    func testArmyLookupAndActivePlayer() async throws {
        let catalog = try await BundledSpearheadCatalogRepository(
            bundle: Bundle(for: UnitFocusViewModelTests.self)
        ).loadCatalog()

        let matchState = GuidedMatchState(
            playerOne: PlayerArmySelection(
                playerName: "Alex",
                factionId: "skaven",
                armyId: "gnawfeast-clawpack"
            ),
            playerTwo: PlayerArmySelection(
                playerName: "Sam",
                factionId: "stormcast-eternals",
                armyId: "vigilant-brotherhood"
            )
        )

        var trackerState = BattleTrackerState()
        trackerState.activePlayerIsOne = true

        let viewModel = BattlePhaseTrackerViewModel(
            matchState: matchState,
            catalog: catalog,
            initialState: trackerState
        )

        XCTAssertEqual(viewModel.army(withId: "gnawfeast-clawpack")?.name, "Gnawfeast Clawpack")
        XCTAssertEqual(viewModel.playerName(forArmyId: "gnawfeast-clawpack"), "Alex")
        XCTAssertTrue(viewModel.isActivePlayerArmy("gnawfeast-clawpack"))
        XCTAssertFalse(viewModel.isActivePlayerArmy("vigilant-brotherhood"))
    }
}
