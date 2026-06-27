import SwiftUI
import TabletomeDomain

struct GettingStartedDestinationView: View {
    let gameSystemId: String

    @EnvironmentObject private var dependencies: AppDependencies
    @State private var gameSystem: GameSystem?
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if let gameSystem {
                GettingStartedView(gameSystem: gameSystem)
            } else if let errorMessage {
                EmptyStateView(
                    title: String(localized: "Getting Started unavailable"),
                    message: errorMessage,
                    systemImage: "exclamationmark.triangle"
                )
                .asyncContentShell()
            } else {
                ProgressView(String(localized: "Loading guide…"))
                    .asyncContentShell()
                    .accessibilityIdentifier("guide.gettingStarted.loading")
            }
        }
        .navigationTitle(String(localized: "Getting Started"))
        .task { await load() }
    }

    private func load() async {
        do {
            gameSystem = try await dependencies.rulesRepository.gameSystem(id: gameSystemId)
        } catch {
            errorMessage = String(localized: "This getting started guide could not be loaded.")
        }
    }
}
