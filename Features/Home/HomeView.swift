import SwiftUI
import TabletomeDomain

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel

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
                        Section {
                            HomeWelcomeCard()
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                    }

                    ForEach(viewModel.gameSystems) { system in
                        NavigationLink(value: system.id) {
                            gameSystemRow(system)
                        }
                        .accessibilityIdentifier("home.gameSystem.\(system.id)")
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
        .navigationDestination(for: GettingStartedLink.self) { link in
            GettingStartedDestinationView(gameSystemId: link.gameSystemId)
        }
        .navigationDestination(for: GuidedMatchLink.self) { link in
            GuidedMatchDestinationView(gameSystemId: link.gameSystemId)
        }
        .navigationDestination(for: SampleTurnLink.self) { _ in
            SampleTurnWalkthroughView()
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
            return String(localized: "Learn and play with your starter-set armies")
        }
        if system.id == "wh40k-11e" {
            return String(localized: "New to 40k or upgrading from 10th? Guided setup and rules")
        }
        return system.tagline
    }
}
