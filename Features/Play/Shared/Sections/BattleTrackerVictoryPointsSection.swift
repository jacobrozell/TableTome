import SwiftUI
import TabletomeDomain

struct BattleTrackerVictoryPointsSection: View {
    @ObservedObject var viewModel: BattlePhaseTrackerViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            if !viewModel.playContext.usesAlternatingActivation, viewModel.trackerState.currentPhase != .deployment {
                BattleRoundTurnProgressChip(
                    round: viewModel.trackerState.battleRound,
                    playerOneName: viewModel.playerOneName,
                    playerTwoName: viewModel.playerTwoName,
                    completedTurnPlayerOnes: viewModel.trackerState.completedTurnsThisRound,
                    activePlayerIsOne: viewModel.trackerState.activePlayerIsOne
                )
            }

            VictoryPointsCard(
                playerOneName: viewModel.playerOneName,
                playerTwoName: viewModel.playerTwoName,
                playerOneVP: viewModel.trackerState.playerOneVictoryPoints,
                playerTwoVP: viewModel.trackerState.playerTwoVictoryPoints,
                battleRound: viewModel.trackerState.battleRound,
                maxBattleRounds: viewModel.playContext.playEngine.battleRoundCount(),
                victoryPointsByRound: viewModel.trackerState.victoryPointsByRound,
                activePlayerIsOne: viewModel.trackerState.activePlayerIsOne,
                completedTurnPlayerOnes: viewModel.trackerState.completedTurnsThisRound,
                scoreLeaderIsPlayerOne: viewModel.scoreLeaderIsPlayerOne,
                highlightsScoring: viewModel.trackerState.currentPhase == (viewModel.playContext.capabilities.showsActivationBar ? .scoring : .endOfTurn),
                gameSystemId: viewModel.gameSystemId,
                defaultsExpandedPerTurnBreakdown: viewModel.gameSystemId == .aosSpearhead,
                onAdjust: { viewModel.adjustVictoryPoints(playerIsOne: $0, delta: $1, reason: $2) },
                onQuickAdd: { viewModel.adjustVictoryPoints(playerIsOne: $0, delta: $1, reason: $2) },
                onSetRoundVictoryPoints: { viewModel.setRoundVictoryPoints(playerIsOne: $1, round: $0, value: $2) },
                turnIsComplete: { viewModel.turnIsComplete(round: $0, playerIsOne: $1) },
                turnIsActive: { viewModel.turnIsActive(round: $0, playerIsOne: $1) }
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            if let underdogIsPlayerOne = viewModel.underdogIsPlayerOne,
               viewModel.playContext.capabilities.showsBattleTacticDecks {
                let name = underdogIsPlayerOne ? viewModel.playerOneName : viewModel.playerTwoName
                HStack(spacing: DesignTokens.Spacing.sm) {
                    Image(systemName: "arrow.down.circle.fill")
                        .foregroundStyle(.orange)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(String(localized: "Underdog this round"))
                            .font(.caption.weight(.semibold))
                        Text(name)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, DesignTokens.Spacing.sm)
                .padding(.vertical, DesignTokens.Spacing.sm)
                .background(Color.orange.opacity(0.08), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm))
            }
        }
    }
}
