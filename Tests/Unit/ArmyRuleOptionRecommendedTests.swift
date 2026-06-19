import XCTest
@testable import TabletomeDomain

final class ArmyRuleOptionRecommendedTests: XCTestCase {
    func testRecommendedDefaultPrefersMarkedOption() {
        let options = [
            ArmyRuleOption(
                id: "optional",
                name: "Optional",
                summary: "Swap later",
                timing: "Pre-battle — optional Enhancement"
            ),
            ArmyRuleOption(
                id: "default",
                name: "Default",
                summary: "Starter pick",
                newPlayerHint: "Recommended first game",
                timing: "Pre-battle — default Enhancement"
            )
        ]

        XCTAssertEqual(ArmyRuleOption.recommendedDefault(in: options)?.id, "default")
    }
}
