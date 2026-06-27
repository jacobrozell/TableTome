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
        NewPlayerTipsStore.markPhysicalDiceResolverHintSeen()
        NewPlayerTipsStore.dismissHeroRoundOneNudge()
        NewPlayerTipsStore.dismissWargamePrimer()

        NewPlayerTipsStore.resetAll()

        XCTAssertFalse(NewPlayerTipsStore.hasSeenBattleTrackerCoach)
        XCTAssertFalse(NewPlayerTipsStore.hasDismissedCombatSequencePrimer)
        XCTAssertFalse(NewPlayerTipsStore.hasDismissedPileInGuide)
        XCTAssertFalse(NewPlayerTipsStore.hasExpandedGuidedMatchSetup)
        XCTAssertFalse(NewPlayerTipsStore.hasSeenPhysicalDiceResolverHint)
        XCTAssertFalse(NewPlayerTipsStore.hasDismissedHeroRoundOneNudge)
        XCTAssertFalse(NewPlayerTipsStore.hasDismissedWargamePrimer)
    }

    func testGuidedMatchSetupExpandedDefaultsToCollapsed() {
        XCTAssertFalse(NewPlayerTipsStore.hasExpandedGuidedMatchSetup)
    }

    func testMarksGuidedMatchSetupExpanded() {
        NewPlayerTipsStore.markGuidedMatchSetupExpanded()
        XCTAssertTrue(NewPlayerTipsStore.hasExpandedGuidedMatchSetup)
    }

    func testPhysicalDiceResolverHintDefaultsToUnseen() {
        XCTAssertFalse(NewPlayerTipsStore.hasSeenPhysicalDiceResolverHint)
    }

    func testMarksPhysicalDiceResolverHintSeen() {
        NewPlayerTipsStore.markPhysicalDiceResolverHintSeen()
        XCTAssertTrue(NewPlayerTipsStore.hasSeenPhysicalDiceResolverHint)
    }

    func testDismissesHeroRoundOneNudge() {
        XCTAssertFalse(NewPlayerTipsStore.hasDismissedHeroRoundOneNudge)
        NewPlayerTipsStore.dismissHeroRoundOneNudge()
        XCTAssertTrue(NewPlayerTipsStore.hasDismissedHeroRoundOneNudge)
    }

    func testDismissesWargamePrimer() {
        XCTAssertFalse(NewPlayerTipsStore.hasDismissedWargamePrimer)
        NewPlayerTipsStore.dismissWargamePrimer()
        XCTAssertTrue(NewPlayerTipsStore.hasDismissedWargamePrimer)
    }
}
