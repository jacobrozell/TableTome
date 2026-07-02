import SwiftUI
import TabletomeDomain

struct ScTmgBattlefieldSetupSection: View {
    @ObservedObject var viewModel: GuidedMatchViewModel

    var body: some View {
        ScTmgDeploymentChecklistCard(
            completedSteps: viewModel.deploymentCompletedSteps,
            focusedStep: BattleFlowGuide.nextIncompleteScTmgSetupStep(
                in: viewModel.deploymentCompletedSteps
            ),
            onToggle: viewModel.setScTmgDeploymentStep
        )
    }
}

struct ScTmgStepContent: View {
    let step: MatchSetupStep
    @ObservedObject var viewModel: GuidedMatchViewModel
    let ruleSections: [RuleSection]
    let usesSideBySideColumns: Bool

    var body: some View {
        switch step.id {
        case "choose-armies":
            MatchStepMatchupCard(
                hasBothArmies: viewModel.matchState.hasBothArmies,
                matchupSummary: viewModel.matchupSummary
            )
        case "roll-attacker":
            MatchStepAttackerPicker(
                playerOneName: viewModel.matchState.playerOne.playerName,
                playerTwoName: viewModel.matchState.playerTwo.playerName,
                attackerIsPlayerOne: viewModel.matchState.attackerIsPlayerOne,
                onSelect: viewModel.setAttacker
            )
        case "regiment-abilities":
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                MatchStepRegimentCoachingCallout(gameSystemId: viewModel.gameSystemId)
                MatchStepArmyOptionsSection(
                    viewModel: viewModel,
                    ruleSections: ruleSections,
                    usesSideBySideColumns: usesSideBySideColumns,
                    title: String(localized: "Regiment ability (pick one army rule)"),
                    playerOneKeyPath: \.regimentAbilityId,
                    playerTwoKeyPath: \.regimentAbilityId,
                    options: { army in army.regimentAbilities },
                    onSelect: viewModel.setRegimentAbility
                )
                MatchStepLoadoutSummarySection(
                    viewModel: viewModel,
                    usesSideBySideColumns: usesSideBySideColumns,
                    showRegiment: true,
                    showEnhancement: false
                )
            }
        case "battlefield-setup":
            ScTmgBattlefieldSetupSection(viewModel: viewModel)
        case "battle-format", "mission-setup", "confirm-lists":
            EmptyView()
        default:
            EmptyView()
        }
    }
}
