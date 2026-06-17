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
                List(viewModel.gameSystems) { system in
                    NavigationLink(value: system.id) {
                        gameSystemRow(system)
                    }
                    .accessibilityIdentifier("home.gameSystem.\(system.id)")
                }
                .listStyle(.insetGrouped)
                .accessibilityIdentifier("home.gameSystemList")
            }
        }
        .navigationTitle(String(localized: "Learn"))
        .navigationDestination(for: String.self) { systemId in
            GameSystemDetailView(gameSystemId: systemId)
        }
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
    }

    private func gameSystemRow(_ system: GameSystem) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Text(system.name)
                .font(.headline)
            Text(system.tagline)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(system.edition)
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, DesignTokens.Spacing.xs)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(system.name). \(system.tagline). \(system.edition)")
    }
}
