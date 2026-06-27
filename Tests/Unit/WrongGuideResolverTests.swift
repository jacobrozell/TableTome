import XCTest
@testable import Tabletome
@testable import TabletomeDomain

final class WrongGuideResolverTests: XCTestCase {
    override func setUp() {
        super.setUp()
        FirstSessionStore.clearPersistedState()
    }

    override func tearDown() {
        super.tearDown()
        FirstSessionStore.clearPersistedState()
    }

    func testNoAlertWhenGuidesMatch() {
        XCTAssertNil(
            WrongGuideResolver.alert(
                currentGameSystemId: GameSystemId.aosSpearhead.rawValue,
                onboardingChoice: GameSystemId.aosSpearhead.rawValue,
                wh40kVariant: nil
            )
        )
    }

    func testSpearheadChoiceOnWh40kGuideShowsAlert() {
        let alert = WrongGuideResolver.alert(
            currentGameSystemId: GameSystemId.wh40k11e.rawValue,
            onboardingChoice: GameSystemId.aosSpearhead.rawValue,
            wh40kVariant: nil
        )
        XCTAssertEqual(alert?.suggestedGameSystemId, GameSystemId.aosSpearhead.rawValue)
    }

    func testCombatPatrolChoiceOnWh40k11eGuideShowsAlert() {
        let alert = WrongGuideResolver.alert(
            currentGameSystemId: GameSystemId.wh40k11e.rawValue,
            onboardingChoice: GameSystemId.wh40k10eCp.rawValue,
            wh40kVariant: nil
        )
        XCTAssertEqual(alert?.suggestedGameSystemId, GameSystemId.wh40k10eCp.rawValue)
    }

    func testCombatPatrolVariantOnWh40k11eGuideShowsAlert() {
        let alert = WrongGuideResolver.alert(
            currentGameSystemId: GameSystemId.wh40k11e.rawValue,
            onboardingChoice: GameSystemId.wh40k11e.rawValue,
            wh40kVariant: Wh40kChooserVariant.combatPatrol.rawValue
        )
        XCTAssertEqual(alert?.suggestedGameSystemId, GameSystemId.wh40k10eCp.rawValue)
    }
}
