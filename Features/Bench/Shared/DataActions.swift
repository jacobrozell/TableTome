import Foundation
import SwiftData
import TabletomeHobbyData
import TabletomeDomain

/// Bridges file URLs ↔ the DataIO layer for the screens' Import/Export menus.
/// Returns a user-facing summary message (shown in an alert). Confirmation dialogs and the
/// rich results sheet are specced in `docs/ios-spec/08-import-export.md`; this M5 wiring
/// keeps the UX minimal but functional.
@MainActor
enum DataActions {

    enum Mode { case replace, append }

    static func readText(at url: URL) throws -> String {
        let scoped = url.startAccessingSecurityScopedResource()
        defer { if scoped { url.stopAccessingSecurityScopedResource() } }
        let data = try Data(contentsOf: url)
        guard data.count <= HobbyLimits.maxImportBytes else {
            throw Failure(
                String(
                    localized: "File is too large (max \(HobbyLimits.maxImportBytes / (1024 * 1024)) MB)."
                )
            )
        }
        guard let text = String(data: data, encoding: .utf8) else {
            throw Failure(String(localized: "Could not read file as UTF-8 text."))
        }
        return text
    }

    struct Failure: LocalizedError { let msg: String; init(_ m: String) { msg = m }
        var errorDescription: String? { msg } }

    // MARK: CSV import

    static func importArmies(from url: URL, mode: Mode, ctx: ModelContext) -> String {
        do {
            if let hint = fileImportHint(url.lastPathComponent) { return hint }
            let text = try readText(at: url)
            let cfg = HobbyConfig.current(ctx)
            let result = ArmyCSV.import(CSV.parse(text),
                                        pipeline: Pipeline.resolve(cfg.globalPipeline),
                                        overrides: cfg.factionOverrides)
            guard result.ok, let armies = result.armies else {
                return String(
                    localized: "Import failed: \(result.errors.first ?? String(localized: "unknown error"))"
                )
            }
            switch mode {
            case .replace: CollectionStore.replaceArmies(armies, in: ctx)
            case .append:  CollectionStore.appendArmies(armies, in: ctx)
            }
            return summary(result, noun: "armies", warnings: result.warnings)
        } catch { return error.localizedDescription }
    }

    static func importPaints(from url: URL, mode: Mode, ctx: ModelContext) -> String {
        do {
            if let hint = fileImportHint(url.lastPathComponent) { return hint }
            let text = try readText(at: url)
            let result = PaintCSV.import(CSV.parse(text))
            guard result.ok, let paints = result.paints else {
                return String(
                    localized: "Import failed: \(result.errors.first ?? String(localized: "unknown error"))"
                )
            }
            switch mode {
            case .replace: CollectionStore.replacePaints(paints, in: ctx)
            case .append:  CollectionStore.appendPaints(paints, in: ctx)
            }
            return summary(result, noun: "paints", warnings: result.warnings)
        } catch { return error.localizedDescription }
    }

    private static func summary(_ r: ImportResult, noun: String, warnings: [String]) -> String {
        let n = noun == "paints" ? (r.stats["paints"] ?? 0) : (r.stats["units"] ?? 0)
        let unit = noun == "paints"
            ? String(localized: "paints")
            : String(localized: "unit entries")
        let warn = warnings.isEmpty
            ? ""
            : String(localized: " (\(warnings.count) warning\(warnings.count == 1 ? "" : "s"))")
        return String(localized: "Imported \(n) \(unit)\(warn).")
    }

    struct ImportOutcome: Identifiable, Sendable {
        let id: UUID
        let success: Bool
        let title: String
        let message: String
        let warnings: [String]

        static func failure(title: String, message: String) -> ImportOutcome {
            ImportOutcome(id: UUID(), success: false, title: title, message: message, warnings: [])
        }
    }

    static func importArmiesOutcome(from url: URL, mode: Mode, ctx: ModelContext) -> ImportOutcome {
        do {
            if let hint = fileImportHint(url.lastPathComponent) {
                return .failure(title: String(localized: "Import failed"), message: hint)
            }
            let text = try readText(at: url)
            let cfg = HobbyConfig.current(ctx)
            let result = ArmyCSV.import(CSV.parse(text),
                                        pipeline: Pipeline.resolve(cfg.globalPipeline),
                                        overrides: cfg.factionOverrides)
            guard result.ok, let armies = result.armies else {
                return .failure(
                    title: String(localized: "Import failed"),
                    message: result.errors.first ?? String(localized: "Unknown error")
                )
            }
            switch mode {
            case .replace: CollectionStore.replaceArmies(armies, in: ctx)
            case .append:  CollectionStore.appendArmies(armies, in: ctx)
            }
            WidgetUpdater.refresh(context: ctx)
            return ImportOutcome(
                id: UUID(),
                success: true,
                title: String(localized: "Armies imported"),
                message: summary(result, noun: "armies", warnings: result.warnings),
                warnings: result.warnings
            )
        } catch {
            return .failure(title: String(localized: "Import failed"), message: error.localizedDescription)
        }
    }

