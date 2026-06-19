import SwiftUI
import TabletomeDomain

struct EditionMigrationDestinationView: View {
    let gameSystemId: String

    @EnvironmentObject private var dependencies: AppDependencies
    @State private var gameSystem: GameSystem?
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if let gameSystem {
                EditionMigrationView(gameSystem: gameSystem)
            } else if let errorMessage {
                EmptyStateView(
                    title: String(localized: "Edition guide unavailable"),
                    message: errorMessage
                )
            } else {
                ProgressView(String(localized: "Loading guide…"))
                    .accessibilityIdentifier("guide.migration.loading")
            }
        }
        .task { await load() }
    }

    private func load() async {
        do {
            gameSystem = try await dependencies.rulesRepository.gameSystem(id: gameSystemId)
        } catch {
            errorMessage = String(localized: "This guide could not be loaded.")
        }
    }
}
