import SwiftUI
import TabletomeDomain

struct GuidedMatchDestinationView: View {
    let gameSystemId: GameSystemId

    @EnvironmentObject private var dependencies: AppDependencies
    @State private var ruleSections: [RuleSection]?
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if let ruleSections {
                GuidedMatchView(
                    viewModel: dependencies.makeGuidedMatchViewModel(gameSystemId: gameSystemId),
                    ruleSections: ruleSections
                )
            } else if let errorMessage {
                EmptyStateView(title: String(localized: "Not Found"), message: errorMessage)
            } else {
                ProgressView(String(localized: "Loading match setup…"))
                    .accessibilityIdentifier("guidedMatch.loading")
            }
        }
        .navigationTitle(String(localized: "Guided Match"))
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
