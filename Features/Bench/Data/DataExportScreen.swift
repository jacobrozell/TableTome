import SwiftUI

struct DataExportScreen: View {
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
