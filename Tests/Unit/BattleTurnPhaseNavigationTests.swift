import XCTest
@testable import TabletomeDomain

final class BattleTurnPhaseNavigationTests: XCTestCase {
    func testNextMainPhaseFromHero() {
        XCTAssertEqual(BattleTurnPhase.hero.nextMainPhase, .movement)
    }

    func testNextMainPhaseFromCombat() {
        XCTAssertEqual(BattleTurnPhase.combat.nextMainPhase, .endOfTurn)
    }

    func testEndOfTurnHasNoNextMainPhase() {
        XCTAssertNil(BattleTurnPhase.endOfTurn.nextMainPhase)
    }
}
