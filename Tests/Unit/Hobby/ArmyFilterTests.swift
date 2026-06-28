import XCTest
import SwiftData
@testable import Tabletome
@testable import TabletomeHobbyData
@testable import TabletomeDomain

@MainActor
final class ArmyFilterTests: XCTestCase {
    private var context: ModelContext!

    override func setUp() async throws {
        try await super.setUp()
        context = HobbyAppContainer.unitTestContext()
        HobbyAppContainer.resetUnitTestStore()
    }

    func testUsesBeginnerFilterLayoutWhenCollectionIsSmall() throws {
        XCTAssertTrue(ArmyFilter.usesBeginnerFilterLayout(armies: []))

        XCTAssertTrue(ArmyStore.addArmy(name: "First", game: "40k", faction: "SM", in: context))
        let one = try XCTUnwrap((try? context.fetch(FetchDescriptor<Army>()))?.first)
        XCTAssertTrue(ArmyFilter.usesBeginnerFilterLayout(armies: [one]))

        XCTAssertTrue(ArmyStore.addArmy(name: "Second", game: "40k", faction: "SM", in: context))
        let armies = try XCTUnwrap(try? context.fetch(FetchDescriptor<Army>()))
        XCTAssertTrue(ArmyFilter.usesBeginnerFilterLayout(armies: armies))
    }

    func testBeginnerLayoutEndsWhenSourcesExist() throws {
        XCTAssertTrue(ArmyStore.addArmy(name: "Army", game: "40k", faction: "SM", in: context))
        let army = try XCTUnwrap((try? context.fetch(FetchDescriptor<Army>()))?.first)
        XCTAssertTrue(
            ArmyStore.addUnit(to: army, name: "Captain", qty: 1, source: "Combat Patrol", state: "Unassembled", in: context)
        )

        XCTAssertFalse(ArmyFilter.usesBeginnerFilterLayout(armies: [army]))
    }

    func testQuickViewBacklogFiltersUnassembledUnits() throws {
        XCTAssertTrue(ArmyStore.addArmy(name: "Army", game: "40k", faction: "SM", in: context))
        let army = try XCTUnwrap((try? context.fetch(FetchDescriptor<Army>()))?.first)
        XCTAssertTrue(ArmyStore.addUnit(to: army, name: "Captain", qty: 1, source: "", state: "Unassembled", in: context))
        XCTAssertTrue(ArmyStore.addUnit(to: army, name: "Sergeant", qty: 1, source: "", state: "Done", in: context))

        let cfg = AppConfiguration()
        cfg.quickViewRaw = "backlog"
        context.insert(cfg)

        let visible = ArmyFilter.build(armies: [army], cfg: cfg, search: "", global: nil)
        XCTAssertEqual(visible.count, 1)
        XCTAssertEqual(visible.first?.units.count, 1)
        XCTAssertEqual(visible.first?.units.first?.name, "Captain")
    }

    func testActiveFilterCountIncludesQuickView() {
        let cfg = AppConfiguration()
        XCTAssertEqual(ArmyFilter.activeFilterCount(cfg), 0)

        cfg.quickViewRaw = "wip"
        XCTAssertEqual(ArmyFilter.activeFilterCount(cfg), 1)

        cfg.gameFilter = "40k"
        XCTAssertEqual(ArmyFilter.activeFilterCount(cfg), 2)
    }

    func testClearFiltersResetsQuickView() {
        let cfg = AppConfiguration()
        cfg.quickViewRaw = "backlog"
        cfg.gameFilter = "40k"
        cfg.spearheadOnly = true

        ArmyFilter.clearFilters(cfg)

        XCTAssertEqual(cfg.quickViewRaw, "all")
        XCTAssertEqual(cfg.gameFilter, "All")
        XCTAssertFalse(cfg.spearheadOnly)
    }
}
