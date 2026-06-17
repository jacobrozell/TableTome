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
                    if viewModel.gameSystems.count == 1,
                       let system = viewModel.gameSystems.first,
                       system.id == "aos-spearhead" {
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
            Text(system.name)
                .font(.headline)
            Text(newcomerTagline(for: system))
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(system.edition)
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, DesignTokens.Spacing.xs)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(system.name). \(newcomerTagline(for: system)). \(system.edition)")
    }

    private func newcomerTagline(for system: GameSystem) -> String {
        if system.id == "aos-spearhead" {
            return String(localized: "Learn and play with your starter-set armies")
        }
        return system.tagline
    }
}
