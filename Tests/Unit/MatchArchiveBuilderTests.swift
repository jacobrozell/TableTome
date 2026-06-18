import XCTest
@testable import TabletomeDomain

final class MatchArchiveBuilderTests: XCTestCase {
    func testBuildRecordDenormalizesArmyLabels() {
        var matchState = GuidedMatchState()
        matchState.playerOne = PlayerArmySelection(
            playerName: "Alice",
            factionId: "skaven",
            armyId: "gnawfeast-clawpack"
        )
        matchState.playerTwo = PlayerArmySelection(
            playerName: "Bob",
            factionId: "stormcast",
            armyId: "vigilant-brotherhood"
        )
        let tracker = BattleTrackerState(
            battleRound: 4,
            playerOneVictoryPoints: 14,
            playerTwoVictoryPoints: 8
        )
        let endedAt = Date(timeIntervalSince1970: 1_700_000_000)
        let startedAt = endedAt.addingTimeInterval(-3_600)

        let record = MatchArchiveBuilder.buildRecord(
            from: MatchArchiveInput(
                gameSystemId: "aos-spearhead",
                gameSystemName: "Spearhead",
                matchState: matchState,
                trackerState: tracker,
                status: .completed,
                startedAt: startedAt,
                endedAt: endedAt,
                playerOneArmyLabel: "Skaven — Gnawfeast Clawpack",
                playerTwoArmyLabel: "Stormcast — Vigilant Brotherhood",
                playerOneVictoryPoints: 14,
                playerTwoVictoryPoints: 8
            )
        )

        XCTAssertEqual(record.players.playerOneName, "Alice")
        XCTAssertEqual(record.players.playerOneArmyLabel, "Skaven — Gnawfeast Clawpack")
        XCTAssertEqual(record.result.winner, .playerOne)
        XCTAssertEqual(record.result.battleRound, 4)
        XCTAssertEqual(record.createdAt, startedAt)
        XCTAssertEqual(record.status, .completed)
    }
}