    static func restoreBackupOutcome(from url: URL, ctx: ModelContext) -> ImportOutcome {
        do {
            let text = try readText(at: url)
            switch BackupSanitizer.parse(text, byteLength: text.utf8.count) {
            case .failure(let err):
                return .failure(title: String(localized: "Restore failed"), message: err.message)
            case .success(let backup):
                BackupCodec.restore(backup, into: ctx)
                WidgetUpdater.refresh(context: ctx)
                return ImportOutcome(
                    id: UUID(),
                    success: true,
                    title: String(localized: "Restore complete"),
                    message: String(localized: "Backup restored: \(backup.preview)."),
                    warnings: []
                )
            }
        } catch {
            return .failure(title: String(localized: "Restore failed"), message: error.localizedDescription)
        }
    }

    static func loadSampleOutcome(ctx: ModelContext) -> ImportOutcome {
        do {
            let counts = try DemoLoader.load(into: ctx)
            WidgetUpdater.refresh(context: ctx)
            return ImportOutcome(id: UUID(), success: true, title: String(localized: "Sample loaded"),
                                 message: String(
                                    localized: "Sample loaded: \(counts.armies) armies, \(counts.paints) paints."
                                 ),
                                 warnings: [])
        } catch {
            return .failure(title: String(localized: "Sample failed"),
                            message: String(localized: "Could not load sample data (resources missing)."))
        }
    }

    static func importPaintsOutcome(from url: URL, mode: Mode, ctx: ModelContext) -> ImportOutcome {
        do {
            if let hint = fileImportHint(url.lastPathComponent) {
                return .failure(title: String(localized: "Import failed"), message: hint)
            }
            let text = try readText(at: url)
            let result = PaintCSV.import(CSV.parse(text))
            guard result.ok, let paints = result.paints else {
                return .failure(
                    title: String(localized: "Import failed"),
                    message: result.errors.first ?? String(localized: "Unknown error")
                )
            }
            switch mode {
            case .replace: CollectionStore.replacePaints(paints, in: ctx)
            case .append:  CollectionStore.appendPaints(paints, in: ctx)
            }
            WidgetUpdater.refresh(context: ctx)
            return ImportOutcome(
                id: UUID(),
                success: true,
                title: String(localized: "Paints imported"),
                message: summary(result, noun: "paints", warnings: result.warnings),
                warnings: result.warnings
            )
        } catch {
            return .failure(title: String(localized: "Import failed"), message: error.localizedDescription)
        }
    }

    // MARK: JSON backup

    static func restoreBackup(from url: URL, ctx: ModelContext) -> String {
        do {
            let text = try readText(at: url)
            switch BackupSanitizer.parse(text, byteLength: text.utf8.count) {
            case .failure(let err): return err.message
            case .success(let backup):
                BackupCodec.restore(backup, into: ctx)
                return String(localized: "Backup restored: \(backup.preview).")
            }
        } catch { return error.localizedDescription }
    }

    // MARK: Sample data

    static func loadSample(ctx: ModelContext) -> String {
        do {
            let counts = try DemoLoader.load(into: ctx)
            return String(
                localized: "Sample loaded: \(counts.armies) armies, \(counts.paints) paints."
            )
        } catch { return String(localized: "Could not load sample data (resources missing).") }
    }

    // MARK: Export builders

    static func armiesCSV(ctx: ModelContext) -> (text: String, filename: String) {
        let cfg = HobbyConfig.current(ctx)
        let armies = (try? ctx.fetch(FetchDescriptor<Army>())) ?? []
        let rows = ArmyCSV.exportRows(armies, overrides: cfg.factionOverrides)
        return (CSV.serialize(rows), "warhammer_armies_\(Date().fileStamp).csv")
    }

    static func paintsCSV(ctx: ModelContext) -> (text: String, filename: String) {
        let paints = (try? ctx.fetch(FetchDescriptor<HobbyPaint>())) ?? []
        return (CSV.serialize(PaintCSV.exportRows(paints)), "warhammer_paint_inventory_\(Date().fileStamp).csv")
    }

    static func backupJSON(ctx: ModelContext) -> (text: String, filename: String) {
        let json = BackupCodec.export(ctx)
        HobbyConfig.current(ctx).lastBackupAt = Date()
        try? ctx.save()
        return (json, "minimuster-backup-\(Date().fileStamp).json")
    }

    static func armiesTemplateCSV() -> (text: String, filename: String) {
        (CSVSchema.template(.armies), CSVSchema.filename(.armies))
    }

    static func paintsTemplateCSV() -> (text: String, filename: String) {
        (CSVSchema.template(.paints), CSVSchema.filename(.paints))
    }
}
