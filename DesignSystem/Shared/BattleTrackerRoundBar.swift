import SwiftUI
import TabletomeDomain

/// Compact round controls for iPad turn layout when the phase playbook uses full width.
struct BattleTrackerRoundBar: View {
    @ObservedObject var viewModel: BattlePhaseTrackerViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            HStack(alignment: .center, spacing: DesignTokens.Spacing.md) {
                Stepper(
                    viewModel.playContext.playEngine.roundLabel(round: viewModel.trackerState.battleRound),
                    value: Binding(
                        get: { viewModel.trackerState.battleRound },
                        set: { viewModel.setBattleRound($0) }
                    ),
                    in: 1...viewModel.playContext.playEngine.battleRoundCount()
                )
                .accessibilityIdentifier("battleTracker.round")

                Spacer(minLength: 0)

                if viewModel.canPassToNextPlayerThisRound {
                    Button {
                        viewModel.completePhasedRoundTurnPhase(.endOfTurn)
                    } label: {
                        Label(String(localized: "Next Turn"), systemImage: "arrow.left.arrow.right")
                            .font(.caption.weight(.semibold))
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier("battleTracker.nextPlayer")
                } else if viewModel.canAdvanceBattleRound {
                    Button {
                        viewModel.advanceBattleRound()
                    } label: {
                        Label(
                            String(
                                localized: "Start \(viewModel.playContext.playEngine.roundLabel(round: viewModel.trackerState.battleRound + 1))"
                            ),
                            systemImage: "arrow.up.circle.fill"
                        )
                        .font(.caption.weight(.semibold))
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier("battleTracker.advanceRound")
                }
            }

            if !viewModel.playContext.usesAlternatingActivation {
                BattleRoundTurnProgressChip(
                    round: viewModel.trackerState.battleRound,
                    playerOneName: viewModel.playerOneName,
                    playerTwoName: viewModel.playerTwoName,
                    completedTurnPlayerOnes: viewModel.trackerState.completedTurnsThisRound,
                    activePlayerIsOne: viewModel.trackerState.activePlayerIsOne
                )
            }

            if !viewModel.canPassToNextPlayerThisRound,
               !viewModel.canAdvanceBattleRound,
               viewModel.trackerState.currentPhase == .endOfTurn {
                Text(roundAdvanceHint)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .surfaceCard()
        .accessibilityIdentifier("battleTracker.roundBar")
    }

    private var roundAdvanceHint: String {
        if viewModel.trackerState.completedTurnsThisRound.count < 2 {
            return String(
                localized: "Both players must finish End of Turn before starting the next battle round."
            )
        }
        return String(localized: "Finish scoring, then use Start next round when both turns are done.")
    }
}
