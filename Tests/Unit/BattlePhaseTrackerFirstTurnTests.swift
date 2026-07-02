import XCTest
@testable import Tabletome
@testable import TabletomeDomain

@MainActor
final class BattlePhaseTrackerFirstTurnTests: XCTestCase {
    private func makeViewModel(
        gameSystemId: GameSystemId = .wh40k10eCp,
        firstTurnIsPlayerOne: Bool = true,
        activePlayerIsOne: Bool = true,
        phase: BattleTurnPhase? = nil,
        playerOneVP: Int = 0,
        playerTwoVP: Int = 0
    ) -> BattlePhaseTrackerViewModel {
        let context = GameSystemPlayContext.context(for: gameSystemId)
        var match = GuidedMatchState()
        match.firstTurnIsPlayerOne = firstTurnIsPlayerOne
        match.playerOne.playerName = "Alex"
        match.playerTwo.playerName = "Jordan"
        var tracker = BattleTrackerState(
            battleRound: 1,
            activePlayerIsOne: activePlayerIsOne,
            currentPhase: phase ?? context.playEngine.turnStartPhase(),
            playerOneVictoryPoints: playerOneVP,
            playerTwoVictoryPoints: playerTwoVP
        )
        return BattlePhaseTrackerViewModel(
            gameSystemId: gameSystemId,
            matchState: match,
            catalog: SpearheadCatalog(schemaVersion: 1, factions: [], matchSteps: []),
            initialState: tracker
        )
    }

    func testSetActivePlayerSyncsFirstTurnDuringRoundOne() {
        let viewModel = makeViewModel(firstTurnIsPlayerOne: true, activePlayerIsOne: true)

        viewModel.setActivePlayer(isOne: false)

        XCTAssertFalse(viewModel.trackerState.activePlayerIsOne)
        XCTAssertEqual(viewModel.matchState.firstTurnIsPlayerOne, false)
    }

    func testSetActivePlayerResetsPhaseWhenCorrectingRoundOneStart() {
        let viewModel = makeViewModel(
            firstTurnIsPlayerOne: true,
            activePlayerIsOne: true,
            phase: .shooting
        )

        viewModel.setActivePlayer(isOne: false)

        XCTAssertEqual(
            viewModel.trackerState.currentPhase,
            viewModel.playContext.playEngine.turnStartPhase()
        )
    }

    func testSetFirstTurnUpdatesActivePlayerDuringRoundOne() {
        let viewModel = makeViewModel(firstTurnIsPlayerOne: true, activePlayerIsOne: true)

        viewModel.setFirstTurn(isPlayerOne: false)

        XCTAssertFalse(viewModel.trackerState.activePlayerIsOne)
        XCTAssertEqual(viewModel.matchState.firstTurnIsPlayerOne, false)
    }

    func testSpearheadCorrectRoundOneFirstTurnResetsPhaseEvenWithVictoryPoints() {
        let viewModel = makeViewModel(
            gameSystemId: .aosSpearhead,
            firstTurnIsPlayerOne: true,
            activePlayerIsOne: true,
            phase: .movement,
            playerOneVP: 2,
            playerTwoVP: 1
        )
        viewModel.trackerState.completedTurnsThisRound = [true]

        viewModel.correctRoundOneFirstTurn(isPlayerOne: false)

        XCTAssertFalse(viewModel.matchState.firstTurnIsPlayerOne ?? true)
        XCTAssertTrue(viewModel.trackerState.completedTurnsThisRound.isEmpty)
        XCTAssertEqual(
            viewModel.trackerState.currentPhase,
            viewModel.playContext.playEngine.turnStartPhase()
        )
    }

    func testSpearheadSetActivePlayerDoesNotChangeFirstTurnAfterOpener() {
        let viewModel = makeViewModel(
            gameSystemId: .aosSpearhead,
            firstTurnIsPlayerOne: true,
            activePlayerIsOne: true
        )
        viewModel.matchState.firstTurnIsPlayerOne = true

        viewModel.setActivePlayer(isOne: false)

        XCTAssertFalse(viewModel.trackerState.activePlayerIsOne)
        XCTAssertEqual(viewModel.matchState.firstTurnIsPlayerOne, true)
    }
}
