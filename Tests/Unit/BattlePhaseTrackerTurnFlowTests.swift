import XCTest
@testable import Tabletome
@testable import TabletomeDomain

@MainActor
final class BattlePhaseTrackerTurnFlowTests: XCTestCase {
    private func makeViewModel(
        activePlayerIsOne: Bool = true,
        phase: BattleTurnPhase = .endOfTurn,
        round: Int = 1
    ) -> BattlePhaseTrackerViewModel {
        var match = GuidedMatchState()
        match.playerOne.playerName = "Alice"
        match.playerTwo.playerName = "Bob"
        match.attackerIsPlayerOne = true
        let tracker = BattleTrackerState(
            battleRound: round,
            activePlayerIsOne: activePlayerIsOne,
            currentPhase: phase
        )
        return BattlePhaseTrackerViewModel(
            gameSystemId: .aosSpearhead,
            matchState: match,
            catalog: SpearheadCatalog(schemaVersion: 1, factions: [], matchSteps: []),
            initialState: tracker
        )
    }

    func testEndOfTurnPassesToNextPlayerBeforeAdvancingRound() {
        let viewModel = makeViewModel(activePlayerIsOne: true)
        viewModel.trackerState.completedRoundChecklistSteps = [
            "round-1": Set(BattleRoundChecklistStep.allCases.map(\.rawValue))
        ]
        viewModel.matchState.firstTurnIsPlayerOne = true
        XCTAssertTrue(viewModel.canPassToNextPlayerThisRound)
        XCTAssertFalse(viewModel.canAdvanceBattleRound)

        viewModel.completePhasedRoundTurnPhase(.endOfTurn)

        XCTAssertFalse(viewModel.trackerState.activePlayerIsOne)
        XCTAssertEqual(viewModel.trackerState.currentPhase, .hero)
        XCTAssertEqual(viewModel.trackerState.completedTurnsThisRound.count, 1)
        XCTAssertFalse(viewModel.canAdvanceBattleRound)
    }

    func testBothTurnsCompleteEnablesNextRound() {
        let viewModel = makeViewModel(activePlayerIsOne: false)
        viewModel.trackerState.completedTurnsThisRound = [true]

        viewModel.completePhasedRoundTurnPhase(.endOfTurn)

        XCTAssertEqual(viewModel.trackerState.completedTurnsThisRound.count, 2)
        XCTAssertTrue(viewModel.canAdvanceBattleRound)
        XCTAssertFalse(viewModel.canPassToNextPlayerThisRound)
    }

    func testAdvanceTurnOrPhaseHandsOffAtEndOfTurn() {
        var match = GuidedMatchState()
        match.playerOne.playerName = "Alice"
        match.playerTwo.playerName = "Bob"
        match.firstTurnIsPlayerOne = true
        let tracker = BattleTrackerState(
            battleRound: 1,
            activePlayerIsOne: true,
            currentPhase: .endOfTurn
        )
        let catalog = SpearheadCatalog(schemaVersion: 1, factions: [], matchSteps: [])
        let viewModel = BattlePhaseTrackerViewModel(
            gameSystemId: .aosSpearhead,
            matchState: match,
            catalog: catalog,
            initialState: tracker
        )
        // Mark round 1 opener complete so turn handoff is allowed.
        viewModel.trackerState.completedRoundChecklistSteps = [
            "round-1": Set(BattleRoundChecklistStep.allCases.map(\.rawValue))
        ]
        viewModel.advanceTurnOrPhase()
        XCTAssertFalse(viewModel.trackerState.activePlayerIsOne)
        XCTAssertEqual(viewModel.trackerState.currentPhase, .hero)
    }

    func testAdvanceRoundIncrementsAndRequiresNewOpener() {
        let viewModel = makeViewModel(activePlayerIsOne: false)
        viewModel.trackerState.completedTurnsThisRound = [true, false]
        viewModel.completePhasedRoundTurnPhase(.endOfTurn)
        XCTAssertTrue(viewModel.canAdvanceBattleRound)

        viewModel.advanceBattleRound()

        XCTAssertEqual(viewModel.trackerState.battleRound, 2)
        XCTAssertTrue(viewModel.trackerState.completedTurnsThisRound.isEmpty)
        XCTAssertNil(viewModel.matchState.firstTurnIsPlayerOne)
        XCTAssertTrue(viewModel.roundOpenerIsIncomplete)
        XCTAssertFalse(viewModel.canPassToNextPlayerThisRound)
        XCTAssertTrue(viewModel.isTurnFlowBlocked)
    }
}
