import XCTest
@testable import Tabletome
@testable import TabletomeDomain

final class BattleTrackerSectionTabTests: XCTestCase {
    func testCombatPatrolShowsAllSectionTabs() {
        let tabs = BattleTrackerSectionTab.visibleTabs(gameSystemId: .wh40k10eCp)
        XCTAssertEqual(tabs, [.setup, .turn, .combat, .army])
    }

    func testWh40k11eHidesCombatTab() {
        let tabs = BattleTrackerSectionTab.visibleTabs(gameSystemId: .wh40k11e)
        XCTAssertEqual(tabs, [.setup, .turn, .army])
    }

    func testSuggestedCombatTabDuringShootingForSpearhead() {
        let tab = BattleTrackerSectionTab.suggested(
            phase: .shooting,
            deploymentComplete: true,
            roundOpenerIncomplete: false,
            gameSystemId: .aosSpearhead
        )
        XCTAssertEqual(tab, .combat)
    }

    func testSuggestedCombatTabDuringShootingForCombatPatrol() {
        let tab = BattleTrackerSectionTab.suggested(
            phase: .shooting,
            deploymentComplete: true,
            roundOpenerIncomplete: false,
            gameSystemId: .wh40k10eCp
        )
        XCTAssertEqual(tab, .combat)
    }

    func testSuggestedTurnTabDuringShootingForFullWh40k() {
        let tab = BattleTrackerSectionTab.suggested(
            phase: .shooting,
            deploymentComplete: true,
            roundOpenerIncomplete: false,
            gameSystemId: .wh40k11e
        )
        XCTAssertEqual(tab, .turn)
    }
}
