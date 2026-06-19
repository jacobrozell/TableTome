import XCTest
@testable import Tabletome
@testable import TabletomeData
@testable import TabletomeDomain

@MainActor
final class AppSearchViewModelTests: XCTestCase {
    private func makeViewModel(gameSystemId: String = "aos-spearhead") -> AppSearchViewModel {
        AppSearchViewModel(
            rulesRepository: BundledRulesRepository(bundle: Bundle(for: AppSearchViewModelTests.self)),
            catalogRepository: { _ in
                BundledSpearheadCatalogRepository(bundle: Bundle(for: AppSearchViewModelTests.self))
            },
            gameSystemId: gameSystemId
        )
    }

    func testLoadBuildsSearchIndex() async throws {
        let viewModel = makeViewModel()
        await viewModel.load()

        XCTAssertFalse(viewModel.index.isEmpty)
        XCTAssertFalse(viewModel.ruleSections.isEmpty)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testSearchResultsFilterByQuery() async {
        let viewModel = makeViewModel()
        await viewModel.load()
        viewModel.searchText = "rend"

        XCTAssertTrue(viewModel.isShowingSearchResults)
        XCTAssertTrue(viewModel.searchResults.contains { $0.referenceId == "rend" })
    }

    func testSelectGameSystemUpdatesScope() async {
        let viewModel = makeViewModel()
        await viewModel.load()
        let original = viewModel.scopedGameSystemId

        viewModel.selectGameSystem(original)
        XCTAssertEqual(viewModel.scopedGameSystemId, original)
        XCTAssertTrue(viewModel.searchText.isEmpty)
    }

    func testGroupedSearchResultsRespectVisibleKinds() async {
        let viewModel = makeViewModel()
        await viewModel.load()
        viewModel.searchText = "rend"

        let groups = viewModel.groupedSearchResults
        XCTAssertFalse(groups.isEmpty)
        XCTAssertTrue(groups.allSatisfy { !$0.results.isEmpty })
    }
}
