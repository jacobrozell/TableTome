import XCTest
@testable import TabletomeDomain

final class MatchLogRecorderTests: XCTestCase {
    private let gameSystemId = "test-match-log"

    override func tearDown() {
        MatchLogRecorder.discard(gameSystemId: gameSystemId)
        super.tearDown()
    }

    func testEnsureSessionCreatesMatchStarted() {
        MatchLogRecorder.ensureSession(gameSystemId: gameSystemId)
        let log = MatchLogStore.load(gameSystemId: gameSystemId)
        XCTAssertEqual(log?.events.count, 1)
        XCTAssertEqual(log?.events.first?.kind, .matchStarted)
    }

    func testRecordAppendsVictoryPointsEvent() {
        MatchLogRecorder.record(
            gameSystemId: gameSystemId,
            kind: .victoryPointsChanged,
            payload: MatchLogEventPayload(
                round: 2,
                playerIsOne: true,
                playerName: "Alice",
                delta: 2,
                newTotal: 6,
                pointsReason: .objective
            )
        )
        let events = MatchLogStore.load(gameSystemId: gameSystemId)?.events ?? []
        XCTAssertEqual(events.count, 2)
        XCTAssertEqual(events.last?.kind, .victoryPointsChanged)
        XCTAssertEqual(events.last?.payload.delta, 2)
    }

    func testDrainForArchiveAppendsMatchEndedAndClears() {
        MatchLogRecorder.ensureSession(gameSystemId: gameSystemId)
        let drained = MatchLogRecorder.drainForArchive(gameSystemId: gameSystemId, status: .completed)
        XCTAssertEqual(drained.last?.kind, .matchEnded)
        XCTAssertNil(MatchLogStore.load(gameSystemId: gameSystemId))
    }
}
