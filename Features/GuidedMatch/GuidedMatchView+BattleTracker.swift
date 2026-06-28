import SwiftUI
import TabletomeDomain

extension GuidedMatchView {
    @ViewBuilder
    func guidedMatchScreen(
        destination: GuidedMatchDestination,
        catalog: SpearheadCatalog,
        dismissesArmySelectionOnSave: Bool
    ) -> some View {
        switch destination {
        case .playerOne:
            ArmySelectionView(
                title: String(localized: "Player 1 Army"),
                selection: viewModel.matchState.playerOne,
                factions: viewModel.sortedFactions,
                featuredArmies: featuredArmies,
                ruleSections: ruleSections,
                gameSystemId: viewModel.gameSystemId,
                dismissesOnSave: dismissesArmySelectionOnSave,
                onSave: viewModel.updatePlayerOne
            )
        case .playerTwo:
            ArmySelectionView(
                title: String(localized: "Player 2 Army"),
                selection: viewModel.matchState.playerTwo,
                factions: viewModel.sortedFactions,
                featuredArmies: featuredArmies,
                ruleSections: ruleSections,
                gameSystemId: viewModel.gameSystemId,
                dismissesOnSave: dismissesArmySelectionOnSave,
                onSave: viewModel.updatePlayerTwo
            )
        case .battleTracker:
            if viewModel.matchState.hasBothArmies {
                PlayShell(
                    gameSystemId: gameSystemId,
                    matchState: viewModel.matchState,
                    catalog: catalog,
                    ruleSections: ruleSections,
                    onMatchStateChange: { viewModel.reloadFromStore() },
                    onVictoryComplete: handleVictoryComplete
                )
            } else {
                guidedMatchPlaceholder(
                    title: String(localized: "Battle Phase Tracker"),
                    message: String(localized: "Choose both player armies to open the battle tracker.")
                )
            }
        case .step(let stepId):
            if let step = viewModel.sortedMatchSteps.first(where: { $0.id == stepId }),
               let index = viewModel.sortedMatchSteps.firstIndex(where: { $0.id == stepId }) {
                MatchStepDetailView(
                    step: step,
                    stepNumber: index + 1,
                    viewModel: viewModel,
                    ruleSections: ruleSections
                )
            } else {
                guidedMatchPlaceholder(
                    title: String(localized: "Match Setup"),
                    message: String(localized: "This step could not be loaded.")
                )
            }
        }
    }

    @ViewBuilder
    func embeddedBattleTracker(catalog: SpearheadCatalog) -> some View {
        PlayShell(
            gameSystemId: gameSystemId,
            matchState: viewModel.matchState,
            catalog: catalog,
            ruleSections: ruleSections,
            onMatchStateChange: {
                viewModel.reloadFromStore()
                hubTrackerTick += 1
            },
            onVictoryComplete: handleVictoryComplete
        )
        .environment(\.battleTrackerIsEmbeddedInGuidedMatch, true)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityIdentifier("guidedMatch.embeddedBattleTracker")
    }
}
