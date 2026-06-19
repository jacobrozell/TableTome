import XCTest
@testable import Tabletome
@testable import TabletomeData
@testable import TabletomeDomain

@MainActor
final class RulesReferenceViewModelTests: XCTestCase {
    private var viewModel: RulesReferenceViewModel {
        RulesReferenceViewModel(
            rulesRepository: BundledRulesRepository(bundle: Bundle(for: RulesReferenceViewModelTests.self))
        )
    }

    func testLoadsSpearheadRuleSections() async {
        let viewModel = viewModel
        await viewModel.load()

        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.sections.count, 20)
    }

    func testFiltersByCategory() async {
        let viewModel = viewModel
        await viewModel.load()
        viewModel.selectedCategory = .core

        XCTAssertEqual(viewModel.filteredSections.count, 13)
        XCTAssertTrue(viewModel.filteredSections.allSatisfy { $0.category == .core })
    }

    func testSearchMatchesTitleAndContent() async {
        let viewModel = viewModel
        await viewModel.load()
        viewModel.searchText = "contest"

        XCTAssertTrue(viewModel.filteredSections.contains { $0.id == "glossary-contest" })
    }

    func testFilteredSectionsStayOrdered() async {
        let viewModel = viewModel
        await viewModel.load()

        let orders = viewModel.filteredSections.map(\.order)
        XCTAssertEqual(orders, orders.sorted())
    }

    func testLoadPreservesCategoryAndSearch() async {
        let viewModel = viewModel
        await viewModel.load()
        viewModel.selectedCategory = .core
        viewModel.searchText = "battle"

        await viewModel.load()

        XCTAssertEqual(viewModel.selectedCategory, .core)
        XCTAssertEqual(viewModel.searchText, "battle")
        XCTAssertFalse(viewModel.filteredSections.isEmpty)
    }

    func testSelectSameGameSystemDoesNotResetFilters() async {
        let viewModel = viewModel
        await viewModel.load()
        viewModel.selectedCategory = .glossary
        viewModel.searchText = "rend"

        viewModel.selectGameSystem(viewModel.selectedGameSystemId)

        XCTAssertEqual(viewModel.selectedCategory, .glossary)
        XCTAssertEqual(viewModel.searchText, "rend")
    }
}
