import XCTest
import SwiftData
@testable import Tabletome
@testable import TabletomeHobbyData
@testable import TabletomeDomain

@MainActor
final class DataActionsImportExportTests: XCTestCase {
    private var context: ModelContext!

    override func setUp() async throws {
        try await super.setUp()
        context = HobbyAppContainer.unitTestContext()
        HobbyAppContainer.resetUnitTestStore()
    }

    // MARK: - CSV armies

    func testArmiesCSVExportImportRoundTrip() throws {
        XCTAssertTrue(ArmyStore.addArmy(name: "My Chapter", game: "40k", faction: "Space Marines", in: context))
        let army = try XCTUnwrap((try? context.fetch(FetchDescriptor<Army>()))?.first)
        XCTAssertTrue(
            ArmyStore.addUnit(
                to: army, name: "Intercessors (5)", qty: 1, source: "Combat Patrol",
                state: "Primed", in: context
            )
        )

        let exported = DataActions.armiesCSV(ctx: context)
        XCTAssertFalse(exported.text.isEmpty)
        XCTAssertTrue(exported.filename.hasSuffix(".csv"))
        XCTAssertTrue(exported.text.contains("My Chapter"))
        XCTAssertTrue(exported.text.contains("Intercessors (5)"))

        CollectionStore.clearAll(in: context)
        XCTAssertTrue((try? context.fetch(FetchDescriptor<Army>()))?.isEmpty == true)

        let url = try writeTempFile(exported.text, name: "armies-roundtrip.csv")
        let outcome = DataActions.importArmiesOutcome(from: url, mode: .replace, ctx: context)

        XCTAssertTrue(outcome.success, outcome.message)
        let armies = try context.fetch(FetchDescriptor<Army>())
        XCTAssertEqual(armies.count, 1)
        XCTAssertEqual(armies.first?.name, "My Chapter")
        XCTAssertEqual(armies.first?.units.count, 1)
        XCTAssertEqual(armies.first?.units.first?.name, "Intercessors (5)")
        XCTAssertEqual(armies.first?.units.first?.state, "Primed")
        XCTAssertEqual(armies.first?.units.first?.source, "Combat Patrol")
    }

    func testArmiesCSVAppendAddsUnitsToExistingArmy() throws {
        XCTAssertTrue(ArmyStore.addArmy(name: "Chapter", game: "40k", faction: "SM", in: context))
        let csv = """
        Game,Faction,Army,Unit,Qty,Source,State
        40k,Space Marines,Chapter,Captain,1,Box,Unassembled
        """
        let url = try writeTempFile(csv, name: "append.csv")
        let outcome = DataActions.importArmiesOutcome(from: url, mode: .append, ctx: context)

        XCTAssertTrue(outcome.success, outcome.message)
        let army = try XCTUnwrap((try? context.fetch(FetchDescriptor<Army>()))?.first)
        XCTAssertEqual(army.units.count, 1)
        XCTAssertEqual(army.units.first?.name, "Captain")
    }

    func testArmiesImportRejectsExcelFilename() {
        let url = URL(fileURLWithPath: "/tmp/sample.xlsx")
        let outcome = DataActions.importArmiesOutcome(from: url, mode: .replace, ctx: context)

        XCTAssertFalse(outcome.success)
        XCTAssertTrue(outcome.message.contains("Excel"))
    }

    func testLoadSampleOutcomeReportsInsertedCounts() {
        let outcome = DataActions.loadSampleOutcome(ctx: context)
        XCTAssertTrue(outcome.success, outcome.message)
        XCTAssertTrue(outcome.message.contains("Added"))
        XCTAssertTrue(CollectionStore.hasSampleData(in: context))
    }

    func testRemoveSampleOutcomeFailsWhenEmpty() {
        let outcome = DataActions.removeSampleOutcome(ctx: context)
        XCTAssertFalse(outcome.success)
        XCTAssertEqual(outcome.title, String(localized: "Nothing to remove"))
    }

    func testRemoveSampleOutcomeAfterLoad() {
        _ = DataActions.loadSampleOutcome(ctx: context)
        let outcome = DataActions.removeSampleOutcome(ctx: context)
        XCTAssertTrue(outcome.success, outcome.message)
        XCTAssertFalse(CollectionStore.hasSampleData(in: context))
    }

    func testArmiesTemplateImportsSuccessfully() throws {
        let template = DataActions.armiesTemplateCSV()
        XCTAssertEqual(template.filename, "warhammer_armies.csv")

        let url = try writeTempFile(template.text, name: template.filename)
        let outcome = DataActions.importArmiesOutcome(from: url, mode: .replace, ctx: context)

        XCTAssertTrue(outcome.success, outcome.message)
        let armies = try context.fetch(FetchDescriptor<Army>())
        XCTAssertEqual(armies.count, 1)
        XCTAssertEqual(armies.first?.name, "My Chapter")
        XCTAssertEqual(armies.first?.units.first?.name, "Intercessors (5)")
    }

