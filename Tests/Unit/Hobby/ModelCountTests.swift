import XCTest
@testable import TabletomeDomain

final class HobbyModelCountTests: XCTestCase {
    func testSingleParenGroupTimesQty() {
        XCTAssertEqual(ModelCount.of(name: "Clanrats (5)", qty: 2), 10)
    }

    func testSumsAllIntegersInsideParens() {
        XCTAssertEqual(ModelCount.of(name: "Reclusians + Memorians (x3 + x2)", qty: 1), 5)
    }

    func testFallsBackToQtyWhenNoParens() {
        XCTAssertEqual(ModelCount.of(name: "Lord-Vigilant", qty: 3), 3)
    }

    func testClampsQtyToAtLeastOne() {
        XCTAssertEqual(ModelCount.of(name: "Lord-Vigilant", qty: 0), 1)
        XCTAssertEqual(ModelCount.of(name: "Clanrats (5)", qty: -1), 5)
    }
}
