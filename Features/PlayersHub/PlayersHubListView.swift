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
                .asyncContentShell()
            } else {
                List {
                    Section {
                        ForEach(viewModel.profiles) { profile in
                            NavigationLink(value: PlayerDetailLink(profileId: profile.id)) {
                                playerRow(profile)
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

                    if let primary = viewModel.household?.primaryProfile {
                        Section(String(localized: "This device")) {
                            Picker(String(localized: "Default player"), selection: Binding(
                                get: { primary.id },
                                set: { id in Task { await viewModel.setPrimaryProfile(id: id) } }
                            )) {
                                ForEach(viewModel.profiles) { profile in
                                    Text(profile.displayName).tag(profile.id)
                                }
                            }
                            .accessibilityIdentifier("playersHub.defaultPlayerPicker")
                        } footer: {
                            Text(String(localized: "The default player is pre-selected as Player 1 in Guided Match."))
                        }
                    }
                }
                .floatingCardListStyle()
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
        .alert(String(localized: "Add Player"), isPresented: $showsAddPlayer) {
            TextField(String(localized: "Name"), text: $newPlayerName)
            Button(String(localized: "Cancel"), role: .cancel) {}
            Button(String(localized: "Add")) {
                let name = newPlayerName.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !name.isEmpty else { return }
                Task { await viewModel.createProfile(name: name) }
            }
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

    private func playerRow(_ profile: PlayerProfile) -> some View {
        let stats = viewModel.stats(for: profile.id)
        return HStack(spacing: DesignTokens.Spacing.md) {
            PlayerAvatarView(name: profile.displayName, accentColorName: profile.accentColorName)
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                HStack(spacing: DesignTokens.Spacing.sm) {
                    Text(profile.displayName)
                        .font(.headline)
                    if viewModel.isPrimary(profile) {
                        Text(String(localized: "Me"))
                            .font(.caption2.weight(.semibold))
                            .padding(.horizontal, DesignTokens.Spacing.sm)
                            .padding(.vertical, 2)
                            .background(Color.accentColor.opacity(0.15), in: Capsule())
                    }
                }
                Text(
                    String(
                        localized: "\(profile.ownedSpearheadArmyIds.count) armies"
                    )
                )
                .font(.caption)
                .foregroundStyle(.secondary)
                if stats.gamesPlayed > 0 {
                    Text(statsSummary(stats, profile: profile))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, DesignTokens.Spacing.xs)
    }

    private func statsSummary(_ stats: PlayerMatchStats, profile: PlayerProfile) -> String {
        var parts = [stats.recordLabel]
        if let opponent = stats.lastOpponentName {
            parts.append(String(localized: "last: vs \(opponent)"))
        }
        return parts.joined(separator: " · ")
    }
}
