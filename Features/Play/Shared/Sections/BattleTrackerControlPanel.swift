import SwiftUI
import TabletomeDomain

struct BattleTrackerControlPanel: View {
    @ObservedObject var viewModel: BattlePhaseTrackerViewModel
    var showsPhaseGuidanceInPicker: Bool = true
    var showsAdvancePhaseButton: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            if viewModel.playContext.usesAlternatingActivation {
                ScActivationBar(
                    activePlayerName: viewModel.trackerState.activePlayerIsOne
                        ? viewModel.playerOneName
                        : viewModel.playerTwoName,
                    phase: viewModel.trackerState.currentPhase,
                    markerHolderName: viewModel.scFirstPlayerMarkerHolderName,
                    passClaimedByActivePlayer: viewModel.trackerState.scPhasePassClaimedByPlayerOne
                        == viewModel.trackerState.activePlayerIsOne,
                    onDone: viewModel.completeActivation,
                    onPass: viewModel.passActivation
                )
            }

            Stepper(
                viewModel.playContext.playEngine.roundLabel(round: viewModel.trackerState.battleRound),
                value: Binding(
                    get: { viewModel.trackerState.battleRound },
                    set: { viewModel.setBattleRound($0) }
                ),
                in: 1...viewModel.playContext.playEngine.battleRoundCount()
            )
            .accessibilityIdentifier("battleTracker.round")

            if viewModel.canAdvanceBattleRound {
                Button {
                    viewModel.advanceBattleRound()
                } label: {
                    Label(
                        String(
                            localized: "Start \(viewModel.playContext.playEngine.roundLabel(round: viewModel.trackerState.battleRound + 1))"
                        ),
                        systemImage: "arrow.up.circle.fill"
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .prominentButtonLabelStyle()
                }
                .buttonStyle(.borderedProminent)
                .frame(minHeight: DesignTokens.minTouchTarget)
                .accessibilityIdentifier("battleTracker.advanceRound")
            }

            BattleTrackerPlayerSwitcher(
                playerOneName: viewModel.playerOneName,
                playerTwoName: viewModel.playerTwoName,
                activePlayerIsOne: viewModel.trackerState.activePlayerIsOne,
                label: BattleTrackerPlayerSwitcher.label(
                    round: viewModel.trackerState.battleRound,
                    playerOneVictoryPoints: viewModel.trackerState.playerOneVictoryPoints,
                    playerTwoVictoryPoints: viewModel.trackerState.playerTwoVictoryPoints,
                    completedTurnsThisRound: viewModel.trackerState.completedTurnsThisRound.count,
                    roundOpenerIncomplete: viewModel.roundOpenerIsIncomplete
                ),
                onSelect: { viewModel.setActivePlayer(isOne: $0) }
            )

            AttackerDefenderPickerCard(
                playerOneName: viewModel.playerOneName,
                playerTwoName: viewModel.playerTwoName,
                attackerIsPlayerOne: viewModel.attackerIsPlayerOne,
                onSelect: viewModel.setAttacker,
                accessibilityPrefix: "battleTracker"
            )

            if viewModel.playContext.capabilities.usesPatrolFormatRules,
               viewModel.trackerState.battleRound == 1 {
                FirstTurnPickerCard(
                    playerOneName: viewModel.playerOneName,
                    playerTwoName: viewModel.playerTwoName,
                    firstTurnIsPlayerOne: viewModel.matchState.firstTurnIsPlayerOne,
                    onSelect: viewModel.setFirstTurn
                )
            }

            Text(viewModel.armyName)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            BattleTrackerPhaseControls(
                viewModel: viewModel,
                showsPhaseGuidance: showsPhaseGuidanceInPicker,
                showsAdvancePhaseButton: showsAdvancePhaseButton
            )
                .id("phaseControls")
        }
    }
}
