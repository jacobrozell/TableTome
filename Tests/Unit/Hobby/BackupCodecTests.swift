import XCTest
import SwiftData
@testable import Tabletome
@testable import TabletomeHobbyData
@testable import TabletomeDomain

@MainActor
final class BackupCodecTests: XCTestCase {
    private var context: ModelContext!

    override func setUp() async throws {
        try await super.setUp()
        context = HobbyAppContainer.unitTestContext()
        HobbyAppContainer.resetUnitTestStore()
    }

    func testExportRestoreRoundTripPreservesArmy() throws {
        XCTAssertTrue(ArmyStore.addArmy(name: "Ultramarines", game: "40k", faction: "Space Marines", in: context))

        let exported = BackupCodec.export(context)
        guard case .success(let backup) = BackupSanitizer.parse(exported) else {
            return XCTFail("Exported backup should parse")
        }

        BackupCodec.restore(backup, into: context)

        let armies = try context.fetch(FetchDescriptor<Army>())
        XCTAssertEqual(armies.count, 1)
        XCTAssertEqual(armies.first?.name, "Ultramarines")
        XCTAssertEqual(armies.first?.units.count, 0)
    }

    func testExportIncludesPaintAndSettings() throws {
        XCTAssertTrue(ArmyStore.addArmy(name: "Chapter", game: "40k", faction: "SM", in: context))
        let paint = HobbyPaint(name: "Macragge Blue", type: "Base", swatchHex: "#0000ff", qty: 1)
        context.insert(paint)
        try context.save()

        let exported = BackupCodec.export(context)

        XCTAssertTrue(exported.contains("Macragge Blue"))
        XCTAssertTrue(exported.contains("\"version\""))
        guard case .success(let backup) = BackupSanitizer.parse(exported) else {
            return XCTFail("Exported backup should parse")
        }
        XCTAssertEqual(backup.paints.count, 1)
        XCTAssertEqual(backup.paints.first?.name, "Macragge Blue")
    }

    func testExportRestorePreservesUnitsAndPerModelStates() throws {
        XCTAssertTrue(ArmyStore.addArmy(name: "Chapter", game: "40k", faction: "Space Marines", in: context))
        let army = try XCTUnwrap((try? context.fetch(FetchDescriptor<Army>()))?.first)
        XCTAssertTrue(
            ArmyStore.addUnit(
                to: army, name: "Intercessors (5)", qty: 1, source: "Starter", state: "Primed",
                trackPerModel: true,
                memberStates: ["Primed", "Detailed", "Primed", "Primed", "Primed"],
                in: context
            )
        )

        let exported = BackupCodec.export(context)
        guard case .success(let backup) = BackupSanitizer.parse(exported) else {
            return XCTFail("Exported backup should parse")
        }

        HobbyAppContainer.resetUnitTestStore()

        BackupCodec.restore(backup, into: context)

        let armies = try context.fetch(FetchDescriptor<Army>())
        XCTAssertEqual(armies.count, 1)
        let unit = try XCTUnwrap(armies.first?.units.first)
        XCTAssertEqual(unit.name, "Intercessors (5)")
        XCTAssertEqual(unit.source, "Starter")
        XCTAssertTrue(unit.hasSquadMembers)
        XCTAssertEqual(Members.effectiveState(of: unit, at: 1), "Detailed")
    }

    func testExportRestorePreservesFilterSettings() throws {
        let cfg = HobbyConfig.current(context)
        cfg.gameFilter = "40k"
        cfg.factionFilter = "Space Marines"
        cfg.quickViewRaw = "backlog"
        cfg.spearheadOnly = true
        try context.save()

        let exported = BackupCodec.export(context)
        guard case .success(let backup) = BackupSanitizer.parse(exported) else {
            return XCTFail("Exported backup should parse")
        }

        HobbyAppContainer.resetUnitTestStore()
        BackupCodec.restore(backup, into: context)

        let restored = HobbyConfig.current(context)
        XCTAssertEqual(restored.gameFilter, "40k")
        XCTAssertEqual(restored.factionFilter, "Space Marines")
        XCTAssertEqual(restored.quickViewRaw, "backlog")
        XCTAssertTrue(restored.spearheadOnly)
    }

    func testExportRestorePreservesSampleFlagsAndCollapsedArmies() throws {
        CollectionStore.insertSampleArmies([
            ArmyDraft(name: "Sample Army", game: "40k", faction: "SM", units: [])
        ], in: context)
        XCTAssertTrue(ArmyStore.addArmy(name: "My Chapter", game: "40k", faction: "SM", in: context))
        let chapter = try XCTUnwrap((try? context.fetch(FetchDescriptor<Army>()))?.first(where: { $0.name == "My Chapter" }))
        chapter.isCollapsed = true
        try context.save()

        let exported = BackupCodec.export(context)
        XCTAssertTrue(exported.contains("\"isSample\""))
        guard case .success(let backup) = BackupSanitizer.parse(exported) else {
            return XCTFail("Exported backup should parse")
        }
        XCTAssertTrue(backup.armies.contains { $0.name == "Sample Army" && $0.isSample })
        XCTAssertEqual(backup.settings.collapsedArmyNames, ["My Chapter"])

        HobbyAppContainer.resetUnitTestStore()
        BackupCodec.restore(backup, into: context)

        let armies = try context.fetch(FetchDescriptor<Army>())
        XCTAssertEqual(armies.count, 2)
        XCTAssertTrue(armies.contains { $0.name == "Sample Army" && $0.isSample })
        XCTAssertTrue(armies.first(where: { $0.name == "My Chapter" })?.isCollapsed == true)
    }

    func testExportRestorePreservesFactionCrestImageFileName() throws {
        let cfg = HobbyConfig.current(context)
        cfg.factionOverrides = [
            FactionPresetOverride(key: "40k\u{0}Space Marines", crest: "SM", hex: "#0072CE", imageFileName: "crest-sm.jpg")
        ]
        try context.save()

        let exported = BackupCodec.export(context)
        XCTAssertTrue(exported.contains("crest-sm.jpg"))
        guard case .success(let backup) = BackupSanitizer.parse(exported) else {
            return XCTFail("Exported backup should parse")
        }
        XCTAssertEqual(backup.settings.factionOverrides.first?.imageFileName, "crest-sm.jpg")

        HobbyAppContainer.resetUnitTestStore()
        BackupCodec.restore(backup, into: context)

        let restored = HobbyConfig.current(context)
        XCTAssertEqual(restored.factionOverrides.first?.imageFileName, "crest-sm.jpg")
    }
}
