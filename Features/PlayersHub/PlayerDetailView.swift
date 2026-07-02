import SwiftUI
import TabletomeDomain

struct PlayerDetailView: View {
    @StateObject private var viewModel: PlayerDetailViewModel
    @Environment(AppRouter.self) private var router
    @State private var editingName: String = ""

    init(viewModel: PlayerDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _editingName = State(initialValue: "")
    }

    var body: some View {
        Group {
            if viewModel.isLoading, viewModel.profile == nil {
                ProgressView(String(localized: "Loading player…"))
                    .asyncContentShell()
            } else if let profile = viewModel.profile {
                Form {
                    Section {
                        HStack(spacing: DesignTokens.Spacing.md) {
                            PlayerAvatarView(
                                name: profile.displayName,
                                accentColorName: profile.accentColorName,
                                size: 56
                            )
                            TextField(String(localized: "Display name"), text: $editingName)
                                .textInputAutocapitalization(.words)
                                .onSubmit {
                                    Task { await viewModel.updateDisplayName(editingName) }
                                }
                        }
                    }

                    Section {
                        Toggle(
                            String(localized: "This is me"),
                            isOn: Binding(
                                get: { viewModel.isPrimaryPlayer() },
                                set: { isOn in
                                    if isOn { Task { await viewModel.setPrimary() } }
                                }
                            )
                        )
                        .accessibilityIdentifier("playersHub.primaryToggle")
                    } footer: {
                        Text(
                            String(
                                localized: """
                                Marks this player as the phone owner. They are pre-selected as Player 1 in Guided Match.
                                """
                            )
                        )
                    }

                    Section(String(localized: "Accent color")) {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: DesignTokens.Spacing.sm) {
                            ForEach(PlayerAccentPalette.options, id: \.name) { option in
                                Button {
                                    Task { await viewModel.setAccentColor(option.name) }
                                } label: {
                                    Circle()
                                        .fill(option.color)
                                        .frame(width: 36, height: 36)
                                        .overlay {
                                            if profile.accentColorName == option.name {
                                                Image(systemName: "checkmark")
                                                    .font(.caption.weight(.bold))
                                                    .foregroundStyle(.white)
                                            }
                                        }
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel(option.name)
                            }
                        }
                        .padding(.vertical, DesignTokens.Spacing.xs)
                    }

                    OwnedSpearheadArmiesSection(
                        viewModel: viewModel,
                        gameSystemId: GameSystemId.aosSpearhead.rawValue
                    )

                    PlayerMatchHistorySection(
                        profile: profile,
                        records: viewModel.matchRecords,
                        stats: viewModel.stats
                    )

                    Section {
                        Button {
                            router.selectedTab = .bench
                            router.hobbyTab = .armies
                        } label: {
                            Label(String(localized: "Open Models collection"), systemImage: "tray.full")
                        }
                        .accessibilityIdentifier("playersHub.openModels")
                    } footer: {
                        Text(
                            String(
                                localized: """
                                Track painted models in the Models tab. Mark Spearhead armies you own above for faster Guided Match setup.
                                """
                            )
                        )
                    }
                }
                .formEditorTopContentMargin()
                .onAppear { editingName = profile.displayName }
                .onChange(of: profile.displayName) { _, newValue in
                    editingName = newValue
                }
            } else {
                ContentUnavailableView(
                    String(localized: "Player not found"),
                    systemImage: "person.crop.circle.badge.exclamationmark"
                )
            }
        }
        .navigationTitle(viewModel.profile?.displayName ?? String(localized: "Player"))
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("playersHub.detail.\(viewModel.profileId.uuidString)")
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
    }
}
