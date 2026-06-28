import XCTest
import SwiftData
@testable import Tabletome
@testable import TabletomeHobbyData
@testable import TabletomeDomain

@MainActor
final class CollectionStoreTests: XCTestCase {
    private var context: ModelContext!

    override func setUp() async throws {
        try await super.setUp()
        context = HobbyAppContainer.unitTestContext()
        HobbyAppContainer.resetUnitTestStore()
    }

    func testReplaceArmiesWipesExisting() throws {
        XCTAssertTrue(ArmyStore.addArmy(name: "Old", game: "40k", faction: "SM", in: context))
        let draft = ArmyDraft(name: "New", game: "40k", faction: "SM", units: [
            UnitDraft(name: "Captain", qty: 1, source: "Box", state: "Unassembled")
        ])

        CollectionStore.replaceArmies([draft], in: context)

        let armies = try context.fetch(FetchDescriptor<Army>())
        XCTAssertEqual(armies.count, 1)
        XCTAssertEqual(armies.first?.name, "New")
        XCTAssertEqual(armies.first?.units.count, 1)
    }

    func testAppendArmiesMergesUnitsIntoExistingArmyByName() throws {
        XCTAssertTrue(ArmyStore.addArmy(name: "Chapter", game: "40k", faction: "SM", in: context))
        let army = try XCTUnwrap((try? context.fetch(FetchDescriptor<Army>()))?.first)
        XCTAssertTrue(
            ArmyStore.addUnit(to: army, name: "Captain", qty: 1, source: "", state: "Unassembled", in: context)
        )

        let incoming = ArmyDraft(name: "Chapter", game: "40k", faction: "SM", units: [
            UnitDraft(name: "Intercessors (5)", qty: 1, source: "Box", state: "Primed")
        ])
        CollectionStore.appendArmies([incoming], in: context)

        let refreshed = try XCTUnwrap((try? context.fetch(FetchDescriptor<Army>()))?.first)
        XCTAssertEqual(refreshed.units.count, 2)
        XCTAssertTrue(refreshed.units.contains { $0.name == "Intercessors (5)" })
    }

    func testAppendArmiesInsertsNewArmyWhenNameDiffers() throws {
        XCTAssertTrue(ArmyStore.addArmy(name: "First", game: "40k", faction: "SM", in: context))
        let incoming = ArmyDraft(name: "Second", game: "AoS", faction: "Skaven", units: [
            UnitDraft(name: "Clanrats (10)", qty: 1, source: "", state: "Unassembled")
        ])

        CollectionStore.appendArmies([incoming], in: context)

        let armies = try context.fetch(FetchDescriptor<Army>())
        XCTAssertEqual(armies.count, 2)
        XCTAssertTrue(armies.contains { $0.name == "Second" })
    }

    func testAppendPaintsMergesQuantityByLowercasedName() throws {
        context.insert(HobbyPaint(name: "Macragge Blue", type: "Base", swatchHex: "#0000ff", qty: 1))
        try context.save()

        CollectionStore.appendPaints([
            PaintDraft(name: "macragge blue", type: "Base", swatchHex: "#0000ff", qty: 2, brand: "Citadel")
        ], in: context)

        let paints = try context.fetch(FetchDescriptor<HobbyPaint>())
        XCTAssertEqual(paints.count, 1)
        XCTAssertEqual(paints.first?.qty, 3)
    }

    func testReplacePaintsWipesExisting() throws {
        context.insert(HobbyPaint(name: "Old", type: "Base", swatchHex: "#000000", qty: 1))
        try context.save()

        CollectionStore.replacePaints([
            PaintDraft(name: "New", type: "Layer", swatchHex: "#ffffff", qty: 1, brand: "")
        ], in: context)

        let paints = try context.fetch(FetchDescriptor<HobbyPaint>())
        XCTAssertEqual(paints.count, 1)
        XCTAssertEqual(paints.first?.name, "New")
    }

    func testClearAllResetsConfiguration() throws {
        XCTAssertTrue(ArmyStore.addArmy(name: "Chapter", game: "40k", faction: "SM", in: context))
        let cfg = HobbyConfig.current(context)
        cfg.gameFilter = "40k"
        cfg.hasSeenCollectionIntro = true
        try context.save()

        CollectionStore.clearAll(in: context)

        let armies = try context.fetch(FetchDescriptor<Army>())
        let configs = try context.fetch(FetchDescriptor<AppConfiguration>())
        XCTAssertTrue(armies.isEmpty)
        XCTAssertEqual(configs.count, 1)
        XCTAssertEqual(configs.first?.gameFilter, "All")
        XCTAssertFalse(configs.first?.hasSeenCollectionIntro ?? true)
    }
}
