import XCTest
@testable import Tabletome
@testable import TabletomeDomain

final class SpearheadHubTabsTests: XCTestCase {
    func testVisibleTabsBeforeArmiesChosen() {
        XCTAssertEqual(
            SpearheadHubTabs.visibleTabs(hasBothArmies: false),
            [.armies]
        )
    }

    func testVisibleTabsAfterArmiesChosen() {
        XCTAssertEqual(
            SpearheadHubTabs.visibleTabs(hasBothArmies: true),
            [.setup, .battle]
        )
    }

    func testSuggestedTabProgression() {
        XCTAssertEqual(
            SpearheadHubTabs.suggested(hasBothArmies: false, setupComplete: false),
            .armies
        )
        XCTAssertEqual(
            SpearheadHubTabs.suggested(hasBothArmies: true, setupComplete: false),
            .setup
        )
        XCTAssertEqual(
            SpearheadHubTabs.suggested(hasBothArmies: true, setupComplete: true),
            .battle
        )
    }

    func testPadDetailDestinationOpensNextSetupStep() {
        XCTAssertEqual(
            SpearheadHubTabs.padDetailDestination(
                hasBothArmies: true,
                setupComplete: false,
                nextIncompleteStepId: "regiment-abilities"
            ),
            .step("regiment-abilities")
        )
    }

    func testPadDetailDestinationOpensBattleWhenSetupComplete() {
        XCTAssertEqual(
            SpearheadHubTabs.padDetailDestination(
                hasBothArmies: true,
                setupComplete: true,
                nextIncompleteStepId: nil
            ),
            .battleTracker
        )
    }
}
