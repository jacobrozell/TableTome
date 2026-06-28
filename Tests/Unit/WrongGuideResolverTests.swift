import XCTest
@testable import Tabletome
@testable import TabletomeDomain

final class WrongGuideResolverTests: XCTestCase {
    func testSpearheadChoiceAgainstWh40kGuideSurfacesAlert() {
        let alert = WrongGuideResolver.alert(
            currentGameSystemId: GameSystemId.wh40k11e.rawValue,
            onboardingChoice: GameSystemId.aosSpearhead.rawValue,
            wh40kVariant: nil
        )
        XCTAssertEqual(alert?.suggestedGameSystemId, GameSystemId.aosSpearhead.rawValue)
    }

    func testWh40kChoiceAgainstSpearheadGuideSurfacesAlert() {
        let alert = WrongGuideResolver.alert(
            currentGameSystemId: GameSystemId.aosSpearhead.rawValue,
            onboardingChoice: GameSystemId.wh40k11e.rawValue,
            wh40kVariant: nil
        )
        XCTAssertEqual(alert?.suggestedGameSystemId, GameSystemId.wh40k11e.rawValue)
    }
}
