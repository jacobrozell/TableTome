import XCTest
@testable import TabletomeDomain

final class MatchLogSummaryFormatterTests: XCTestCase {
    func testVictoryPointsTitle() {
        let event = MatchLogEvent(
            matchId: UUID(),
            kind: .victoryPointsChanged,
            payload: MatchLogEventPayload(
                playerName: "Alice",
                delta: 2,
                pointsReason: .objective
            )
        )
        let title = MatchLogSummaryFormatter.title(for: event)
        XCTAssertTrue(title.contains("Alice"))
        XCTAssertTrue(title.contains("+2"))
    }

    func testDamageTitle() {
        let event = MatchLogEvent(
            matchId: UUID(),
            kind: .damageApplied,
            payload: MatchLogEventPayload(
                unitName: "Liberators",
                woundsRemoved: 3,
                woundsRemaining: 4
            )
        )
        let title = MatchLogSummaryFormatter.title(for: event)
        XCTAssertTrue(title.contains("Liberators"))
        XCTAssertTrue(title.contains("3"))
    }

    func testCombatBatchTitle() {
        let event = MatchLogEvent(
            matchId: UUID(),
            kind: .combatBatchResolved,
            payload: MatchLogEventPayload(
                attackerUnitName: "Liberators",
                defenderUnitName: "Gutrippas",
                weaponName: "Warblade",
                combatHits: 5,
                combatWounds: 3,
                combatFailedSaves: 2,
                combatDamageDealt: 4
            )
        )
        let title = MatchLogSummaryFormatter.title(for: event)
        XCTAssertTrue(title.contains("Liberators"))
        XCTAssertTrue(title.contains("Gutrippas"))
        XCTAssertTrue(title.contains("Warblade"))

        let subtitle = MatchLogSummaryFormatter.subtitle(for: event)
        XCTAssertTrue(subtitle?.contains("5") == true)
        XCTAssertTrue(subtitle?.contains("4") == true)
    }

    func testPhaseTitleUsesFriendlyName() {
        let event = MatchLogEvent(
            matchId: UUID(),
            kind: .phaseChanged,
            payload: MatchLogEventPayload(
                round: 2,
                phaseId: BattleTurnPhase.combat.rawValue
            )
        )
        let title = MatchLogSummaryFormatter.title(for: event)
        XCTAssertTrue(title.contains("Fight Phase"))
    }

    func testDeploymentStepUsesChecklistTitle() {
        let event = MatchLogEvent(
            matchId: UUID(),
            kind: .deploymentStepCompleted,
            payload: MatchLogEventPayload(stepId: DeploymentChecklistStep.setupTerrain.rawValue)
        )
        let title = MatchLogSummaryFormatter.title(for: event)
        XCTAssertFalse(title.contains("setupTerrain"))
        XCTAssertTrue(title.contains("Terrain") || title.contains("terrain"))
    }
}
