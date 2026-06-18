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

    func testDismissesPileInGuide() {
        XCTAssertFalse(NewPlayerTipsStore.hasDismissedPileInGuide)
        NewPlayerTipsStore.dismissPileInGuide()
        XCTAssertTrue(NewPlayerTipsStore.hasDismissedPileInGuide)
    }

    func testResetAllClearsTips() {
        NewPlayerTipsStore.markBattleTrackerCoachSeen()
        NewPlayerTipsStore.dismissCombatSequencePrimer()
        NewPlayerTipsStore.dismissPileInGuide()
        NewPlayerTipsStore.markGuidedMatchSetupExpanded()

        NewPlayerTipsStore.resetAll()

        XCTAssertFalse(NewPlayerTipsStore.hasSeenBattleTrackerCoach)
        XCTAssertFalse(NewPlayerTipsStore.hasDismissedCombatSequencePrimer)
        XCTAssertFalse(NewPlayerTipsStore.hasDismissedPileInGuide)
        XCTAssertFalse(NewPlayerTipsStore.hasExpandedGuidedMatchSetup)
    }

    func testGuidedMatchSetupExpandedDefaultsToCollapsed() {
        XCTAssertFalse(NewPlayerTipsStore.hasExpandedGuidedMatchSetup)
    }

    func testMarksGuidedMatchSetupExpanded() {
        NewPlayerTipsStore.markGuidedMatchSetupExpanded()
        XCTAssertTrue(NewPlayerTipsStore.hasExpandedGuidedMatchSetup)
    }
}
