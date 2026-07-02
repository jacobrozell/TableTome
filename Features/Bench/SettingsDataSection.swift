import SwiftUI
import SwiftData
import UniformTypeIdentifiers
import TabletomeHobbyData

/// Data import/export controls for Settings.
@MainActor
struct SettingsDataSection: View {
    @Environment(\.modelContext) private var context
    @Environment(BannerCenter.self) private var banner
    @Query private var paints: [HobbyPaint]

    @State private var importMode: DataActions.Mode = .replace
    @State private var importDomain: ImportDomain = .armies
    @State private var showCSVImporter = false
    @State private var showJSONImporter = false
    @State private var showExporter = false
    @State private var exportDoc = TextFileDocument(text: "")
    @State private var exportName = "export"
    @State private var exportType: UTType = .commaSeparatedText
    @State private var importOutcome: DataActions.ImportOutcome?
    @State private var alertError: (title: String, message: String)?
    @State private var confirmClear = false
    @State private var confirmRestore = false
    @State private var confirmPendingRestore = false
    @State private var confirmReplaceImport = false
    @State private var pendingImportURL: URL?
    @State private var pendingRestoreURL: URL?
    @State private var pendingRestorePreview: String?
    @State private var importSuccessTrigger = false
    @State private var importErrorTrigger = false

    enum ImportDomain: String, CaseIterable, Identifiable {
        case armies, paints

        var id: String { rawValue }

        var label: String {
            switch self {
            case .armies: String(localized: "Armies")
            case .paints: String(localized: "Paints")
            }
        }

        static var visibleCases: [ImportDomain] {
            var domains: [ImportDomain] = [.armies]
            if ReleaseSurface.showsPaintsInBench {
                domains.append(.paints)
            }
            return domains
        }
    }

    private var alertPresented: Binding<Bool> {
        Binding(
            get: { alertError != nil },
            set: { if !$0 { alertError = nil } }
        )
    }

    private var lastBackupAt: Date? {
        try? context.fetch(FetchDescriptor<AppConfiguration>()).first?.lastBackupAt
    }

    var body: some View {
        SettingsDataFormSections(
            lastBackupAt: lastBackupAt,
            showsPaintsInBench: ReleaseSurface.showsPaintsInBench,
            hasPaints: !paints.isEmpty,
            importDomain: $importDomain,
            importMode: $importMode,
            onChooseCSVFile: { showCSVImporter = true },
            onExportArmiesTemplate: exportArmiesTemplate,
            onExportPaintsTemplate: exportPaintsTemplate,
            onExportArmies: exportArmiesCSV,
            onExportPaints: exportPaintsCSV,
            onExportBackup: exportBackup,
            onRestore: { confirmRestore = true },
            onLoadSample: { presentOutcome(DataActions.loadSampleOutcome(ctx: context)) },
            onRemoveSample: { presentOutcome(DataActions.removeSampleOutcome(ctx: context)) },
            onClearAll: { confirmClear = true }
        )
        .fileImporter(isPresented: $showCSVImporter,
                      allowedContentTypes: [.commaSeparatedText, .plainText]) { handleCSV($0) }
        .fileImporter(isPresented: $showJSONImporter, allowedContentTypes: [.json]) { handleJSON($0) }
        .fileExporter(isPresented: $showExporter, document: exportDoc,
                      contentType: exportType, defaultFilename: exportName) { _ in }
        .sheet(item: $importOutcome, content: importResultsSheet)
        .alert(alertError?.title ?? String(localized: "Error"), isPresented: alertPresented) {
            Button(String(localized: "OK"), role: .cancel) {}
        } message: {
            if let alertError { Text(alertError.message) }
        }
        .confirmationDialog(String(localized: "Replace all data on this device?"),
                            isPresented: $confirmRestore, titleVisibility: .visible) {
            Button(String(localized: "Choose backup file")) { showJSONImporter = true }
        } message: {
            Text(String(localized: "Restoring a backup replaces armies, paints, and hobby settings."))
        }
        .confirmationDialog(String(localized: "Restore this backup?"),
                            isPresented: $confirmPendingRestore, titleVisibility: .visible) {
            Button(String(localized: "Restore"), role: .destructive) { runPendingRestore() }
            Button(String(localized: "Cancel"), role: .cancel) {
                pendingRestoreURL = nil
                pendingRestorePreview = nil
            }
        } message: {
            if let pendingRestorePreview {
                Text(
                    String(
                        localized: """
                        \(pendingRestorePreview). This replaces all data on this device.
                        """
                    )
                )
            }
        }
        .confirmationDialog(String(localized: "Delete all armies, paints, and settings?"),
                            isPresented: $confirmClear, titleVisibility: .visible) {
            Button(String(localized: "Clear all"), role: .destructive) { clearAllData() }
        }
        .confirmationDialog(String(localized: "Replace existing data?"),
                            isPresented: $confirmReplaceImport, titleVisibility: .visible) {
            Button(String(localized: "Replace")) { runPendingImport() }
            Button(String(localized: "Cancel"), role: .cancel) { pendingImportURL = nil }
        } message: {
            Text(replaceImportMessage)
        }
        .sensoryFeedback(.success, trigger: importSuccessTrigger)
        .sensoryFeedback(.error, trigger: importErrorTrigger)
    }

