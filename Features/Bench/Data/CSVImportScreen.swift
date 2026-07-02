import SwiftUI
import TabletomeHobbyData

struct CSVImportScreen: View {
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
