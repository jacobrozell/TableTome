import SwiftUI
import TabletomeDomain

struct BattleTrackerRoundOpenerSection: View {
    @ObservedObject var viewModel: BattlePhaseTrackerViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            if viewModel.playContext.capabilities.showsRoundChecklist {
                RoundChecklistCard(
                    round: viewModel.trackerState.battleRound,
                    completedSteps: viewModel.trackerState.completedRoundChecklistSteps,
                    focusedStep: viewModel.focusedRoundOpenerStep,
                    playerOneName: viewModel.playerOneName,
                    playerTwoName: viewModel.playerTwoName,
                    attackerName: viewModel.attackerDisplayName,
                    firstTurnIsPlayerOne: viewModel.matchState.firstTurnIsPlayerOne,
                    onSelectFirstTurn: { playerIsOne in
                        if viewModel.trackerState.battleRound == 1 {
                            viewModel.correctRoundOneFirstTurn(isPlayerOne: playerIsOne)
                        } else {
                            viewModel.setRoundFirstTurn(isPlayerOne: playerIsOne)
                        }
                    },
                    onToggle: viewModel.setRoundChecklistStep
                )
            }
            if viewModel.playContext.capabilities.usesPatrolFormatRules {
                CombatPatrolTableStateCard(
                    mission: viewModel.selectedMission,
                    playerOneName: viewModel.playerOneName,
                    playerTwoName: viewModel.playerTwoName,
                    playerOneArmy: viewModel.playerOneArmy,
                    playerTwoArmy: viewModel.playerTwoArmy,
                    playerOneSecondary: viewModel.playerOneSecondary,
                    playerTwoSecondary: viewModel.playerTwoSecondary,
                    activePlayerIsOne: viewModel.trackerState.activePlayerIsOne,
                    battleRound: viewModel.trackerState.battleRound,
                    currentPhase: viewModel.trackerState.currentPhase,
                    playerOneBattleReady: battleReadyBinding(isPlayerOne: true),
                    playerTwoBattleReady: battleReadyBinding(isPlayerOne: false),
                    securedObjectiveIds: securedBinding,
                    usedStratagemIds: stratagemBinding,
                    intelRecoveredObjectiveIds: intelBinding,
                    onApplyBattleReadyBonus: viewModel.applyBattleReadyBonus
                )
            }
        }
    }

    private func battleReadyBinding(isPlayerOne: Bool) -> Binding<Bool?> {
        Binding(
            get: { isPlayerOne ? viewModel.trackerState.playerOneBattleReady : viewModel.trackerState.playerTwoBattleReady },
            set: { viewModel.setBattleReady(isPlayerOne: isPlayerOne, value: $0) }
        )
    }

    private var securedBinding: Binding<Set<String>> {
        Binding(
            get: { viewModel.trackerState.securedObjectiveIds },
            set: { viewModel.setSecuredObjectiveIds($0) }
        )
    }

    private var stratagemBinding: Binding<Set<String>> {
        Binding(
            get: { viewModel.trackerState.usedStratagemIds },
            set: { viewModel.setUsedStratagemIds($0) }
        )
    }

    private var intelBinding: Binding<Set<String>> {
        Binding(
            get: { viewModel.trackerState.intelRecoveredObjectiveIds },
            set: { viewModel.setIntelRecoveredObjectiveIds($0) }
        )
    }
}

/// Ongoing match score — Turn tab after deployment; phase dock Score shortcut when enabled.
