import SwiftUI
import TabletomeDomain

extension BattlePhaseTrackerView {
    var victoryScreen: some View {
        MatchVictoryScreen(
            presentation: MatchVictoryPresentation(
                gameSystemId: viewModel.gameSystemId.rawValue,
                gameSystemName: GameSystemRulesLabels.displayName(gameSystemId: viewModel.gameSystemId),
                playerOneName: viewModel.playerOneName,
                playerTwoName: viewModel.playerTwoName,
                playerOneArmyLabel: viewModel.playerOneArmyLabel,
                playerTwoArmyLabel: viewModel.playerTwoArmyLabel,
                playerOneVictoryPoints: victoryPlayerOneVP,
                playerTwoVictoryPoints: victoryPlayerTwoVP,
                startedAt: MatchSessionStore.startedAt(gameSystemId: viewModel.gameSystemId),
                status: .completed
            ),
            mode: .interactive,
            onDone: {
                Task { await completeVictory(rematch: false) }
            },
            onRematch: {
                Task { await completeVictory(rematch: true) }
            },
            onVictoryPointsChange: { playerOne, playerTwo in
                victoryPlayerOneVP = playerOne
                victoryPlayerTwoVP = playerTwo
                viewModel.setFinalVictoryPoints(playerOne: playerOne, playerTwo: playerTwo)
            }
        )
    }

    func presentVictoryScreen() {
        unitFocusSelection = nil
        victoryPlayerOneVP = viewModel.trackerState.playerOneVictoryPoints
        victoryPlayerTwoVP = viewModel.trackerState.playerTwoVictoryPoints
        dismissedBattleCompleteGuide = true
        showsVictoryScreen = true
        Task {
            await onVictoryPresented?(victoryPlayerOneVP, victoryPlayerTwoVP)
        }
        TabletomeAnalytics.logger?.info(
            .guidedMatch,
            eventName: "battle_tracker_victory_presented",
            message: "Victory screen presented.",
            metadata: [
                "gameSystemId": viewModel.gameSystemId.rawValue,
                "playerOneVP": String(victoryPlayerOneVP),
                "playerTwoVP": String(victoryPlayerTwoVP),
                "battleRound": String(viewModel.trackerState.battleRound),
                "durationSeconds": TabletomeAnalytics.durationSeconds(
                    since: MatchSessionStore.startedAt(gameSystemId: viewModel.gameSystemId)
                ) ?? "0"
            ]
        )
    }

    func completeVictory(rematch: Bool) async {
        await onVictoryComplete?(rematch, victoryPlayerOneVP, victoryPlayerTwoVP)
        showsVictoryScreen = false
        viewModel.reloadFromPersistedStores()
        onMatchStateChange?()
        if rematch {
            dismissedBattleCompleteGuide = false
        }
    }
}
