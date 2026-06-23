import SwiftUI
import TabletomeDomain

struct GuidedMatchDestinationView: View {
    let gameSystemId: GameSystemId
    var opensBattleTab: Bool = false

    @EnvironmentObject private var dependencies: AppDependencies
    @State private var ruleSections: [RuleSection]?
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if let ruleSections {
                GuidedMatchView(
                    viewModel: dependencies.makeGuidedMatchViewModel(gameSystemId: gameSystemId),
                    ruleSections: ruleSections,
                    initialHubTab: opensBattleTab ? .battle : nil
                )
            } else if let errorMessage {
                EmptyStateView(
                    title: String(localized: "Guided Match unavailable"),
                    message: errorMessage,
                    systemImage: "exclamationmark.triangle"
                )
                .asyncContentShell()
            } else {
                ProgressView(String(localized: "Loading match setup…"))
                    .asyncContentShell()
                    .accessibilityIdentifier("guidedMatch.loading")
            }
        }
        .navigationTitle(String(localized: "Guided Match"))
        .playNavigationDestinations()
        .task { await load() }
    }

    private func load() async {
        do {
            let gameSystem = try await dependencies.rulesRepository.gameSystem(id: gameSystemId.rawValue)
            ruleSections = gameSystem.ruleSections
        } catch {
            errorMessage = String(localized: "Guided Match could not be loaded.")
        }
    }
}
