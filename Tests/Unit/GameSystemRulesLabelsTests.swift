import XCTest
@testable import TabletomeDomain

final class GameSystemRulesLabelsTests: XCTestCase {
    func testAosLabels() {
        XCTAssertEqual(GameSystemRulesLabels.tabTitle(gameSystemId: "aos-spearhead"), "AoS")
        XCTAssertEqual(
            GameSystemRulesLabels.rulesReferenceTitle(gameSystemId: "aos-spearhead"),
            "AoS Rules"
        )
        XCTAssertEqual(
            GameSystemRulesLabels.glossaryTitle(gameSystemId: "aos-spearhead"),
            "AoS Glossary"
        )
    }

    func test40kLabels() {
        XCTAssertEqual(GameSystemRulesLabels.tabTitle(gameSystemId: "wh40k-11e"), "40k")
        XCTAssertEqual(
            GameSystemRulesLabels.rulesReferenceTitle(gameSystemId: "wh40k-11e"),
            "40k Rules"
        )
    }

    func testCombatPatrolLabels() {
        XCTAssertEqual(GameSystemRulesLabels.tabTitle(gameSystemId: "wh40k-10e-cp"), "CP")
        XCTAssertEqual(
            GameSystemRulesLabels.rulesReferenceTitle(gameSystemId: "wh40k-10e-cp"),
            "Combat Patrol Rules"
        )
        XCTAssertEqual(
            GameSystemRulesLabels.availableCategories(gameSystemId: "wh40k-10e-cp"),
            [.core, .combatPatrol, .glossary]
        )
        XCTAssertEqual(
            GameSystemRulesLabels.categoryLabel(.combatPatrol, gameSystemId: "wh40k-10e-cp"),
            "Combat Patrol"
        )
    }

    func testSpearheadCategoriesExcludeCombatPatrol() {
        XCTAssertEqual(
            GameSystemRulesLabels.availableCategories(gameSystemId: "aos-spearhead"),
            [.core, .spearhead, .glossary]
        )
    }
}
