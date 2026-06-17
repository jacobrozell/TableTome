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
        XCTAssertEqual(viewModel.sections.count, 7)
    }

    func testFiltersByCategory() async {
        let viewModel = viewModel
        await viewModel.load()
        viewModel.selectedCategory = .core

        XCTAssertEqual(viewModel.filteredSections.count, 3)
        XCTAssertTrue(viewModel.filteredSections.allSatisfy { $0.category == .core })
    }

    func testSearchMatchesTitleAndContent() async {
        let viewModel = viewModel
        await viewModel.load()
        viewModel.searchText = "contest"

        XCTAssertEqual(viewModel.filteredSections.map(\.id), ["glossary-contest"])
    }

    func testFilteredSectionsStayOrdered() async {
        let viewModel = viewModel
        await viewModel.load()

        let orders = viewModel.filteredSections.map(\.order)
        XCTAssertEqual(orders, orders.sorted())
    }
}
