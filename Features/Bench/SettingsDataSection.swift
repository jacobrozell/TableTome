import SwiftUI
import SwiftData
import UniformTypeIdentifiers
import TabletomeHobbyData

/// Data import/export controls for Settings.
@MainActor
struct SettingsDataSection: View {
    @Environment(\.modelContext) private var context
    @Environment(BannerCenter.self) private var banner

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
    @State private var confirmReplaceImport = false
    @State private var pendingImportURL: URL?
    @State private var importSuccessTrigger = false
    @State private var importErrorTrigger = false

    enum ImportDomain { case armies, paints }

    private var alertPresented: Binding<Bool> {
        Binding(
            get: { alertError != nil },
            set: { if !$0 { alertError = nil } }
        )
    }

    var body: some View {
        formSections
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

    @ViewBuilder
    private var formSections: some View {
        Section {
            Text(
                String(
                    localized: """
                    Back up or move your collection between devices. Replace clears existing data in that \
                    category first; append adds new rows and skips duplicates.
                    """
                )
            )
            .font(.callout)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)

            if let cfg = try? context.fetch(FetchDescriptor<AppConfiguration>()).first,
               let last = cfg.lastBackupAt {
                LabeledContent(String(localized: "Last backup")) {
                    Text(last, style: .date).foregroundStyle(.secondary)
                }
            }
        } header: {
            Text(String(localized: "Collection & Data"))
        }

        templateSection

        Section {
            Button { beginImport(.armies, .replace) } label: {
                Label(String(localized: "Import armies (replace)…"), systemImage: "square.and.arrow.down")
            }
            Button { beginImport(.armies, .append) } label: {
                Label(String(localized: "Import armies (append)…"), systemImage: "square.and.arrow.down.on.square")
            }
            Button { beginImport(.paints, .replace) } label: {
                Label(String(localized: "Import paints (replace)…"), systemImage: "square.and.arrow.down")
            }
            Button { beginImport(.paints, .append) } label: {
                Label(String(localized: "Import paints (append)…"), systemImage: "square.and.arrow.down.on.square")
            }
        } header: {
            Text(String(localized: "Import"))
        } footer: {
            Text(String(localized: "CSV files from Excel, Numbers, or Google Sheets. Use a template below if you're starting fresh."))
        }

        Section {
            Button { exportArmiesCSV() } label: {
                Label(String(localized: "Export armies CSV"), systemImage: "doc.text")
            }
            Button { exportPaintsCSV() } label: {
                Label(String(localized: "Export paints CSV"), systemImage: "doc.text")
            }
            Button { exportBackup() } label: {
                Label(String(localized: "Full backup (JSON)"), systemImage: "externaldrive")
            }
        } header: {
            Text(String(localized: "Export"))
        } footer: {
            Text(String(localized: "JSON backup includes armies, paints, pipeline settings, and list defaults."))
        }

        Section {
            Button { confirmRestore = true } label: {
                Label(String(localized: "Restore backup…"), systemImage: "arrow.counterclockwise")
            }
            Button { presentOutcome(DataActions.loadSampleOutcome(ctx: context)) } label: {
                Label(String(localized: "Load sample collection"), systemImage: "tray.and.arrow.down")
            }
            Button(role: .destructive) { confirmClear = true } label: {
                Label(String(localized: "Clear all data"), systemImage: "trash")
            }
        } header: {
            Text(String(localized: "Backup & sample"))
        } footer: {
            Text(String(localized: "Sample data is for exploring the Models tab — safe to delete anytime."))
        }
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

    private func beginImport(_ domain: ImportDomain, _ mode: DataActions.Mode) {
        importDomain = domain
        importMode = mode
        showCSVImporter = true
    }

    private func clearAllData() {
        CollectionStore.clearAll(in: context)
        WidgetUpdater.refresh(context: context)
        banner.show(String(localized: "All data cleared"))
    }

    private var templateSection: some View {
        Section {
            Button { exportArmiesTemplate() } label: {
                Label(String(localized: "Armies template"), systemImage: "doc.badge.plus")
            }
            Button { exportPaintsTemplate() } label: {
                Label(String(localized: "Paints template"), systemImage: "doc.badge.plus")
            }
        } header: {
            Text(String(localized: "CSV templates"))
        } footer: {
            Text(String(localized: "Download a starter CSV with the correct columns and an example row."))
        }
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
        case .paints: return DataActions.importPaintsOutcome(from: url, mode: importMode, ctx: context)
        }
    }

    private func handleJSON(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            presentOutcome(DataActions.restoreBackupOutcome(from: url, ctx: context))
        case .failure(let err):
            showFailure(title: String(localized: "Restore failed"), message: err.localizedDescription)
        }
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