    private var replaceImportMessage: String {
        if importDomain == .armies {
            return String(localized: "Import (replace) will delete your current armies before importing.")
        }
        return String(localized: "Import (replace) will delete your current paints before importing.")
    }

    @ViewBuilder
    private func importResultsSheet(_ outcome: DataActions.ImportOutcome) -> some View {
        ImportResultsSheet(title: outcome.title, message: outcome.message,
                           warnings: outcome.warnings, failed: false)
            .presentationDetents([.medium, .large])
    }

    private func clearAllData() {
        CollectionStore.clearAll(in: context)
        WidgetUpdater.refresh(context: context)
        banner.show(String(localized: "All data cleared"))
    }

    private func handleCSV(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            if importMode == .replace {
                pendingImportURL = url
                confirmReplaceImport = true
            } else {
                presentOutcome(importFrom(url))
            }
        case .failure(let err):
            showFailure(title: String(localized: "Import failed"), message: err.localizedDescription)
        }
    }

    private func runPendingImport() {
        guard let url = pendingImportURL else { return }
        pendingImportURL = nil
        presentOutcome(importFrom(url))
    }

    private func importFrom(_ url: URL) -> DataActions.ImportOutcome {
        switch importDomain {
        case .armies: return DataActions.importArmiesOutcome(from: url, mode: importMode, ctx: context)
        case .paints:
            guard ReleaseSurface.showsPaintsInBench else {
                return .failure(
                    title: String(localized: "Import unavailable"),
                    message: String(localized: "Paints inventory is not available in this version.")
                )
            }
            return DataActions.importPaintsOutcome(from: url, mode: importMode, ctx: context)
        }
    }

    private func handleJSON(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            let preview = DataActions.previewBackup(from: url)
            if let error = preview.error {
                showFailure(title: error.title, message: error.message)
            } else if let backup = preview.backup {
                pendingRestoreURL = url
                pendingRestorePreview = backup.preview
                confirmPendingRestore = true
            }
        case .failure(let err):
            showFailure(title: String(localized: "Restore failed"), message: err.localizedDescription)
        }
    }

    private func runPendingRestore() {
        guard let url = pendingRestoreURL else { return }
        pendingRestoreURL = nil
        pendingRestorePreview = nil
        presentOutcome(DataActions.restoreBackupOutcome(from: url, ctx: context))
    }

    private func presentOutcome(_ outcome: DataActions.ImportOutcome) {
        if outcome.success {
            importSuccessTrigger.toggle()
            if outcome.warnings.isEmpty {
                banner.show(outcome.message)
            } else {
                importOutcome = outcome
            }
        } else {
            showFailure(title: outcome.title, message: outcome.message)
        }
    }

    private func showFailure(title: String, message: String) {
        importErrorTrigger.toggle()
        alertError = (title, message)
    }

    private func exportArmiesTemplate() {
        let out = DataActions.armiesTemplateCSV()
        exportDoc = TextFileDocument(text: out.text, contentType: .commaSeparatedText)
        exportName = out.filename; exportType = .commaSeparatedText; showExporter = true
    }

    private func exportPaintsTemplate() {
        let out = DataActions.paintsTemplateCSV()
        exportDoc = TextFileDocument(text: out.text, contentType: .commaSeparatedText)
        exportName = out.filename; exportType = .commaSeparatedText; showExporter = true
    }

    private func exportArmiesCSV() {
        let out = DataActions.armiesCSV(ctx: context)
        exportDoc = TextFileDocument(text: out.text, contentType: .commaSeparatedText)
        exportName = out.filename; exportType = .commaSeparatedText; showExporter = true
    }

    private func exportPaintsCSV() {
        let out = DataActions.paintsCSV(ctx: context)
        exportDoc = TextFileDocument(text: out.text, contentType: .commaSeparatedText)
        exportName = out.filename; exportType = .commaSeparatedText; showExporter = true
    }

    private func exportBackup() {
        let out = DataActions.backupJSON(ctx: context)
        exportDoc = TextFileDocument(text: out.text, contentType: .json)
        exportName = out.filename; exportType = .json; showExporter = true
        banner.show(String(localized: "Backup exported"))
    }
}
