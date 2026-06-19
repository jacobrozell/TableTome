import XCTest
@testable import TabletomeDomain

final class MatchSessionStoreTests: XCTestCase {
    private let gameSystemId = "test-match-session"

    override func tearDown() {
        MatchSessionStore.clear(gameSystemId: gameSystemId)
        super.tearDown()
    }

    func testMarkStartedIfNeededIsIdempotent() {
        let first = Date(timeIntervalSince1970: 1_700_000_000)
        MatchSessionStore.markStartedIfNeeded(gameSystemId: gameSystemId, at: first)
        MatchSessionStore.markStartedIfNeeded(gameSystemId: gameSystemId, at: Date(timeIntervalSince1970: 9_999_999_999))

        XCTAssertEqual(MatchSessionStore.startedAt(gameSystemId: gameSystemId), first)
    }

    func testClearRemovesStartedAt() {
        MatchSessionStore.markStartedIfNeeded(gameSystemId: gameSystemId)
        XCTAssertNotNil(MatchSessionStore.startedAt(gameSystemId: gameSystemId))

        MatchSessionStore.clear(gameSystemId: gameSystemId)

        XCTAssertNil(MatchSessionStore.startedAt(gameSystemId: gameSystemId))
    }

    func testStartedAtReturnsNilWhenUnset() {
        XCTAssertNil(MatchSessionStore.startedAt(gameSystemId: gameSystemId))
    }
}
