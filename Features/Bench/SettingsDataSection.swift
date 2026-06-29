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

    @ViewBuilder
    private var formSections: some View {
        Section {
            if let cfg = try? context.fetch(FetchDescriptor<AppConfiguration>()).first,
               let last = cfg.lastBackupAt {
                LabeledContent(String(localized: "Last backup")) {
                    Text(last, style: .date).foregroundStyle(.secondary)
                }
            }

            NavigationLink {
                CSVImportScreen(
                    importDomain: $importDomain,
                    importMode: $importMode,
                    showsPaintsOptions: ReleaseSurface.showsPaintsInBench,
                    onChooseFile: { showCSVImporter = true },
                    onExportArmiesTemplate: exportArmiesTemplate,
                    onExportPaintsTemplate: exportPaintsTemplate
                )
            } label: {
                Label(String(localized: "Import CSV"), systemImage: "square.and.arrow.down")
            }

            NavigationLink {
                DataExportScreen(
                    showsPaintsExport: ReleaseSurface.showsPaintsInBench,
                    onExportArmies: exportArmiesCSV,
                    onExportPaints: exportPaintsCSV,
                    onExportBackup: exportBackup
                )
            } label: {
                Label(String(localized: "Export"), systemImage: "square.and.arrow.up")
            }

            NavigationLink {
                BackupToolsScreen(
                    onRestore: { confirmRestore = true },
                    onLoadSample: { presentOutcome(DataActions.loadSampleOutcome(ctx: context)) },
                    onRemoveSample: { presentOutcome(DataActions.removeSampleOutcome(ctx: context)) },
                    onClearAll: { confirmClear = true }
                )
            } label: {
                Label(String(localized: "Backup & restore"), systemImage: "externaldrive")
            }
        } header: {
            Text(String(localized: "Collection & Data"))
        } footer: {
            Text(
                String(
                    localized: """
                    Move your collection between devices. CSV for spreadsheets; JSON for a full backup \
                    including pipeline settings.
                    """
                )
            )
        }

        if !paints.isEmpty {
            Section {
                Button {
                    let count = PaintStore.refreshCatalogColors(in: context)
                    if count > 0 {
                        banner.show(String(localized: "\(count) paint colours updated"))
                    } else {
                        banner.show(String(localized: "All paint colours are up to date"))
                    }
                } label: {
                    Label(String(localized: "Refresh paint colours"), systemImage: "arrow.triangle.2.circlepath")
                }
            } header: {
                Text(String(localized: "Paints"))
            } footer: {
                Text(FormHints.paintRefreshCatalog)
            }
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

// MARK: - Import CSV

private struct CSVImportScreen: View {
    @Binding var importDomain: SettingsDataSection.ImportDomain
    @Binding var importMode: DataActions.Mode
    var showsPaintsOptions: Bool
    let onChooseFile: () -> Void
    let onExportArmiesTemplate: () -> Void
    let onExportPaintsTemplate: () -> Void

    var body: some View {
        Form {
            Section {
                Picker(String(localized: "Import"), selection: $importDomain) {
                    ForEach(SettingsDataSection.ImportDomain.visibleCases) { domain in
                        Text(domain.label).tag(domain)
                    }
                }
                .formNavigationPickerStyle()

                Picker(String(localized: "Mode"), selection: $importMode) {
                    Text(String(localized: "Replace existing")).tag(DataActions.Mode.replace)
                    Text(String(localized: "Add to collection")).tag(DataActions.Mode.append)
                }
                .formNavigationPickerStyle()
            } footer: {
                Text(importModeFooter)
            }

            Section {
                Button(action: onChooseFile) {
                    Label(String(localized: "Choose CSV file…"), systemImage: "doc.badge.plus")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            Section {
                Button(action: onExportArmiesTemplate) {
                    Label(String(localized: "Armies template"), systemImage: "doc")
                }
                if showsPaintsOptions {
                    Button(action: onExportPaintsTemplate) {
                        Label(String(localized: "Paints template"), systemImage: "doc")
                    }
                }
            } header: {
                Text(String(localized: "Templates"))
            } footer: {
                Text(
                    String(
                        localized: """
                        Starter CSVs with the correct columns and an example row — use in Excel, Numbers, \
                        or Google Sheets.
                        """
                    )
                )
            }
        }
        .navigationTitle(String(localized: "Import CSV"))
        .navigationBarTitleDisplayMode(.inline)
        .tabBarScrollInset()
        .onAppear {
            if !showsPaintsOptions, importDomain == .paints {
                importDomain = .armies
            }
        }
    }

    private var importModeFooter: String {
        switch (importDomain, importMode) {
        case (.armies, .replace):
            String(localized: "Deletes your current armies, then imports the file.")
        case (.armies, .append):
            String(localized: "Keeps existing armies and merges units into armies with the same name.")
        case (.paints, .replace):
            String(localized: "Deletes your current paints, then imports the file.")
        case (.paints, .append):
            String(localized: "Keeps existing paints and adds quantities for matching names.")
        }
    }
}

// MARK: - Export

private struct DataExportScreen: View {
    var showsPaintsExport: Bool
    let onExportArmies: () -> Void
    let onExportPaints: () -> Void
    let onExportBackup: () -> Void

    var body: some View {
        Form {
            Section {
                Button(action: onExportArmies) {
                    Label(String(localized: "Armies CSV"), systemImage: "doc.text")
                }
                if showsPaintsExport {
                    Button(action: onExportPaints) {
                        Label(String(localized: "Paints CSV"), systemImage: "doc.text")
                    }
                }
                Button(action: onExportBackup) {
                    Label(String(localized: "Full backup (JSON)"), systemImage: "externaldrive")
                }
            } footer: {
                Text(
                    String(
                        localized: showsPaintsExport
                            ? """
                            JSON backup includes armies, paints, pipeline settings, and list defaults. \
                            Custom crest image files stay on this device — re-upload after restore on a new iPad or iPhone.
                            """
                            : """
                            JSON backup includes armies, pipeline settings, and list defaults. \
                            Custom crest image files stay on this device — re-upload after restore on a new iPad or iPhone.
                            """
                    )
                )
            }
        }
        .navigationTitle(String(localized: "Export"))
        .navigationBarTitleDisplayMode(.inline)
        .tabBarScrollInset()
    }
}

// MARK: - Backup

private struct BackupToolsScreen: View {
    @Environment(\.modelContext) private var context
    let onRestore: () -> Void
    let onLoadSample: () -> Void
    let onRemoveSample: () -> Void
    let onClearAll: () -> Void

    private var hasSampleData: Bool {
        CollectionStore.hasSampleData(in: context)
    }

    var body: some View {
        Form {
            Section {
                Button(action: onLoadSample) {
                    Label(
                        hasSampleData
                            ? String(localized: "Reload sample collection")
                            : String(localized: "Load sample collection"),
                        systemImage: "tray.and.arrow.down"
                    )
                }
                .accessibilityIdentifier("backup.loadSample")
                Button(action: onRemoveSample) {
                    Label(String(localized: "Remove sample data"), systemImage: "tray.and.arrow.up")
                }
                .disabled(!hasSampleData)
                .accessibilityIdentifier("backup.removeSample")
            } footer: {
                Text(
                    String(
                        localized: """
                        Sample data is tagged separately from armies and paints you add or import. \
                        Removing it never deletes your own collection.
                        """
                    )
                )
            }

            Section {
                Button(action: onRestore) {
                    Label(String(localized: "Restore backup…"), systemImage: "arrow.counterclockwise")
                }
            } footer: {
                Text(String(localized: "Restoring a backup replaces all data on this device."))
            }

            Section {
                Button(role: .destructive, action: onClearAll) {
                    Label(String(localized: "Clear all data"), systemImage: "trash")
                }
            } footer: {
                Text(String(localized: "Removes all armies, paints, and hobby settings from this device."))
            }
        }
        .navigationTitle(String(localized: "Backup & restore"))
        .navigationBarTitleDisplayMode(.inline)
        .tabBarScrollInset()
    }
}
