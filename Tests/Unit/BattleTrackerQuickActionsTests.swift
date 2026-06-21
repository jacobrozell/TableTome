import XCTest
@testable import Tabletome

final class BattleTrackerQuickActionsTests: XCTestCase {
    func testShootingPhaseIncludesCombatResolverAction() {
        let actions = BattleTrackerQuickActions.actions(
            phase: .shooting,
            gameSystemId: "aos-spearhead",
            deploymentComplete: true,
            roundOpenerIncomplete: false,
            shootingEligibleCount: 2,
            shootInCombatEligibleCount: 0,
            activePlayerName: "Alex"
        )
        XCTAssertTrue(actions.contains { $0.id == "shooting-units" })
        XCTAssertTrue(actions.contains { $0.id == "resolve-combat" })
    }

    func testIncompleteDeploymentSuggestsSetupTab() {
        let actions = BattleTrackerQuickActions.actions(
            phase: .hero,
            gameSystemId: "aos-spearhead",
            deploymentComplete: false,
            roundOpenerIncomplete: false,
            shootingEligibleCount: 0,
            shootInCombatEligibleCount: 0,
            activePlayerName: "Alex"
        )
        XCTAssertEqual(actions.first?.id, "finish-deployment")
        XCTAssertEqual(actions.first?.target, .sectionTab(.setup))
    }

    func testCombatPhaseIncludesShootInCombatWhenEligible() {
        let actions = BattleTrackerQuickActions.actions(
            phase: .combat,
            gameSystemId: "aos-spearhead",
            deploymentComplete: true,
            roundOpenerIncomplete: false,
            shootingEligibleCount: 0,
            shootInCombatEligibleCount: 1,
            activePlayerName: "Alex"
        )
        XCTAssertTrue(actions.contains { $0.id == "shoot-in-combat" })
        XCTAssertTrue(actions.contains { $0.id == "pile-in-fight" })
    }

    func testEndOfTurnSuggestsVictoryPoints() {
        let actions = BattleTrackerQuickActions.actions(
            phase: .endOfTurn,
            gameSystemId: "aos-spearhead",
            deploymentComplete: true,
            roundOpenerIncomplete: false,
            shootingEligibleCount: 0,
            shootInCombatEligibleCount: 0,
            activePlayerName: "Alex"
        )
        XCTAssertTrue(actions.contains { $0.target == .victoryPoints })
    }

    func testWh40k11eShootingPhaseIncludesCombatResolver() {
        let actions = BattleTrackerQuickActions.actions(
            phase: .shooting,
            gameSystemId: "wh40k-11e",
            deploymentComplete: true,
            roundOpenerIncomplete: false,
            shootingEligibleCount: 2,
            shootInCombatEligibleCount: 0,
            activePlayerName: "Alex"
        )
        XCTAssertTrue(actions.contains { $0.id == "shooting-units" })
        XCTAssertTrue(actions.contains { $0.id == "resolve-combat" })
        XCTAssertFalse(actions.contains { $0.id == "shooting-reminder" })
    }
}
