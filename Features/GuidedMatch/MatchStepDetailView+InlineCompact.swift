import SwiftUI
import TabletomeDomain

extension MatchStepDetailView {
    @ViewBuilder
    var compactInlineBattlefieldContent: some View {
        switch step.id {
        case "realm-battlefield":
            RealmSideCoinFlipCard(compactMode: true)
            DeploymentChecklistCard(
                completedSteps: viewModel.deploymentCompletedSteps,
                focusedStep: BattleFlowGuide.nextIncompleteDeploymentStep(
                    in: viewModel.deploymentCompletedSteps
                ),
                compactMode: true,
                onToggle: viewModel.setDeploymentStep
            )
        case "deploy-battlefield":
            Wh40kDeploymentChecklistCard(
                completedSteps: viewModel.deploymentCompletedSteps,
                focusedStep: Wh40kDeploymentChecklistStep.allCases.first {
                    !Wh40kDeploymentChecklist.isComplete(
                        step: $0,
                        completedSteps: viewModel.deploymentCompletedSteps
                    )
                },
                onToggle: viewModel.setWh40kDeploymentStep,
                compactMode: true,
                gameSystemId: viewModel.gameSystemId.rawValue,
                ruleSections: ruleSections
            )
        case "setup-battlefield":
            CombatPatrolDeploymentChecklistCard(
                completedSteps: viewModel.deploymentCompletedSteps,
                focusedSteps: [.setupTerrain, .placeObjectives, .attackerDefender],
                onToggle: viewModel.setCombatPatrolDeploymentStep,
                compactMode: true
            )
        case "battlefield-setup":
            ScTmgDeploymentChecklistCard(
                completedSteps: viewModel.deploymentCompletedSteps,
                focusedStep: BattleFlowGuide.nextIncompleteScTmgSetupStep(
                    in: viewModel.deploymentCompletedSteps
                ),
                compactMode: true,
                onToggle: viewModel.setScTmgDeploymentStep
            )
        default:
            stepSpecificContent
        }
    }

    var inlineStepCompletionHint: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            Image(systemName: isComplete ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isComplete ? .green : .secondary)
            Text(completionHint)
                .font(.subheadline)
                .foregroundStyle(isComplete ? .primary : .secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityIdentifier("guidedMatch.stepComplete.\(step.id)")
    }
}
