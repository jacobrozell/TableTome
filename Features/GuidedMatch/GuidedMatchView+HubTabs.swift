import SwiftUI
import TabletomeDomain

extension GuidedMatchView {
    var setupIsComplete: Bool {
        guard viewModel.matchState.hasBothArmies else { return false }
        let progress = viewModel.setupProgress
        guard progress.total > 0 else { return true }
        return progress.completed == progress.total
    }

    var suggestedHubTab: GuidedMatchHubTab {
        GuidedMatchHubTab.suggested(
            hasBothArmies: viewModel.matchState.hasBothArmies,
            setupComplete: setupIsComplete
        )
    }

    func playerSummary(
        selection: PlayerArmySelection,
        catalog: SpearheadCatalog,
        fallback: String
    ) -> String {
        let name = selection.playerName.isEmpty ? fallback : selection.playerName
        guard let faction = catalog.factions.first(where: { $0.id == selection.factionId }),
              let army = faction.armies.first(where: { $0.id == selection.armyId }) else {
            return name
        }
        return "\(name) · \(army.name)"
    }

    func battleTrackerSummaryLine() -> String? {
        guard setupIsComplete else { return nil }
        let state = BattleTrackerStore.load(gameSystemId: gameSystemId)
        let playerName = state.activePlayerIsOne
            ? (viewModel.matchState.playerOne.playerName.isEmpty
                ? String(localized: "Player 1")
                : viewModel.matchState.playerOne.playerName)
            : (viewModel.matchState.playerTwo.playerName.isEmpty
                ? String(localized: "Player 2")
                : viewModel.matchState.playerTwo.playerName)
        return "\(BattleRules.roundLabel(round: state.battleRound, gameSystemId: gameSystemId)) · \(state.currentPhase.title) · \(playerName)"
    }

    var showsEmbeddedBattleTracker: Bool {
        hubTab == .battle && setupIsComplete && viewModel.matchState.hasBothArmies
    }
}
