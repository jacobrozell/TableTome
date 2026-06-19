import XCTest
@testable import Tabletome
@testable import TabletomeData
@testable import TabletomeDomain

@MainActor
final class GuidedMatchViewModelTests: XCTestCase {
    func testSetupProgressCountsCompletedSteps() async throws {
        let catalog = try await BundledSpearheadCatalogRepository(
            bundle: Bundle(for: GuidedMatchViewModelTests.self)
        ).loadCatalog()

        var state = GuidedMatchState()
        state.completedStepIds = ["choose-armies", "roll-attacker"]

        let viewModel = GuidedMatchViewModel(
            catalogRepository: StubSpearheadCatalogRepository(catalog: catalog),
            initialState: state
        )
        await viewModel.load()

        XCTAssertEqual(viewModel.setupProgress.completed, 2)
        XCTAssertEqual(viewModel.setupProgress.total, catalog.matchSteps.count)
        XCTAssertGreaterThan(viewModel.setupProgressFraction, 0)
        XCTAssertLessThan(viewModel.setupProgressFraction, 1)
    }

    func testPlayerFacingCoverageTitles() {
        XCTAssertEqual(SpearheadContentCoverage.roster.playerFacingTitle, "Army list only")
        XCTAssertEqual(SpearheadContentCoverage.matchSetup.playerFacingTitle, "Setup ready")
        XCTAssertEqual(SpearheadContentCoverage.battleTracker.playerFacingTitle, "Rules reminders ready")
        XCTAssertEqual(SpearheadContentCoverage.warscrolls.playerFacingTitle, "Full tabletop support")
    }

    func testApplyStarterMatchupResetsBattleTracker() async throws {
        let catalog = try await BundledSpearheadCatalogRepository(
            bundle: Bundle(for: GuidedMatchViewModelTests.self)
        ).loadCatalog()

        var tracker = BattleTrackerState()
        tracker.battleRound = 3
        tracker.playerOneVictoryPoints = 5
        BattleTrackerStore.save(tracker)
        defer { BattleTrackerStore.reset() }

        let viewModel = GuidedMatchViewModel(
            catalogRepository: StubSpearheadCatalogRepository(catalog: catalog),
            initialState: GuidedMatchState()
        )
        await viewModel.load()
        viewModel.applyStarterMatchup()

        let loaded = BattleTrackerStore.load()
        XCTAssertEqual(loaded.battleRound, 1)
        XCTAssertEqual(loaded.playerOneVictoryPoints, 0)
        XCTAssertTrue(viewModel.matchState.hasBothArmies)
    }

    func testApplyRecommendedLoadoutsSelectsDefaultsForCombatPatrol() async throws {
        let catalog = try await BundledPlayCatalogRepository(
            bundle: Bundle(for: GuidedMatchViewModelTests.self)
        ).loadCatalog(for: "wh40k-10e-cp")

        var state = GuidedMatchState()
        CombatPatrolFeaturedArmies.applyStarterMatchup(to: &state)

        let viewModel = GuidedMatchViewModel(
            gameSystemId: .wh40k10eCp,
            catalogRepository: StubSpearheadCatalogRepository(catalog: catalog),
            initialState: state
        )
        await viewModel.load()
        viewModel.applyRecommendedLoadouts()

        XCTAssertNotNil(viewModel.matchState.playerOne.enhancementId)
        XCTAssertNotNil(viewModel.matchState.playerOne.secondaryObjectiveId)
        XCTAssertNotNil(viewModel.matchState.playerTwo.enhancementId)
        XCTAssertNotNil(viewModel.matchState.playerTwo.secondaryObjectiveId)
    }

    func testCompleteSetupForAutomationFinishesSpearheadSetup() async throws {
        let catalog = try await BundledSpearheadCatalogRepository(
            bundle: Bundle(for: GuidedMatchViewModelTests.self)
        ).loadCatalog()
        defer {
            MatchSetupStore.reset()
            BattleTrackerStore.reset()
        }

        let viewModel = GuidedMatchViewModel(
            catalogRepository: StubSpearheadCatalogRepository(catalog: catalog),
            initialState: GuidedMatchState()
        )
        await viewModel.load()
        viewModel.applyStarterMatchup()
        viewModel.completeSetupForAutomation()

        XCTAssertNotNil(viewModel.matchState.attackerIsPlayerOne)
        XCTAssertEqual(viewModel.setupProgress.completed, viewModel.setupProgress.total)
        let deployment = BattleTrackerStore.load().completedDeploymentSteps
        XCTAssertEqual(
            deployment.count,
            DeploymentChecklistStep.allCases.count
        )
        for step in DeploymentChecklistStep.allCases {
            XCTAssertTrue(deployment.contains(step.rawValue), "Missing deployment step \(step.rawValue)")
        }
    }
}

private struct StubSpearheadCatalogRepository: SpearheadCatalogRepository {
    let catalog: SpearheadCatalog

    func loadCatalog() async throws -> SpearheadCatalog { catalog }
}
