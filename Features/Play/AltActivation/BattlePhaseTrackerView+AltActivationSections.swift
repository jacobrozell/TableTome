import SwiftUI
import TabletomeDomain

extension BattlePhaseTrackerView {
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
    var alternatingActivationSecondarySections: some View {
        BattleTrackerBothRostersSection(
            playerOneName: viewModel.playerOneName,
            playerTwoName: viewModel.playerTwoName,
            playerOneArmy: viewModel.playerOneArmy,
            playerTwoArmy: viewModel.playerTwoArmy,
            playerIsAttacker: viewModel.playerIsAttacker(isOne:)
        )
    }
}
