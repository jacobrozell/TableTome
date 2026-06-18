import SwiftUI
import TabletomeDomain

extension GuidedMatchView {
    @ToolbarContentBuilder
    var matchHistoryToolbarItems: some ToolbarContent {
        if ReleaseSurface.showsMatchHistory {
            ToolbarItem(placement: .topBarLeading) {
                NavigationLink(value: MatchHistoryLink()) {
                    Label(String(localized: "History"), systemImage: "clock.arrow.circlepath")
                }
                .accessibilityIdentifier("guidedMatch.history")
            }
        }
    }

    func handleVictoryComplete(rematch: Bool, playerOneVP: Int, playerTwoVP: Int) async {
        await viewModel.finishMatch(
            repository: dependencies.matchHistoryRepository,
            rematch: rematch,
            playerOneVictoryPoints: playerOneVP,
            playerTwoVictoryPoints: playerTwoVP,
            status: .completed
        )
        viewModel.reloadFromStore()
    }

    func resetMatch(saveToHistory: Bool) async {
        if saveToHistory {
            let tracker = BattleTrackerStore.load(gameSystemId: gameSystemId)
            await viewModel.finishMatch(
                repository: dependencies.matchHistoryRepository,
                rematch: false,
                playerOneVictoryPoints: tracker.playerOneVictoryPoints,
                playerTwoVictoryPoints: tracker.playerTwoVictoryPoints,
                status: .abandoned
            )
        } else {
            viewModel.resetMatch()
        }
        selectedDestination = nil
    }
}