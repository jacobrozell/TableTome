import XCTest
@testable import TabletomeData
@testable import TabletomeDomain

final class JSONMatchHistoryRepositoryTests: XCTestCase {
    private var tempDirectory: URL!
    private var repository: JSONMatchHistoryRepository!

    override func setUp() async throws {
        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        repository = JSONMatchHistoryRepository(baseDirectory: tempDirectory)
    }

    override func tearDown() async throws {
        try? FileManager.default.removeItem(at: tempDirectory)
    }

    func testArchiveAndFetchAll() async throws {
        let record = sampleRecord(gameSystemId: "aos-spearhead", playerOneVP: 12, playerTwoVP: 9)
        try await repository.archive(record: record, log: [])

        let all = try await repository.fetchRecords(limit: nil, gameSystemId: nil)
        XCTAssertEqual(all.count, 1)
        XCTAssertEqual(all.first?.id, record.id)
    }

    func testFilterByGameSystem() async throws {
        try await repository.archive(record: sampleRecord(gameSystemId: "aos-spearhead"), log: [])
        try await repository.archive(record: sampleRecord(gameSystemId: "sc-tmg"), log: [])

        let spearheadOnly = try await repository.fetchRecords(limit: nil, gameSystemId: "aos-spearhead")
        XCTAssertEqual(spearheadOnly.count, 1)
        XCTAssertEqual(spearheadOnly.first?.gameSystemId, "aos-spearhead")
    }

    func testFilterByProfileId() async throws {
        let jacobId = UUID()
        let chrisId = UUID()
        var jacobMatch = sampleRecord(gameSystemId: "aos-spearhead")
        jacobMatch = MatchRecord(
            id: jacobMatch.id,
            gameSystemId: jacobMatch.gameSystemId,
            gameSystemName: jacobMatch.gameSystemName,
            createdAt: jacobMatch.createdAt,
            endedAt: jacobMatch.endedAt,
            status: jacobMatch.status,
            players: MatchPlayerSummary(
                playerOneName: "Jacob",
                playerTwoName: "Chris",
                playerOneArmyLabel: "A",
                playerTwoArmyLabel: "B",
                playerOneProfileId: jacobId
            ),
            setup: jacobMatch.setup,
            result: jacobMatch.result
        )
        var chrisMatch = sampleRecord(gameSystemId: "aos-spearhead")
        chrisMatch = MatchRecord(
            id: chrisMatch.id,
            gameSystemId: chrisMatch.gameSystemId,
            gameSystemName: chrisMatch.gameSystemName,
            createdAt: chrisMatch.createdAt,
            endedAt: chrisMatch.endedAt,
            status: chrisMatch.status,
            players: MatchPlayerSummary(
                playerOneName: "Alex",
                playerTwoName: "Chris",
                playerOneArmyLabel: "A",
                playerTwoArmyLabel: "B",
                playerTwoProfileId: chrisId
            ),
            setup: chrisMatch.setup,
            result: chrisMatch.result
        )
        try await repository.archive(record: jacobMatch, log: [])
        try await repository.archive(record: chrisMatch, log: [])

        let jacobOnly = try await repository.fetchRecords(limit: nil, gameSystemId: nil, involvingProfileId: jacobId)
        XCTAssertEqual(jacobOnly.count, 1)
        XCTAssertEqual(jacobOnly.first?.players.playerOneProfileId, jacobId)

        let chrisOnly = try await repository.fetchRecords(limit: nil, gameSystemId: nil, involvingProfileId: chrisId)
        XCTAssertEqual(chrisOnly.count, 1)
        XCTAssertEqual(chrisOnly.first?.players.playerTwoProfileId, chrisId)
    }

    func testDeleteRecord() async throws {
        let record = sampleRecord(gameSystemId: "aos-spearhead")
        try await repository.archive(record: record, log: [])
        try await repository.deleteRecord(id: record.id)

        let all = try await repository.fetchRecords(limit: nil, gameSystemId: nil)
        XCTAssertTrue(all.isEmpty)
    }

    private func sampleRecord(
        gameSystemId: String,
        playerOneVP: Int = 10,
        playerTwoVP: Int = 10
    ) -> MatchRecord {
        MatchRecord(
            gameSystemId: gameSystemId,
            gameSystemName: gameSystemId,
            createdAt: Date(),
            endedAt: Date(),
            status: .completed,
            players: MatchPlayerSummary(
                playerOneName: "P1",
                playerTwoName: "P2",
                playerOneArmyLabel: "Army A",
                playerTwoArmyLabel: "Army B"
            ),
            setup: MatchSetupSummary(),
            result: MatchResultSummary(
                playerOneVictoryPoints: playerOneVP,
                playerTwoVictoryPoints: playerTwoVP,
                winner: MatchWinnerResolver.resolve(playerOneVP: playerOneVP, playerTwoVP: playerTwoVP),
                battleRound: 4
            )
        )
    }
}
