import XCTest
@testable import TabletomeDomain

final class MatchDurationFormatterTests: XCTestCase {
    func testShortDuration() {
        XCTAssertEqual(MatchDurationFormatter.label(for: 30), "< 1 min")
    }

    func testMinutesDuration() {
        XCTAssertEqual(MatchDurationFormatter.label(for: 45 * 60), "45 min")
    }

    func testHoursDuration() {
        XCTAssertEqual(MatchDurationFormatter.label(for: (2 * 60 + 15) * 60), "2 hr 15 min")
    }
}

final class MatchHistoryDisplayFormatterTests: XCTestCase {
    func testMatchupTitle() {
        let record = MatchRecord(
            gameSystemId: "aos-spearhead",
            gameSystemName: "Spearhead",
            createdAt: Date(),
            endedAt: Date(),
            status: .completed,
            players: MatchPlayerSummary(
                playerOneName: "Alice",
                playerTwoName: "Bob",
                playerOneArmyLabel: "A",
                playerTwoArmyLabel: "B"
            ),
            setup: MatchSetupSummary(),
            result: MatchResultSummary(
                playerOneVictoryPoints: 10,
                playerTwoVictoryPoints: 8,
                winner: .playerOne,
                battleRound: 4
            )
        )

        XCTAssertEqual(
            MatchHistoryDisplayFormatter.matchupTitle(for: record),
            "Alice vs Bob"
        )
    }

    func testRelativeDateLabelToday() {
        let now = Date()
        let label = MatchHistoryDisplayFormatter.relativeDateLabel(for: now, now: now)
        XCTAssertFalse(label.isEmpty)
    }
}
