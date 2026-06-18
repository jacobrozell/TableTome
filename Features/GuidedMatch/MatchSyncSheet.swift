import SwiftUI
import TabletomeDomain
import TabletomeData

struct MatchSyncSheet: View {
    @ObservedObject var syncService: NearbyMatchSyncService
    let gameSystemId: String
    @Environment(\.dismiss) private var dismiss

    @State private var joinCode = ""
    @State private var pasteCode = ""
    @State private var copiedExport = false
    @State private var importMessage: String?

    let onApplied: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section(String(localized: "Nearby sync")) {
                    Text(
                        String(
                            localized: """
                            Both players need Tabletome on the same Wi-Fi or Bluetooth range. \
                            One hosts, the other enters the 4-character code.
                            """
                        )
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)

                    Button(String(localized: "Host match")) {
                        syncService.startHosting()
                    }
                    .accessibilityIdentifier("matchSync.host")

                    TextField(String(localized: "Join code"), text: $joinCode)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                        .accessibilityIdentifier("matchSync.joinCodeField")

                    Button(String(localized: "Join match")) {
                        syncService.startJoining(code: joinCode)
                    }
                    .accessibilityIdentifier("matchSync.join")

                    if case .hosting(let code) = syncService.role {
                        LabeledContent(String(localized: "Your code"), value: code)
                            .font(.title2.monospaced().bold())
                    }

                    if let status = syncService.statusMessage {
                        Text(status)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    if syncService.role != .idle {
                        Button(String(localized: "Stop syncing"), role: .destructive) {
                            syncService.stop()
                        }
                        .accessibilityIdentifier("matchSync.stop")
                    }
                }

                Section(String(localized: "Paste code")) {
                    Text(
                        String(
                            localized: "Copy a match code from the other player and paste it here if nearby sync is unavailable."
                        )
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)

                    TextField(String(localized: "Paste match code"), text: $pasteCode, axis: .vertical)
                        .lineLimit(3...6)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .accessibilityIdentifier("matchSync.pasteField")

                    Button(String(localized: "Import pasted code")) {
                        if syncService.applyPasteCode(pasteCode) {
                            importMessage = String(localized: "Match imported.")
                            onApplied()
                        } else {
                            importMessage = String(localized: "Could not read that code.")
                        }
                    }
                    .accessibilityIdentifier("matchSync.importPaste")

                    if let export = syncService.exportPasteCode {
                        Button(copiedExport ? String(localized: "Copied!") : String(localized: "Copy match code")) {
                            UIPasteboard.general.string = export
                            copiedExport = true
                        }
                        .accessibilityIdentifier("matchSync.copyExport")
                    }

                    if let importMessage {
                        Text(importMessage)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle(String(localized: "Sync Match"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(String(localized: "Done")) { dismiss() }
                        .accessibilityIdentifier("matchSync.done")
                }
            }
        }
        .accessibilityIdentifier("matchSync.sheet")
        .onAppear { syncService.syncGameSystemId = gameSystemId }
    }
}