    func testCSVWithBOMImports() throws {
        let csv = "\u{FEFF}Game,Faction,Army,Unit,Qty,Source,State\n40k,SM,Chapter,Captain,1,,Unassembled\n"
        let url = try writeTempFile(csv, name: "bom.csv")
        let outcome = DataActions.importArmiesOutcome(from: url, mode: .replace, ctx: context)

        XCTAssertTrue(outcome.success, outcome.message)
        XCTAssertEqual(try context.fetch(FetchDescriptor<Army>()).count, 1)
    }

    // MARK: - CSV paints

    func testPaintsCSVExportImportRoundTrip() throws {
        context.insert(HobbyPaint(name: "Macragge Blue", type: "Base", swatchHex: "#1c4fa0", qty: 2, brand: "Citadel"))
        try context.save()

        let exported = DataActions.paintsCSV(ctx: context)
        XCTAssertTrue(exported.text.contains("Macragge Blue"))

        CollectionStore.replacePaints([], in: context)
        XCTAssertTrue((try? context.fetch(FetchDescriptor<HobbyPaint>()))?.isEmpty == true)

        let url = try writeTempFile(exported.text, name: "paints-roundtrip.csv")
        let outcome = DataActions.importPaintsOutcome(from: url, mode: .replace, ctx: context)

        XCTAssertTrue(outcome.success, outcome.message)
        let paints = try context.fetch(FetchDescriptor<HobbyPaint>())
        XCTAssertEqual(paints.count, 1)
        XCTAssertEqual(paints.first?.name, "Macragge Blue")
        XCTAssertEqual(paints.first?.qty, 2)
    }

    func testPaintsAppendMergesDuplicateNames() throws {
        context.insert(HobbyPaint(name: "Macragge Blue", type: "Base", swatchHex: "#1c4fa0", qty: 1))
        try context.save()

        let csv = "Name,Type,Brand,Source,Quantity,Notes\nmacragge blue,Base,Citadel,,2,\n"
        let url = try writeTempFile(csv, name: "paints-append.csv")
        let outcome = DataActions.importPaintsOutcome(from: url, mode: .append, ctx: context)

        XCTAssertTrue(outcome.success, outcome.message)
        let paints = try context.fetch(FetchDescriptor<HobbyPaint>())
        XCTAssertEqual(paints.count, 1)
        XCTAssertEqual(paints.first?.qty, 3)
    }

    func testPaintsTemplateImportsSuccessfully() throws {
        let template = DataActions.paintsTemplateCSV()
        let url = try writeTempFile(template.text, name: template.filename)
        let outcome = DataActions.importPaintsOutcome(from: url, mode: .replace, ctx: context)

        XCTAssertTrue(outcome.success, outcome.message)
        let paints = try context.fetch(FetchDescriptor<HobbyPaint>())
        XCTAssertEqual(paints.count, 1)
        XCTAssertEqual(paints.first?.name, "Macragge Blue")
    }

    // MARK: - JSON backup

    func testBackupJSONExportRestoreRoundTrip() throws {
        XCTAssertTrue(ArmyStore.addArmy(name: "Ultramarines", game: "40k", faction: "Space Marines", in: context))
        let army = try XCTUnwrap((try? context.fetch(FetchDescriptor<Army>()))?.first)
        XCTAssertTrue(
            ArmyStore.addUnit(
                to: army, name: "Intercessors (5)", qty: 1, source: "Box", state: "Unassembled",
                trackPerModel: true,
                memberStates: ["Unassembled", "Primed", "Primed", "Primed", "Primed"],
                in: context
            )
        )
        context.insert(HobbyPaint(name: "Macragge Blue", type: "Base", swatchHex: "#1c4fa0", qty: 1))
        let cfg = HobbyConfig.current(context)
        cfg.gameFilter = "40k"
        cfg.quickViewRaw = "wip"
        cfg.globalPipeline = DefaultPipeline.stages
        try context.save()

        let exported = DataActions.backupJSON(ctx: context)
        XCTAssertTrue(exported.filename.hasPrefix("tabletome-backup-"))
        XCTAssertTrue(exported.text.contains("Ultramarines"))
        XCTAssertTrue(exported.text.contains("Intercessors (5)"))

        CollectionStore.clearAll(in: context)
        XCTAssertTrue((try? context.fetch(FetchDescriptor<Army>()))?.isEmpty == true)

        let url = try writeTempFile(exported.text, name: "backup.json")
        let outcome = DataActions.restoreBackupOutcome(from: url, ctx: context)

        XCTAssertTrue(outcome.success, outcome.message)
        let armies = try context.fetch(FetchDescriptor<Army>())
        XCTAssertEqual(armies.count, 1)
        let unit = try XCTUnwrap(armies.first?.units.first)
        XCTAssertEqual(unit.name, "Intercessors (5)")
        XCTAssertTrue(unit.hasSquadMembers)
        XCTAssertEqual(unit.squadMembers.count, 5)

        let paints = try context.fetch(FetchDescriptor<HobbyPaint>())
        XCTAssertEqual(paints.count, 1)

        let restoredCfg = try XCTUnwrap((try? context.fetch(FetchDescriptor<AppConfiguration>()))?.first)
        XCTAssertEqual(restoredCfg.gameFilter, "40k")
        XCTAssertEqual(restoredCfg.quickViewRaw, "wip")
        XCTAssertNotNil(restoredCfg.lastBackupAt)
    }

