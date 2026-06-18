import XCTest
@testable import TabletomeDomain

final class MatchWinnerResolverTests: XCTestCase {
    func testPlayerOneWins() {
        XCTAssertEqual(MatchWinnerResolver.resolve(playerOneVP: 14, playerTwoVP: 8), .playerOne)
    }

    func testPlayerTwoWins() {
        XCTAssertEqual(MatchWinnerResolver.resolve(playerOneVP: 6, playerTwoVP: 12), .playerTwo)
    }

    func testTie() {
        XCTAssertEqual(MatchWinnerResolver.resolve(playerOneVP: 10, playerTwoVP: 10), .tie)
    }
}
