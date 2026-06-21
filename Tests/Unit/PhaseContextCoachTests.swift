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
        XCTAssertTrue(tips.joined().localizedCaseInsensitiveContains("objectives"))
        XCTAssertTrue(tips.joined().localizedCaseInsensitiveContains("Table State"))
    }

    func testWh40k11eChargePhaseRollsBeforeTargets() {
        let tips = PhaseContextCoach.quickTips(for: .charge, gameSystemId: "wh40k-11e")
        XCTAssertTrue(tips.joined().localizedCaseInsensitiveContains("2D6"))
        XCTAssertTrue(tips.joined().localizedCaseInsensitiveContains("12"))
        XCTAssertTrue(tips.joined().localizedCaseInsensitiveContains("first"))
    }

    func testWh40k11eCommandPhaseMentionsHalfStrength() {
        let tips = PhaseContextCoach.quickTips(for: .command, gameSystemId: "wh40k-11e")
        XCTAssertTrue(tips.joined().localizedCaseInsensitiveContains("Half-strength"))
    }

    func testWh40k11eChargePhaseMentionsVerticalEngagement() {
        let tips = PhaseContextCoach.quickTips(for: .charge, gameSystemId: "wh40k-11e")
        XCTAssertTrue(tips.joined().localizedCaseInsensitiveContains("5 inches vertically"))
    }

    func testWh40k11eEndOfTurnMentionsCoherency() {
        let tips = PhaseContextCoach.quickTips(for: .endOfTurn, gameSystemId: "wh40k-11e")
        XCTAssertTrue(tips.joined().localizedCaseInsensitiveContains("coherency"))
    }
}
