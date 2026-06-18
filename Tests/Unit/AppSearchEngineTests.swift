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

    func testWh40kIndexExcludesSpearheadOnlyTopics() async throws {
        let rulesRepository = BundledRulesRepository(bundle: Bundle(for: AppSearchEngineTests.self))
        let catalogRepository = BundledPlayCatalogRepository(bundle: Bundle(for: AppSearchEngineTests.self))
        let gameSystem = try await rulesRepository.gameSystem(id: "wh40k-11e")
        let catalog = try await catalogRepository.loadCatalog(for: "wh40k-11e")
        let wh40kIndex = AppSearchIndexBuilder.build(gameSystem: gameSystem, catalog: catalog)

        XCTAssertFalse(wh40kIndex.contains { $0.kind == .battleTactics })
        XCTAssertFalse(wh40kIndex.contains { $0.kind == .cardDeck })
        XCTAssertFalse(wh40kIndex.contains { $0.referenceId == "pile-in" })
        XCTAssertFalse(wh40kIndex.contains { $0.title.localizedCaseInsensitiveContains("twist card") })
    }

    func testStarCraftSuggestedTopicsExcludeSpearheadTerms() {
        let topics = AppSearchEngine.suggestedTopics(for: "sc-tmg")
        XCTAssertFalse(topics.contains { $0.localizedCaseInsensitiveContains("battle tactic") })
        XCTAssertFalse(topics.contains { $0.localizedCaseInsensitiveContains("twist card") })
        XCTAssertFalse(topics.contains { $0.localizedCaseInsensitiveContains("pile in") })
        XCTAssertFalse(topics.contains { $0.localizedCaseInsensitiveContains("warpfire") })
    }

    func testStarCraftIndexExcludesSpearheadOnlyTopics() async throws {
        let rulesRepository = BundledRulesRepository(bundle: Bundle(for: AppSearchEngineTests.self))
        let catalogRepository = BundledPlayCatalogRepository(bundle: Bundle(for: AppSearchEngineTests.self))
        let gameSystem = try await rulesRepository.gameSystem(id: "sc-tmg")
        let catalog = try await catalogRepository.loadCatalog(for: "sc-tmg")
        let starCraftIndex = AppSearchIndexBuilder.build(gameSystem: gameSystem, catalog: catalog)

        XCTAssertFalse(starCraftIndex.contains { $0.kind == .battleTactics })
        XCTAssertFalse(starCraftIndex.contains { $0.kind == .cardDeck })
        XCTAssertFalse(starCraftIndex.contains { $0.referenceId == "pile-in" })
        XCTAssertTrue(starCraftIndex.contains { $0.kind == .glossary && $0.referenceId == "glossary-surge" })
    }

    func testCombatPatrolIndexIncludesStratagemsAndUnitStats() async throws {
        let rulesRepository = BundledRulesRepository(bundle: Bundle(for: AppSearchEngineTests.self))
        let catalogRepository = BundledPlayCatalogRepository(bundle: Bundle(for: AppSearchEngineTests.self))
        let gameSystem = try await rulesRepository.gameSystem(id: "wh40k-10e-cp")
        let catalog = try await catalogRepository.loadCatalog(for: "wh40k-10e-cp")
        let cpIndex = AppSearchIndexBuilder.build(gameSystem: gameSystem, catalog: catalog)

        XCTAssertTrue(cpIndex.contains { $0.title == "Duty and Honour" && $0.subtitle.contains("Stratagem") })
        XCTAssertTrue(cpIndex.contains { $0.title == "Captain Octavius" && $0.kind == .warscroll })
        XCTAssertTrue(cpIndex.contains { $0.id == "mission:clash-of-patrols" })
    }
}
