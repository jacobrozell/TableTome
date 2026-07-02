import SwiftUI
import SwiftData
import TabletomeHobbyData

struct BackupToolsScreen: View {
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
