import XCTest
@testable import TabletomeData
@testable import TabletomeDomain

final class MatchSetupCompletionEvaluatorTests: XCTestCase {
    func testAutoCompletesChooseArmiesWhenBothSelected() async throws {
        let catalog = try await loadCatalog()
        var state = GuidedMatchState()
        state.playerOne.factionId = "skaven"
        state.playerOne.armyId = "gnawfeast-clawpack"
        state.playerTwo.factionId = "stormcast-eternals"
        state.playerTwo.armyId = "vigilant-brotherhood"

        let completed = MatchSetupCompletionEvaluator.autoCompletedStepIds(
            state: state,
            catalog: catalog,
            deploymentSteps: []
        )

        XCTAssertTrue(completed.contains("choose-armies"))
    }

    func testAutoCompletesAttackerWhenChosen() async throws {
        let catalog = try await loadCatalog()
        var state = GuidedMatchState()
        state.attackerIsPlayerOne = true

        let completed = MatchSetupCompletionEvaluator.autoCompletedStepIds(
            state: state,
            catalog: catalog,
            deploymentSteps: []
        )

        XCTAssertTrue(completed.contains("roll-attacker"))
    }

    func testDoesNotAutoCompleteRegimentBeforeRollOff() async throws {
        let catalog = try await loadCatalog()
        var state = GuidedMatchState()
        state.playerOne.factionId = "stormcast-eternals"
        state.playerOne.armyId = "vigilant-brotherhood"
        state.playerOne.regimentAbilityId = "strike-where-needed"
        state.playerTwo.factionId = "skaven"
        state.playerTwo.armyId = "gnawfeast-clawpack"
        state.playerTwo.regimentAbilityId = "too-quick-to-hit"

        let completed = MatchSetupCompletionEvaluator.autoCompletedStepIds(
            state: state,
            catalog: catalog,
            deploymentSteps: []
        )

        XCTAssertFalse(completed.contains("regiment-abilities"))
        XCTAssertFalse(completed.contains("roll-attacker"))
    }

    func testAutoCompletesRegimentAfterRollOff() async throws {
        let catalog = try await loadCatalog()
        var state = GuidedMatchState()
        state.attackerIsPlayerOne = true
        state.playerOne.factionId = "stormcast-eternals"
        state.playerOne.armyId = "vigilant-brotherhood"
        state.playerOne.regimentAbilityId = "strike-where-needed"
        state.playerTwo.factionId = "skaven"
        state.playerTwo.armyId = "gnawfeast-clawpack"
        state.playerTwo.regimentAbilityId = "too-quick-to-hit"

        let completed = MatchSetupCompletionEvaluator.autoCompletedStepIds(
            state: state,
            catalog: catalog,
            deploymentSteps: []
        )

        XCTAssertTrue(completed.contains("roll-attacker"))
        XCTAssertTrue(completed.contains("regiment-abilities"))
    }

    func testAutoCompletesRealmWhenDeploymentFinished() async throws {
        let catalog = try await loadCatalog()
        let deploymentSteps = Set(DeploymentChecklistStep.allCases.map(\.rawValue))

        let completed = MatchSetupCompletionEvaluator.autoCompletedStepIds(
            state: GuidedMatchState(),
            catalog: catalog,
            deploymentSteps: deploymentSteps
        )

        XCTAssertTrue(completed.contains("realm-battlefield"))
    }

    private func loadCatalog() async throws -> SpearheadCatalog {
        try await BundledSpearheadCatalogRepository(
            bundle: Bundle(for: MatchSetupCompletionEvaluatorTests.self)
        ).loadCatalog()
    }
}

final class BattleFlowGuideTests: XCTestCase {
    func testStartsWithDeploymentChecklist() {
        let step = BattleFlowGuide.currentStep(
            matchState: GuidedMatchState(),
            trackerState: BattleTrackerState()
        )

        XCTAssertEqual(step?.kind, .deployment(.chooseRealmSide))
    }

    func testWh40kStartsWithDeploymentChecklist() {
        let step = BattleFlowGuide.currentStep(
            matchState: GuidedMatchState(),
            trackerState: BattleTrackerState(),
            gameSystemId: "wh40k-11e"
        )

        XCTAssertEqual(step?.kind, .wh40kSetup(.chooseMission))
    }

    func testCombatPatrolStartsWithDeploymentChecklist() {
        let step = BattleFlowGuide.currentStep(
            matchState: GuidedMatchState(),
            trackerState: BattleTrackerState(),
            gameSystemId: "wh40k-10e-cp"
        )

        XCTAssertEqual(step?.kind, .cpSetup(.setupTerrain))
    }

    func testCombatPatrolMovesToCommandAfterDeployment() {
        var tracker = BattleTrackerState()
        tracker.completedDeploymentSteps = Set(CombatPatrolDeploymentChecklistStep.allCases.map(\.rawValue))
        tracker.currentPhase = .command

        let step = BattleFlowGuide.currentStep(
            matchState: GuidedMatchState(),
            trackerState: tracker,
            gameSystemId: "wh40k-10e-cp"
        )

        XCTAssertEqual(step?.kind, .turnPhase(.command))
    }

    func testCombatPatrolMainPhasesExcludeDeployment() {
        let engine = GameSystemPlayContext.context(for: "wh40k-10e-cp").playEngine
        let phases = engine.mainPhases()
        XCTAssertEqual(phases.first, .command)
        XCTAssertFalse(phases.contains(.deployment))
        XCTAssertEqual(engine.battleRoundCount(), 5)
    }

    func testMovesToRoundOpenerAfterDeployment() {
        var tracker = BattleTrackerState()
        tracker.completedDeploymentSteps = Set(DeploymentChecklistStep.allCases.map(\.rawValue))

        let step = BattleFlowGuide.currentStep(
            matchState: GuidedMatchState(),
            trackerState: tracker
        )

        XCTAssertEqual(step?.kind, .roundOpener(.firstTurnOrPriority))
    }

    func testSuggestsIdentifyUnderdogWhenVictoryPointsDiffer() {
        let suggested = BattleChecklistCompletionEvaluator.suggestedRoundCompletions(
            round: 1,
            playerOneVictoryPoints: 3,
            playerTwoVictoryPoints: 1
        )

        XCTAssertTrue(suggested.contains(.identifyUnderdog))
    }
}
