import XCTest
@testable import TabletomeData
@testable import TabletomeDomain

final class AppSearchEngineTests: XCTestCase {
    private var index: [AppSearchResult] = []

    override func setUp() async throws {
        let rulesRepository = BundledRulesRepository(bundle: Bundle(for: AppSearchEngineTests.self))
        let catalogRepository = BundledSpearheadCatalogRepository(bundle: Bundle(for: AppSearchEngineTests.self))
        let gameSystem = try await rulesRepository.gameSystem(id: "aos-spearhead")
        let catalog = try await catalogRepository.loadCatalog()
        index = AppSearchIndexBuilder.build(gameSystem: gameSystem, catalog: catalog)
    }

    func testIndexIncludesGlossaryWarscrollAndRules() {
        XCTAssertTrue(index.contains { $0.kind == .glossary && $0.referenceId == "rend" })
        XCTAssertTrue(index.contains { $0.kind == .warscroll && $0.title == "Rat Ogors" })
        XCTAssertTrue(index.contains { $0.kind == .ruleSection && $0.referenceId == "combat-sequence" })
    }

    func testSearchFindsRendGlossary() {
        let results = AppSearchEngine.search(query: "rend", in: index)
        XCTAssertTrue(results.contains { $0.kind == .glossary && $0.referenceId == "rend" })
    }

    func testSearchFindsWarpfireGunWarscroll() {
        let results = AppSearchEngine.search(query: "warpfire gun", in: index)
        XCTAssertTrue(
            results.contains {
                $0.kind == .warscroll && $0.detailBody.localizedCaseInsensitiveContains("Warpfire Gun")
            }
        )
    }

    func testSearchFindsPileInAcrossKinds() {
        let results = AppSearchEngine.search(query: "pile in", in: index)
        XCTAssertTrue(results.contains { $0.kind == .glossary && $0.referenceId == "pile-in" })
    }

    func testEmptyQueryReturnsNoResults() {
        XCTAssertTrue(AppSearchEngine.search(query: "", in: index).isEmpty)
        XCTAssertTrue(AppSearchEngine.search(query: "  ", in: index).isEmpty)
    }

    func testSearchFindsChargePhaseRules() {
        let results = AppSearchEngine.search(query: "charge roll", in: index)
        XCTAssertTrue(results.contains { $0.kind == .ruleSection && $0.referenceId == "charge-phase" })
    }

    func testSearchFindsStrikeFirstGlossary() {
        let results = AppSearchEngine.search(query: "strike-first", in: index)
        XCTAssertTrue(results.contains { $0.kind == .glossary && $0.referenceId == "strike-first" })
    }

    func testSingleCharacterTokensAreIgnored() {
        let shortQuery = AppSearchEngine.search(query: "a", in: index)
        let rendQuery = AppSearchEngine.search(query: "rend", in: index)
        XCTAssertTrue(shortQuery.isEmpty)
        XCTAssertFalse(rendQuery.isEmpty)
    }
}
