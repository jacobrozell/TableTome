import SwiftUI
import TabletomeDomain

extension BattlePhaseTrackerView {
    @ViewBuilder
    var phasedRoundDeploymentSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            DeploymentZoneCallout(gameSystemId: viewModel.gameSystemId)

            if viewModel.trackerState.currentPhase == .deployment
                || viewModel.trackerState.battleRound == 1 {
                BattleTrackerDeploymentAbilitiesSection(
                    playerOneName: viewModel.playerOneName,
                    playerTwoName: viewModel.playerTwoName,
                    playerOneArmy: viewModel.playerOneArmy,
                    playerTwoArmy: viewModel.playerTwoArmy,
                    usedOncePerBattleAbilityIds: viewModel.trackerState.usedOncePerBattleAbilityIds,
                    ruleSections: ruleSections,
                    onMarkUsed: viewModel.markUsed
                )
            }

            if viewModel.playContext.capabilities.deploymentChecklistStyle == .wh40k {
                Wh40kDeploymentChecklistCard(
                    completedSteps: viewModel.trackerState.completedDeploymentSteps,
                    focusedStep: viewModel.focusedWh40kDeploymentStep,
                    onToggle: viewModel.setWh40kDeploymentStep,
                    gameSystemId: viewModel.gameSystemId.rawValue,
                    ruleSections: ruleSections
                )
            } else if viewModel.playContext.capabilities.usesPatrolFormatRules {
                CombatPatrolDeploymentChecklistCard(
                    completedSteps: viewModel.trackerState.completedDeploymentSteps,
                    focusedSteps: Set(
                        [viewModel.focusedCombatPatrolDeploymentStep].compactMap { $0 }
                    ),
                    onToggle: viewModel.setCombatPatrolDeploymentStep
                )
            } else {
                RealmSideCoinFlipCard()
                DeploymentChecklistCard(
                    completedSteps: viewModel.trackerState.completedDeploymentSteps,
                    focusedStep: viewModel.focusedDeploymentStep,
                    onToggle: viewModel.setDeploymentStep
                )
            }
        }
        .padding(.top, DesignTokens.Spacing.sm)
    }

    @ViewBuilder
    var phasedRoundSecondarySections: some View {
        BattleTrackerBothLoadoutsSection(
            playerOneName: viewModel.playerOneName,
            playerTwoName: viewModel.playerTwoName,
            playerOneArmy: viewModel.playerOneArmy,
            playerTwoArmy: viewModel.playerTwoArmy,
            playerOneRegimentAbility: viewModel.playerOneRegimentAbility,
            playerTwoRegimentAbility: viewModel.playerTwoRegimentAbility,
            playerOneEnhancement: viewModel.playerOneEnhancement,
            playerTwoEnhancement: viewModel.playerTwoEnhancement,
            playerOneSecondary: viewModel.playerOneSecondary,
            playerTwoSecondary: viewModel.playerTwoSecondary,
            playerIsAttacker: viewModel.playerIsAttacker(isOne:),
            ruleSections: ruleSections,
            gameSystemId: viewModel.gameSystemId
        )
        if viewModel.playContext.capabilities.showsBattleTacticDecks
            || viewModel.playContext.capabilities.usesPatrolFormatRules {
            gotchaSection
        }
    }
}
