import XCTest
@testable import Tabletome
@testable import TabletomeData
@testable import TabletomeDomain

@MainActor
final class ScTmgActivationTests: XCTestCase {
    func testPassClaimsFirstPlayerMarker() async throws {
        let catalog = try await BundledPlayCatalogRepository(
            bundle: Bundle(for: ScTmgActivationTests.self)
        ).loadCatalog(for: "sc-tmg")
        var matchState = GuidedMatchState()
        matchState.playerOne.playerName = "Raynor"
        matchState.playerTwo.playerName = "Kerrigan"
        matchState.playerOne.factionId = "terran"
        matchState.playerOne.armyId = "raynors-raiders"
        matchState.playerTwo.factionId = "zerg"
        matchState.playerTwo.armyId = "kerrigans-swarm"

        let viewModel = AlternatingActivationBattleTrackerViewModel(
            gameSystemId: .scTmg,
            matchState: matchState,
            catalog: catalog,
            initialState: BattleTrackerState(
                currentPhase: .movement,
                scFirstPlayerMarkerIsPlayerOne: nil
            )
        )

        XCTAssertTrue(viewModel.trackerState.activePlayerIsOne)
        viewModel.passActivation()
        XCTAssertEqual(viewModel.trackerState.scFirstPlayerMarkerIsPlayerOne, true)
        XCTAssertEqual(viewModel.trackerState.scPhasePassClaimedByPlayerOne, true)
        XCTAssertFalse(viewModel.trackerState.activePlayerIsOne)
    }

    func testPhaseChangeAppliesMarkerHolder() async throws {
        let catalog = try await BundledPlayCatalogRepository(
            bundle: Bundle(for: ScTmgActivationTests.self)
        ).loadCatalog(for: "sc-tmg")
        var matchState = GuidedMatchState()
        matchState.playerOne.playerName = "Raynor"
        matchState.playerTwo.playerName = "Kerrigan"

        let viewModel = AlternatingActivationBattleTrackerViewModel(
            gameSystemId: .scTmg,
            matchState: matchState,
            catalog: catalog,
            initialState: BattleTrackerState(
                activePlayerIsOne: false,
                currentPhase: .movement,
                scFirstPlayerMarkerIsPlayerOne: true,
                scPhasePassClaimedByPlayerOne: false
            )
        )

        viewModel.setPhase(.assault)
        XCTAssertTrue(viewModel.trackerState.activePlayerIsOne)
        XCTAssertNil(viewModel.trackerState.scPhasePassClaimedByPlayerOne)
    }

    func testRoundOpenerSkippedForStarCraft() async throws {
        let catalog = try await BundledPlayCatalogRepository(
            bundle: Bundle(for: ScTmgActivationTests.self)
        ).loadCatalog(for: "sc-tmg")
        let viewModel = AlternatingActivationBattleTrackerViewModel(
            gameSystemId: .scTmg,
            matchState: GuidedMatchState(),
            catalog: catalog,
            initialState: BattleTrackerState(battleRound: 2, currentPhase: .movement)
        )

        XCTAssertNil(viewModel.focusedRoundOpenerStep)
        XCTAssertFalse(viewModel.roundOpenerIsIncomplete)
    }

    func testBattleTrackerStateDecodesScMarkerFields() throws {
        let json = """
        {"battleRound":1,"activePlayerIsOne":true,"currentPhase":"movement","scFirstPlayerMarkerIsPlayerOne":false}
        """
        let data = try XCTUnwrap(json.data(using: .utf8))
        let state = try JSONDecoder().decode(BattleTrackerState.self, from: data)
        XCTAssertEqual(state.scFirstPlayerMarkerIsPlayerOne, false)
        XCTAssertNil(state.scPhasePassClaimedByPlayerOne)
    }
}
