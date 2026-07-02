import SwiftUI
import TabletomeDomain

extension GuidedMatchView {
    @ToolbarContentBuilder
    var matchHistoryToolbarItems: some ToolbarContent {
        if ReleaseSurface.showsMatchHistory, showsMatchHistoryToolbar {
            ToolbarItem(placement: .topBarLeading) {
                NavigationLink(value: MatchHistoryLink()) {
                    Label(String(localized: "History"), systemImage: "clock.arrow.circlepath")
                }
                .accessibilityIdentifier("guidedMatch.history")
                .accessibilityHint(String(localized: "Past guided matches with scores and turn logs"))
            }
        }
    }

    func handleVictoryPresented(playerOneVP: Int, playerTwoVP: Int) async {
        guard gameSystemId == .aosSpearhead else { return }
        await viewModel.archiveVictoryIfNeeded(
            repository: dependencies.matchHistoryRepository,
            playerOneVictoryPoints: playerOneVP,
            playerTwoVictoryPoints: playerTwoVP
        )
    }

    func handleVictoryComplete(rematch: Bool, playerOneVP: Int, playerTwoVP: Int) async {
        if gameSystemId == .aosSpearhead {
            await viewModel.archiveVictoryIfNeeded(
                repository: dependencies.matchHistoryRepository,
                playerOneVictoryPoints: playerOneVP,
                playerTwoVictoryPoints: playerTwoVP
            )
            viewModel.finishAfterVictoryPresented(rematch: rematch)
        } else {
            await viewModel.finishMatch(
                repository: dependencies.matchHistoryRepository,
                rematch: rematch,
                playerOneVictoryPoints: playerOneVP,
                playerTwoVictoryPoints: playerTwoVP,
                status: .completed
            )
        }
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
        hubTab = suggestedHubTab
    }
}
