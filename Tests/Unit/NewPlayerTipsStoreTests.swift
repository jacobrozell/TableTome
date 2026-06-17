import XCTest
@testable import TabletomeDomain

final class NewPlayerTipsStoreTests: XCTestCase {
    override func tearDown() {
        NewPlayerTipsStore.resetAll()
        super.tearDown()
    }

    func testBattleTrackerCoachDefaultsToUnseen() {
        XCTAssertFalse(NewPlayerTipsStore.hasSeenBattleTrackerCoach)
    }

    func testMarksBattleTrackerCoachSeen() {
        NewPlayerTipsStore.markBattleTrackerCoachSeen()
        XCTAssertTrue(NewPlayerTipsStore.hasSeenBattleTrackerCoach)
    }

    func testDismissesCombatSequencePrimer() {
        XCTAssertFalse(NewPlayerTipsStore.hasDismissedCombatSequencePrimer)
        NewPlayerTipsStore.dismissCombatSequencePrimer()
        XCTAssertTrue(NewPlayerTipsStore.hasDismissedCombatSequencePrimer)
        NewPlayerTipsStore.resetAll()
        XCTAssertFalse(NewPlayerTipsStore.hasDismissedCombatSequencePrimer)
    }

    func testResetAllClearsTips() {
        NewPlayerTipsStore.markBattleTrackerCoachSeen()
        NewPlayerTipsStore.dismissCombatSequencePrimer()

        NewPlayerTipsStore.resetAll()

        XCTAssertFalse(NewPlayerTipsStore.hasSeenBattleTrackerCoach)
        XCTAssertFalse(NewPlayerTipsStore.hasDismissedCombatSequencePrimer)
    }
}
