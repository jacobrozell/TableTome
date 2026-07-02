import SwiftUI
import TabletomeDomain

/// Score breakdown and per-round editing — opened from the sticky battle header.
struct SpearheadVictoryPointsSheet: View {
    @ObservedObject var viewModel: SpearheadBattleViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                    Text(
                        String(
                            localized: """
                            Tap +/− to adjust totals, or edit each round below. \
                            The player with fewer points is the underdog and refreshes battle tactics.
                            """
                        )
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                    VictoryPointsCard(
                        playerOneName: viewModel.playerOneName,
                        playerTwoName: viewModel.playerTwoName,
                        playerOneVP: viewModel.trackerState.playerOneVictoryPoints,
                        playerTwoVP: viewModel.trackerState.playerTwoVictoryPoints,
                        battleRound: viewModel.trackerState.battleRound,
                        maxBattleRounds: viewModel.maxBattleRounds,
                        victoryPointsByRound: viewModel.trackerState.victoryPointsByRound,
                        activePlayerIsOne: viewModel.trackerState.activePlayerIsOne,
                        completedTurnPlayerOnes: viewModel.trackerState.completedTurnsThisRound,
                        scoreLeaderIsPlayerOne: viewModel.scoreLeaderIsPlayerOne,
                        highlightsScoring: viewModel.trackerState.currentPhase == .endOfTurn,
                        gameSystemId: viewModel.gameSystemId,
                        defaultsExpandedPerTurnBreakdown: true,
                        onAdjust: { viewModel.adjustVictoryPoints(playerIsOne: $0, delta: $1, reason: $2) },
                        onQuickAdd: { viewModel.adjustVictoryPoints(playerIsOne: $0, delta: $1, reason: $2) },
                        onSetRoundVictoryPoints: { viewModel.setRoundVictoryPoints(round: $0, playerIsOne: $1, value: $2) },
                        turnIsComplete: { viewModel.turnIsComplete(round: $0, playerIsOne: $1) },
                        turnIsActive: { viewModel.turnIsActive(round: $0, playerIsOne: $1) }
                    )

                    if let underdogIsPlayerOne = viewModel.underdogIsPlayerOne {
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
                        .padding(DesignTokens.Spacing.sm)
                        .background(Color.orange.opacity(0.08), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm))
                    }
                }
                .padding(DesignTokens.Spacing.md)
                .readableContentWidth()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(String(localized: "Victory Points"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Done")) { dismiss() }
                }
            }
        }
        .accessibilityIdentifier("spearheadBattle.victoryPointsSheet")
    }
}