    func testBackupISO8601RoundTripsFractionalSeconds() {
        let date = Date(timeIntervalSince1970: 1_718_000_000.456)
        let encoded = BackupISO8601.string(from: date)
        XCTAssertEqual(BackupISO8601.date(from: encoded), date)
    }

    func testBackupRestoreReplacesExistingCollection() throws {
        XCTAssertTrue(ArmyStore.addArmy(name: "Old Army", game: "40k", faction: "SM", in: context))

        let backupArmy = ArmyDraft(name: "Restored", game: "AoS", faction: "Skaven", units: [
            UnitDraft(name: "Clanrats (10)", qty: 1, source: "", state: "Done")
        ])
        let sanitized = try XCTUnwrap(sanitizeBackup(armies: [backupArmy]))
        BackupCodec.restore(sanitized, into: context)

        let armies = try context.fetch(FetchDescriptor<Army>())
        XCTAssertEqual(armies.count, 1)
        XCTAssertEqual(armies.first?.name, "Restored")
        XCTAssertEqual(armies.first?.game, "AoS")
    }

    func testExportRowsRoundTripPreservesSquadMembers() throws {
        XCTAssertTrue(ArmyStore.addArmy(name: "Chapter", game: "40k", faction: "SM", in: context))
        let army = try XCTUnwrap((try? context.fetch(FetchDescriptor<Army>()))?.first)
        XCTAssertTrue(
            ArmyStore.addUnit(
                to: army, name: "Intercessors (5)", qty: 1, source: "", state: "Primed",
                trackPerModel: true,
                memberStates: ["Primed", "Base Coated", "Primed", "Primed", "Primed"],
                in: context
            )
        )

        let cfg = HobbyConfig.current(context)
        let rows = ArmyCSV.exportRows([army], overrides: cfg.factionOverrides)
        let csv = CSV.serialize(rows)
        let url = try writeTempFile(csv, name: "members.csv")

        CollectionStore.clearAll(in: context)
        let outcome = DataActions.importArmiesOutcome(from: url, mode: .replace, ctx: context)
        XCTAssertTrue(outcome.success, outcome.message)

        let imported = try XCTUnwrap((try? context.fetch(FetchDescriptor<Army>()))?.first?.units.first)
        XCTAssertEqual(imported.name, "Intercessors (5)")
        XCTAssertTrue(imported.hasSquadMembers)
        XCTAssertEqual(imported.squadMembers.count, 5)
        XCTAssertEqual(Members.effectiveState(of: imported, at: 1), "Base Coated")
    }

    // MARK: - Helpers

    private func writeTempFile(_ text: String, name: String) throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(UUID().uuidString)-\(name)")
        try text.write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    private func sanitizeBackup(armies: [ArmyDraft]) -> SanitizedBackup? {
        let collection = armies.map { draft in
            ArmyDTO(
                army: draft.name,
                game: draft.game,
                faction: draft.faction,
                units: draft.units.map { unit in
                    UnitDTO(
                        unit: unit.name,
                        qty: unit.qty,
                        source: unit.source,
                        state: unit.state,
                        spearhead: unit.spearhead,
                        notes: unit.notes,
                        members: unit.members.isEmpty
                            ? nil
                            : unit.members.map { MemberDTO(state: $0.state, notes: $0.notes) }
                    )
                }
            )
        }
        let snapshot = Snapshot(
            version: Snapshot.backupVersion,
            collection: collection,
            paints: [],
            settings: SettingsDTO(theme: "system"),
            exportedAt: nil
        )
        guard case .success(let backup) = BackupSanitizer.sanitize(snapshot) else { return nil }
        return backup
    }
}
