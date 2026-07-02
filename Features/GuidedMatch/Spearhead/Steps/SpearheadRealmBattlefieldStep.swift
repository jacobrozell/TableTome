import SwiftUI
import TabletomeDomain

struct SpearheadRealmBattlefieldStep: View {
    @ObservedObject var viewModel: GuidedMatchViewModel
    let ruleSections: [RuleSection]

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            DeploymentZoneCallout(gameSystemId: viewModel.gameSystemId)
            SpearheadDeploymentGotchasSection(viewModel: viewModel)
            SpearheadDeploymentAbilitiesSection(viewModel: viewModel, ruleSections: ruleSections)
            RealmSideCoinFlipCard()
            DeploymentChecklistCard(
                completedSteps: viewModel.deploymentCompletedSteps,
                focusedStep: BattleFlowGuide.nextIncompleteDeploymentStep(
                    in: viewModel.deploymentCompletedSteps
                ),
                onToggle: viewModel.setDeploymentStep
            )
            ReferenceLinksGroup {
                NavigationLink(value: BattleTacticsReferenceLink(gameSystemId: viewModel.gameSystemId.rawValue)) {
                    ReferenceLinkRow(
                        title: String(localized: "Card Decks Guide"),
                        systemImage: "rectangle.stack"
                    )
                }
            }
        }
    }
}
