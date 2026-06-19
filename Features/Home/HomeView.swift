import SwiftUI
import TabletomeDomain

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    @EnvironmentObject private var dependencies: AppDependencies

    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.gameSystems.isEmpty {
                ProgressView(String(localized: "Loading guides…"))
                    .accessibilityIdentifier("home.loading")
            } else if let error = viewModel.errorMessage {
                EmptyStateView(
                    title: String(localized: "Unable to Load"),
                    message: error,
                    actionTitle: String(localized: "Retry"),
                    action: { Task { await viewModel.load() } }
                )
            } else {
                List {
                    if !viewModel.gameSystems.isEmpty {
                        if FirstSessionStore.shouldShowContinueCard(),
                           let choice = FirstSessionStore.onboardingChoice {
                            Section {
                                HomeContinueCard(gameSystemId: choice)
                            }
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                        } else {
                            Section {
                                HomeWelcomeCard()
                            }
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)

                            Section {
                                HomeNewPlayerChooserCard()
                            }
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                        }
                    }

                    Section {
                        ForEach(viewModel.gameSystems) { system in
                            NavigationLink(value: system.id) {
                                gameSystemRow(system)
                            }
                            .accessibilityIdentifier("home.gameSystem.\(system.id)")
                            .simultaneousGesture(TapGesture().onEnded {
                                ActiveGameContextStore.setActiveGameSystem(system.id)
                            })
                        }
                    } header: {
                        Text(String(localized: "All games"))
                    } footer: {
                        Text(String(localized: "Not sure which to pick? Start with the chooser above."))
                    }
                }
                .listStyle(.insetGrouped)
                .tabBarScrollInset()
                .accessibilityIdentifier("home.gameSystemList")
            }
        }
        .navigationTitle(String(localized: "Play"))
        .navigationDestination(for: String.self) { systemId in
            GameSystemDetailView(gameSystemId: systemId)
        }
        .playNavigationDestinations()
        .toolbar {
            if ReleaseSurface.showsMatchHistory {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(value: MatchHistoryLink()) {
                        Label(String(localized: "History"), systemImage: "clock.arrow.circlepath")
                    }
                    .accessibilityIdentifier("home.matchHistory")
                    .accessibilityHint(String(localized: "Past guided matches with scores and turn logs"))
                }
            }
        }
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
    }

    private func gameSystemRow(_ system: GameSystem) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            HStack(alignment: .firstTextBaseline, spacing: DesignTokens.Spacing.sm) {
                Text(system.name)
                    .font(.headline)
                if ReleaseSurface.showsNewEditionBadge(for: system.id) {
                    NewEditionBadge()
                }
            }
            Text(newcomerTagline(for: system))
                .font(.subheadline)
                .foregroundStyle(.secondary)
            if let footnote = editionFootnote(for: system) {
                Text(footnote)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            Text(system.edition)
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, DesignTokens.Spacing.xs)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(homeRowAccessibilityLabel(for: system))
    }

    private func homeRowAccessibilityLabel(for system: GameSystem) -> String {
        var parts = [system.name]
        if ReleaseSurface.showsNewEditionBadge(for: system.id) {
            parts.append(String(localized: "New edition"))
        }
        parts.append(contentsOf: [newcomerTagline(for: system), system.edition])
        return parts.joined(separator: ". ")
    }

    private func newcomerTagline(for system: GameSystem) -> String {
        if system.id == "aos-spearhead" {
            return String(localized: "Fantasy starter box — best first wargame")
        }
        if system.id == "wh40k-11e" {
            return String(localized: "Full 40k rules — not the small Combat Patrol format")
        }
        if system.id == "wh40k-10e-cp" {
            return String(localized: "40k starter box — guided first battles")
        }
        if system.id == "sc-tmg" {
            return String(localized: "StarCraft on the tabletop — Founders Edition")
        }
        return system.tagline
    }

    private func editionFootnote(for system: GameSystem) -> String? {
        if system.id == "wh40k-10e-cp" {
            return String(localized: "Uses 10th Edition Combat Patrol rules")
        }
        if system.id == "wh40k-11e" {
            return String(localized: "Current full-game edition")
        }
        return nil
    }
}
