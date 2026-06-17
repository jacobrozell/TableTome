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

    func testPassiveReactionPhasesHaveNoExtraTips() {
        XCTAssertTrue(PhaseContextCoach.quickTips(for: .enemyMovement).isEmpty)
        XCTAssertTrue(PhaseContextCoach.quickTips(for: .endOfAnyTurn).isEmpty)
    }
}
