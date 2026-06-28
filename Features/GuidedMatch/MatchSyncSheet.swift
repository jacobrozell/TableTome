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

    let onApplied: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                if syncService.isLiveSyncActive {
                    Section {
                        Label(
                            String(localized: "Live sync active"),
                            systemImage: "checkmark.circle.fill"
                        )
                        .foregroundStyle(.green)
                        .accessibilityIdentifier("matchSync.liveActive")
                    }
                }

                Section(String(localized: "Nearby sync")) {
                    Text(
                        String(
                            localized: """
                            Both players need Tabletome on the same Wi-Fi or Bluetooth range. \
                            One hosts, the other enters the 4-character code. Match setup and battle \
                            tracker sync automatically; match history stays on each device.
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
                        .onChange(of: joinCode) { _, newValue in
                            let filtered = newValue
                                .uppercased()
                                .filter { $0.isLetter || $0.isNumber }
                            joinCode = String(filtered.prefix(4))
                        }
                        .accessibilityIdentifier("matchSync.joinCodeField")

                    Button(String(localized: "Join match")) {
                        syncService.startJoining(code: joinCode)
                    }
                    .disabled(joinCode.count != 4)
                    .accessibilityIdentifier("matchSync.join")

                    if case .hosting(let code) = syncService.role {
                        LabeledContent(String(localized: "Your code"), value: code)
                            .font(.title2.monospaced().bold())
                    }

                    if let status = syncService.statusMessage {
                        Text(status)
                            .font(.caption)
                            .foregroundStyle(statusIsError ? .red : .secondary)
                            .accessibilityIdentifier("matchSync.status")
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
                            localized: """
                            Copy a match code from the other player and paste it here if nearby sync \
                            is unavailable. Both devices must be in the same Guided Match game mode.
                            """
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
                            onApplied()
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
        .onAppear {
            syncService.syncGameSystemId = gameSystemId
        }
        .onDisappear {
            copiedExport = false
        }
        .confirmationDialog(
            String(localized: "Allow this player to sync?"),
            isPresented: .init(
                get: { syncService.pendingJoinPeerName != nil },
                set: { if !$0 { syncService.declineJoinRequest() } }
            ),
            titleVisibility: .visible,
            presenting: syncService.pendingJoinPeerName
        ) { peerName in
            Button(String(localized: "Allow \(peerName)")) {
                syncService.acceptJoinRequest()
            }
            Button(String(localized: "Decline"), role: .cancel) {
                syncService.declineJoinRequest()
            }
        } message: { peerName in
            Text(
                String(
                    localized: """
                    \(peerName) is trying to join this match on the local network. Only allow players you trust at your table.
                    """
                )
            )
        }
    }

    private var statusIsError: Bool {
        guard let status = syncService.statusMessage else { return false }
        let lowered = status.lowercased()
        return lowered.contains("could not")
            || lowered.contains("failed")
            || lowered.contains("unreadable")
            || lowered.contains("different")
            || lowered.contains("needs a different version")
            || lowered.contains("check local network")
    }
}
