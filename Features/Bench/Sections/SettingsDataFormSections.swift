import SwiftUI
import SwiftData
import TabletomeHobbyData

struct SettingsDataFormSections: View {
    @Environment(\.modelContext) private var context
    @Environment(BannerCenter.self) private var banner

    let lastBackupAt: Date?
    let showsPaintsInBench: Bool
    let hasPaints: Bool

    @Binding var importDomain: SettingsDataSection.ImportDomain
    @Binding var importMode: DataActions.Mode

    let onChooseCSVFile: () -> Void
    let onExportArmiesTemplate: () -> Void
    let onExportPaintsTemplate: () -> Void
    let onExportArmies: () -> Void
    let onExportPaints: () -> Void
    let onExportBackup: () -> Void
    let onRestore: () -> Void
    let onLoadSample: () -> Void
    let onRemoveSample: () -> Void
    let onClearAll: () -> Void

    var body: some View {
        Section {
            if let lastBackupAt {
                LabeledContent(String(localized: "Last backup")) {
                    Text(lastBackupAt, style: .date).foregroundStyle(.secondary)
                }
            }

            NavigationLink {
                CSVImportScreen(
                    importDomain: $importDomain,
                    importMode: $importMode,
                    showsPaintsOptions: showsPaintsInBench,
                    onChooseFile: onChooseCSVFile,
                    onExportArmiesTemplate: onExportArmiesTemplate,
                    onExportPaintsTemplate: onExportPaintsTemplate
                )
            } label: {
                Label(String(localized: "Import CSV"), systemImage: "square.and.arrow.down")
            }

            NavigationLink {
                DataExportScreen(
                    showsPaintsExport: showsPaintsInBench,
                    onExportArmies: onExportArmies,
                    onExportPaints: onExportPaints,
                    onExportBackup: onExportBackup
                )
            } label: {
                Label(String(localized: "Export"), systemImage: "square.and.arrow.up")
            }

            NavigationLink {
                BackupToolsScreen(
                    onRestore: onRestore,
                    onLoadSample: onLoadSample,
                    onRemoveSample: onRemoveSample,
                    onClearAll: onClearAll
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

        if hasPaints {
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
}
