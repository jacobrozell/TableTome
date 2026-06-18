import XCTest
@testable import TabletomeDomain

final class PhaseContextCoachTests: XCTestCase {
    func testChargePhaseIncludesDistanceReminders() {
        let tips = PhaseContextCoach.quickTips(for: .charge)
        XCTAssertFalse(tips.isEmpty)
        XCTAssertTrue(tips.joined().contains("12"))
        XCTAssertTrue(tips.joined().contains("2D6"))
    }

    func testEndOfTurnIncludesScoringReminder() {
        let tips = PhaseContextCoach.quickTips(for: .endOfTurn)
        XCTAssertTrue(tips.joined().lowercased().contains("victory"))
    }

    func testCombatPhaseIncludesPileInTip() {
        let tips = PhaseContextCoach.quickTips(for: .combat)
        XCTAssertTrue(tips.joined().localizedCaseInsensitiveContains("pile in"))
    }

    func testPassiveReactionPhasesHaveNoExtraTips() {
        XCTAssertTrue(PhaseContextCoach.quickTips(for: .enemyMovement).isEmpty)
        XCTAssertTrue(PhaseContextCoach.quickTips(for: .endOfAnyTurn).isEmpty)
    }

    func testStarCraftHeroPhaseHasNoSpearheadTips() {
        XCTAssertTrue(PhaseContextCoach.quickTips(for: .hero, gameSystemId: "sc-tmg").isEmpty)
        XCTAssertTrue(PhaseContextCoach.quickTips(for: .charge, gameSystemId: "sc-tmg").isEmpty)
    }

    func testCombatPatrolCommandPhaseIncludesSecureObjectives() {
        let tips = PhaseContextCoach.quickTips(for: .command, gameSystemId: "wh40k-10e-cp")
        XCTAssertTrue(tips.joined().localizedCaseInsensitiveContains("Battleline"))
        XCTAssertTrue(tips.joined().localizedCaseInsensitiveContains("stratagem"))
    }

    func testStarCraftMovementSummaryIsNotSpearhead() {
        let summary = BattleTurnPhase.movement.playerFacingSummary(gameSystemId: "sc-tmg")
        XCTAssertTrue(summary.localizedCaseInsensitiveContains("Pass"))
        XCTAssertFalse(summary.localizedCaseInsensitiveContains("coherency"))
    }
}
