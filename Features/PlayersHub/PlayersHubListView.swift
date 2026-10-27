import SwiftUI
import TabletomeDomain

struct PlayersHubListView: View {
    @StateObject private var viewModel: PlayersHubListViewModel
    @State private var showsAddPlayer = false
    @State private var newPlayerName = ""
    @State private var deleteBlockedMessage: String?

    init(viewModel: PlayersHubListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Group {
            if viewModel.isLoading, viewModel.household == nil {
                ProgressView(String(localized: "Loading players…"))
                    .asyncContentShell()
            } else if let error = viewModel.errorMessage, viewModel.household == nil {
                EmptyStateView(
                    title: String(localized: "Unable to Load"),
                    message: error,
                    systemImage: "exclamationmark.triangle",
                    actionTitle: String(localized: "Retry"),
                    action: { Task { await viewModel.load() } }
                )
                .adaptiveEmptyStateLayout()
                .asyncContentShell()
            } else {
                List {
                    Section {
                        ForEach(viewModel.profiles) { profile in
                            NavigationLink(value: PlayerDetailLink(profileId: profile.id)) {
                                PlayerSummaryRow(
                                    profile: profile,
                                    isPrimary: viewModel.isPrimary(profile),
                                    stats: viewModel.stats(for: profile.id),
                                    showsChevron: false
                                )
                            }
                            .accessibilityIdentifier("playersHub.row.\(profile.id.uuidString)")
                        }
                        .onDelete { indexSet in
                            Task {
                                for index in indexSet {
                                    let profile = viewModel.profiles[index]
                                    if !(await viewModel.deleteProfile(id: profile.id)) {
                                        deleteBlockedMessage = viewModel.errorMessage
                                    }
                                }
                            }
                        }
                    } footer: {
                        Text(
                            String(
                                localized: """
                                Profiles stay on this device. Match history links when you pick a player in Guided Match.
                                """
                            )
                        )
                    }

                    if let defaultProfileId = viewModel.household?.defaultPlayerOneProfileId {
                        Section {
                            Picker(String(localized: "Default player"), selection: Binding(
                                get: { defaultProfileId },
                                set: { id in Task { await viewModel.setPrimaryProfile(id: id) } }
                            )) {
                                ForEach(viewModel.profiles) { profile in
                                    Text(profile.displayName).tag(profile.id)
                                }
                            }
                            .accessibilityIdentifier("playersHub.defaultPlayerPicker")
                        } header: {
                            Text(String(localized: "This device"))
                        } footer: {
                            Text(String(localized: "The default player is pre-selected as Player 1 in Guided Match."))
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .tabBarScrollInset()
            }
        }
        .navigationTitle(String(localized: "Players"))
        .accessibilityIdentifier("playersHub.screen")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    newPlayerName = ""
                    showsAddPlayer = true
                } label: {
                    Label(String(localized: "Add Player"), systemImage: "person.badge.plus")
                }
                .accessibilityIdentifier("playersHub.addPlayer")
            }
        }
        .sheet(isPresented: $showsAddPlayer) {
            AddPlayerSheet(
                name: $newPlayerName,
                onCancel: { showsAddPlayer = false },
                onAdd: { name in
                    showsAddPlayer = false
                    Task { await viewModel.createProfile(name: name) }
                }
            )
        }
        .alert(String(localized: "Cannot Delete"), isPresented: Binding(
            get: { deleteBlockedMessage != nil },
            set: { if !$0 { deleteBlockedMessage = nil } }
        )) {
            Button(String(localized: "OK"), role: .cancel) {}
        } message: {
            Text(deleteBlockedMessage ?? "")
        }
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
    }
}
