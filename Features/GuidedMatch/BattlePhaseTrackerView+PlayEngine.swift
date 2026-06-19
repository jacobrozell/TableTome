import SwiftUI
import TabletomeDomain

extension BattlePhaseTrackerView {
    @ViewBuilder
    var engineDeploymentSection: some View {
        if viewModel.usesAlternatingActivation {
            alternatingActivationDeploymentSection
        } else {
            phasedRoundDeploymentSection
        }
    }

    @ViewBuilder
    var phasedRoundDeploymentSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            if viewModel.playContext.isWh40k11e {
                Wh40kDeploymentChecklistCard(
                    completedSteps: viewModel.trackerState.completedDeploymentSteps,
                    focusedStep: viewModel.focusedWh40kDeploymentStep,
                    onToggle: viewModel.setWh40kDeploymentStep,
                    gameSystemId: viewModel.gameSystemId.rawValue,
                    ruleSections: ruleSections
                )
            } else if viewModel.playContext.isCombatPatrol {
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
    var alternatingActivationDeploymentSection: some View {
        ScTmgDeploymentChecklistCard(
            completedSteps: viewModel.trackerState.completedDeploymentSteps,
            focusedStep: viewModel.focusedScTmgDeploymentStep,
            onToggle: viewModel.setScTmgDeploymentStep
        )
        .padding(.top, DesignTokens.Spacing.sm)
    }

    @ViewBuilder
    var engineSecondarySections: some View {
        if viewModel.usesAlternatingActivation {
            BattleTrackerBothRostersSection(
                playerOneName: viewModel.playerOneName,
                playerTwoName: viewModel.playerTwoName,
                playerOneArmy: viewModel.playerOneArmy,
                playerTwoArmy: viewModel.playerTwoArmy,
                playerIsAttacker: viewModel.playerIsAttacker(isOne:)
            )
        } else {
            phasedRoundSecondarySections
        }
        BattleTrackerReferenceLinksSection(
            ruleSections: ruleSections,
            gameSystemId: viewModel.gameSystemId
        )
    }

    @ViewBuilder
    private var phasedRoundSecondarySections: some View {
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
            || viewModel.playContext.isCombatPatrol {
            gotchaSection
        }
    }
}
