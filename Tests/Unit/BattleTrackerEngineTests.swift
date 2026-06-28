import XCTest
@testable import TabletomeDomain

final class BattleTrackerEngineTests: XCTestCase {
    func testPhasedRoundEngineSyncsCombatPatrolFirstTurn() {
        var tracker = BattleTrackerState(
            currentPhase: GameSystemPlayContext.context(for: .wh40k10eCp).playEngine.initialPhase()
        )
        var match = GuidedMatchState()
        match.firstTurnIsPlayerOne = false
        let context = GameSystemPlayContext.context(for: .wh40k10eCp)

        PhasedRoundBattleTrackerEngine().bootstrap(
            trackerState: &tracker,
            matchState: match,
            playContext: context
        )

        XCTAssertFalse(tracker.activePlayerIsOne)
    }

    func testAlternatingActivationPassClaimsMarker() {
        var tracker = BattleTrackerState(activePlayerIsOne: true)
        AlternatingActivationBattleTrackerEngine().passActivation(trackerState: &tracker)

        XCTAssertEqual(tracker.scFirstPlayerMarkerIsPlayerOne, true)
        XCTAssertEqual(tracker.scPhasePassClaimedByPlayerOne, true)
        XCTAssertFalse(tracker.activePlayerIsOne)
    }

    func testAlternatingActivationPhaseChangeAppliesMarkerHolder() {
        var tracker = BattleTrackerState(
            activePlayerIsOne: false,
            scFirstPlayerMarkerIsPlayerOne: true,
            scPhasePassClaimedByPlayerOne: true
        )
        AlternatingActivationBattleTrackerEngine().afterPhaseChange(
            from: .movement,
            trackerState: &tracker
        )

        XCTAssertNil(tracker.scPhasePassClaimedByPlayerOne)
        XCTAssertTrue(tracker.activePlayerIsOne)
    }

    func testFactorySelectsEngineByPlayContext() {
        let phased = BattleTrackerEngineFactory.engine(
            for: GameSystemPlayContext.context(for: .aosSpearhead)
        )
        let alternating = BattleTrackerEngineFactory.engine(
            for: GameSystemPlayContext.context(for: .scTmg)
        )

        XCTAssertEqual(phased.playEngineId, .phasedRound)
        XCTAssertEqual(alternating.playEngineId, .alternatingActivation)
    }
}
