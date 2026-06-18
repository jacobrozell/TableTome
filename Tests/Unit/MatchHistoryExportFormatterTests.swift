import XCTest
@testable import TabletomeDomain

final class MatchHistoryExportFormatterTests: XCTestCase {
    func testTextIncludesMatchupAndLogLines() {
        let endedAt = Date(timeIntervalSince1970: 1_700_000_000)
        let record = MatchRecord(
            gameSystemId: "aos-spearhead",
            gameSystemName: "Spearhead",
            createdAt: endedAt.addingTimeInterval(-3_600),
            endedAt: endedAt,
            status: .completed,
            players: MatchPlayerSummary(
                playerOneName: "Alice",
                playerTwoName: "Bob",
                playerOneArmyLabel: "Skaven — Gnawfeast",
                playerTwoArmyLabel: "Stormcast — Vigilant"
            ),
            setup: MatchSetupSummary(),
            result: MatchResultSummary(
                playerOneVictoryPoints: 14,
                playerTwoVictoryPoints: 8,
                winner: .playerOne,
                battleRound: 4
            )
        )
        let events = [
            MatchLogEvent(
                matchId: record.id,
                timestamp: endedAt.addingTimeInterval(-60),
                kind: .matchStarted,
                payload: MatchLogEventPayload()
            ),
            MatchLogEvent(
                matchId: record.id,
                timestamp: endedAt,
                kind: .victoryPointsChanged,
                payload: MatchLogEventPayload(
                    playerName: "Alice",
                    delta: 2,
                    pointsReason: .objective
                )
            )
        ]

        let text = MatchHistoryExportFormatter.text(record: record, events: events)

        XCTAssertTrue(text.contains("Tabletome Match Summary"))
        XCTAssertTrue(text.contains("Alice"))
        XCTAssertTrue(text.contains("Bob"))
        XCTAssertTrue(text.contains("14 – 8"))
        XCTAssertTrue(text.contains("Match Log"))
        XCTAssertTrue(text.contains("Match started"))
        XCTAssertTrue(text.contains("Duration:"))
        XCTAssertTrue(text.contains("Status:"))
    }

    func testTextWhenNoEvents() {
        let endedAt = Date(timeIntervalSince1970: 1_700_000_000)
        let record = MatchRecord(
            gameSystemId: "aos-spearhead",
            gameSystemName: "Spearhead",
            createdAt: endedAt,
            endedAt: endedAt,
            status: .abandoned,
            players: MatchPlayerSummary(
                playerOneName: "A",
                playerTwoName: "B",
                playerOneArmyLabel: "Army A",
                playerTwoArmyLabel: "Army B"
            ),
            setup: MatchSetupSummary(),
            result: MatchResultSummary(
                playerOneVictoryPoints: 0,
                playerTwoVictoryPoints: 0,
                winner: .undecided,
                battleRound: 1
            )
        )

        let text = MatchHistoryExportFormatter.text(record: record, events: [])

        XCTAssertTrue(text.contains("No match log events recorded."))
    }
}
