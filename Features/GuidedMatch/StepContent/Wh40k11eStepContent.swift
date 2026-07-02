import SwiftUI
import TabletomeDomain

struct Wh40k11eDeploymentSetupSection: View {
    @ObservedObject var viewModel: GuidedMatchViewModel
    let ruleSections: [RuleSection]

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Wh40kDeploymentNowCard()

            Wh40kDeploymentChecklistCard(
                completedSteps: viewModel.deploymentCompletedSteps,
                focusedStep: Wh40kDeploymentChecklistStep.allCases.first {
                    !Wh40kDeploymentChecklist.isComplete(step: $0, completedSteps: viewModel.deploymentCompletedSteps)
                },
                onToggle: viewModel.setWh40kDeploymentStep,
                gameSystemId: viewModel.gameSystemId.rawValue,
                ruleSections: ruleSections
            )

            if let terrainSection = ruleSections.first(where: { $0.id == "11e-terrain-objectives" }) {
                ReferenceLinksGroup {
                    NavigationLink(value: RuleSectionLink(
                        gameSystemId: viewModel.gameSystemId.rawValue,
                        sectionId: terrainSection.id
                    )) {
                        ReferenceLinkRow(
                            title: terrainSection.title,
                            systemImage: "map"
                        )
                    }
                    .accessibilityIdentifier("guidedMatch.wh40kDeployment.terrainReference")
                }
            }
        }
    }
}

struct Wh40k11eStepContent: View {
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
        case "force-disposition", "regiment-abilities":
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                MatchStepRegimentCoachingCallout(gameSystemId: viewModel.gameSystemId)
                MatchStepArmyOptionsSection(
                    viewModel: viewModel,
                    ruleSections: ruleSections,
                    usesSideBySideColumns: usesSideBySideColumns,
                    title: String(localized: "Force Dispositions"),
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
        case "deploy-battlefield":
            Wh40k11eDeploymentSetupSection(viewModel: viewModel, ruleSections: ruleSections)
        default:
            EmptyView()
        }
    }
}
