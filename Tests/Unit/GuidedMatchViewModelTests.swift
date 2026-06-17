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
}

private struct StubSpearheadCatalogRepository: SpearheadCatalogRepository {
    let catalog: SpearheadCatalog

    func loadCatalog() async throws -> SpearheadCatalog { catalog }
}
