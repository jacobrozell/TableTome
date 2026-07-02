import XCTest
@testable import TabletomeDomain

final class PhaseContextCoachTests: XCTestCase {
    func testSpearheadHeroPhaseLinksToBattleRoundRules() {
        XCTAssertEqual(
            PhaseContextCoach.ruleSectionId(for: .hero, gameSystemId: "aos-spearhead"),
            "spearhead-battle-round"
        )
    }

    func testSpearheadEndOfTurnLinksToScoring() {
        XCTAssertEqual(
            PhaseContextCoach.ruleSectionId(for: .endOfTurn, gameSystemId: "aos-spearhead"),
            "spearhead-scoring"
        )
    }

    func testWh40k11eCommandPhaseLinksToRules() {
        XCTAssertEqual(
            PhaseContextCoach.ruleSectionId(for: .command, gameSystemId: "wh40k-11e"),
            "11e-command-phase"
        )
    }

    func testCombatPatrolShootingLinksToCombatSequence() {
        XCTAssertEqual(
            PhaseContextCoach.ruleSectionId(for: .shooting, gameSystemId: "wh40k-10e-cp"),
            "combat-sequence"
        )
    }

    func testUnknownPhaseReturnsNilForSpearhead() {
        XCTAssertNil(PhaseContextCoach.ruleSectionId(for: .scoring, gameSystemId: "aos-spearhead"))
    }

    func testSpearheadHeroPhaseActionNudgeMentionsHitRolls() {
        let nudge = PhaseContextCoach.phaseActionNudge(for: .combat, gameSystemId: "aos-spearhead")
        XCTAssertNotNil(nudge)
        XCTAssertTrue(nudge?.localizedCaseInsensitiveContains("hit") == true)
    }

    func testSpearheadHeroQuickTipsMentionBattleTacticCommands() {
        let tips = PhaseContextCoach.quickTips(for: .hero, gameSystemId: "aos-spearhead")
        XCTAssertTrue(tips.contains { $0.localizedCaseInsensitiveContains("command") })
    }

    func testSpearheadEndOfTurnQuickTipsMentionCommandTradeoff() {
        let tips = PhaseContextCoach.quickTips(for: .endOfTurn, gameSystemId: "aos-spearhead")
        XCTAssertTrue(tips.contains { $0.localizedCaseInsensitiveContains("command") })
    }

    func testWh40k11eShootingPhaseActionNudgeMentionsHitRolls() {
        let nudge = PhaseContextCoach.phaseActionNudge(for: .shooting, gameSystemId: "wh40k-11e")
        XCTAssertNotNil(nudge)
        XCTAssertTrue(nudge?.localizedCaseInsensitiveContains("hit") == true)
    }
}
