import XCTest
@testable import Tabletome
@testable import TabletomeDomain

@MainActor
final class SpearheadBattleViewModelPhaseFlowTests: XCTestCase {
    private func makeViewModel(
        activePlayerIsOne: Bool = true,
        phase: BattleTurnPhase = .endOfTurn,
        round: Int = 1,
        completedTurns: Set<Bool> = []
    ) -> SpearheadBattleViewModel {
        var match = GuidedMatchState()
        match.playerOne.playerName = "Alice"
        match.playerTwo.playerName = "Bob"
        match.attackerIsPlayerOne = true
        match.firstTurnIsPlayerOne = true
        let tracker = BattleTrackerState(
            battleRound: round,
            activePlayerIsOne: activePlayerIsOne,
            currentPhase: phase,
            completedTurnsThisRound: completedTurns
        )
        return SpearheadBattleViewModel(
            gameSystemId: .aosSpearhead,
            matchState: match,
            catalog: SpearheadCatalog(schemaVersion: 1, factions: [], matchSteps: []),
            initialState: tracker
        )
    }

    private func completeRoundOpener(for viewModel: SpearheadBattleViewModel, round: Int) {
        let key = BattleRoundChecklist.storageKey(round: round)
        viewModel.trackerState.completedRoundChecklistSteps[key] = Set(
            BattleRoundChecklistStep.allCases.map(\.rawValue)
        )
    }

    func testEndOfTurnPassesToNextPlayerBeforeAdvancingRound() {
        let viewModel = makeViewModel(activePlayerIsOne: true)
        completeRoundOpener(for: viewModel, round: 1)
        XCTAssertTrue(viewModel.canPassToNextPlayerThisRound)
        XCTAssertFalse(viewModel.canAdvanceBattleRound)

        viewModel.completePhasedRoundTurnPhase(.endOfTurn)

        XCTAssertFalse(viewModel.trackerState.activePlayerIsOne)
        XCTAssertEqual(viewModel.trackerState.currentPhase, .hero)
        XCTAssertEqual(viewModel.trackerState.completedTurnsThisRound.count, 1)
        XCTAssertFalse(viewModel.canAdvanceBattleRound)
    }

    func testSecondPlayerEndOfTurnFinishesTheRoundInsteadOfHandingBack() {
        let viewModel = makeViewModel(activePlayerIsOne: false, completedTurns: [true])
        completeRoundOpener(for: viewModel, round: 1)
        XCTAssertFalse(viewModel.endsTurnWithHandoff)
        XCTAssertFalse(viewModel.canAdvanceBattleRound)

        viewModel.completeCurrentGuideStep()

        XCTAssertEqual(viewModel.trackerState.completedTurnsThisRound.count, 2)
        XCTAssertEqual(viewModel.currentGuideStep?.kind, .startNextRound(1))
    }

    func testBothTurnsCompleteEnablesNextRound() {
        let viewModel = makeViewModel(activePlayerIsOne: false, completedTurns: [true])

        viewModel.completePhasedRoundTurnPhase(.endOfTurn)

        XCTAssertEqual(viewModel.trackerState.completedTurnsThisRound.count, 2)
        XCTAssertTrue(viewModel.canAdvanceBattleRound)
        XCTAssertFalse(viewModel.canPassToNextPlayerThisRound)
    }

    func testAdvanceTurnOrPhaseHandsOffAtEndOfTurn() {
        let viewModel = makeViewModel(activePlayerIsOne: true)
        completeRoundOpener(for: viewModel, round: 1)

        viewModel.advanceTurnOrPhase()

        XCTAssertFalse(viewModel.trackerState.activePlayerIsOne)
        XCTAssertEqual(viewModel.trackerState.currentPhase, .hero)
    }

    func testAdvanceRoundIncrementsAndRequiresNewOpener() {
        let viewModel = makeViewModel(activePlayerIsOne: false, completedTurns: [true])
        viewModel.completePhasedRoundTurnPhase(.endOfTurn)
        XCTAssertTrue(viewModel.canAdvanceBattleRound)

        viewModel.advanceBattleRound()

        XCTAssertEqual(viewModel.trackerState.battleRound, 2)
        XCTAssertTrue(viewModel.trackerState.completedTurnsThisRound.isEmpty)
        XCTAssertNil(viewModel.firstTurnIsPlayerOne)
        XCTAssertTrue(viewModel.roundOpenerIsIncomplete)
        XCTAssertTrue(viewModel.isTurnFlowBlocked)
    }

    func testIsBattleCompleteAfterFinalRoundBothTurns() {
        let viewModel = makeViewModel(
            activePlayerIsOne: false,
            round: 4,
            completedTurns: [true]
        )
        completeRoundOpener(for: viewModel, round: 4)

        XCTAssertFalse(viewModel.isBattleComplete)

        viewModel.completePhasedRoundTurnPhase(.endOfTurn)

        XCTAssertTrue(viewModel.isBattleComplete)
        XCTAssertNotNil(viewModel.currentGuideStep)
        XCTAssertEqual(viewModel.currentGuideStep?.kind, .battleComplete)
    }

    func testRoundOpenerBlocksPhaseAdvance() {
        let viewModel = makeViewModel(phase: .hero, round: 2)
        XCTAssertTrue(viewModel.roundOpenerIsIncomplete)
        XCTAssertTrue(viewModel.isTurnFlowBlocked)
        XCTAssertFalse(viewModel.canAdvancePhase)
        XCTAssertNil(viewModel.nextPhaseTitle)
    }

    func testUnderdogPlayerNameReflectsScore() {
        let viewModel = makeViewModel()
        viewModel.trackerState.playerOneVictoryPoints = 2
        viewModel.trackerState.playerTwoVictoryPoints = 5

        XCTAssertEqual(viewModel.underdogPlayerName, "Alice")
        XCTAssertEqual(viewModel.underdogIsPlayerOne, true)
    }
}
