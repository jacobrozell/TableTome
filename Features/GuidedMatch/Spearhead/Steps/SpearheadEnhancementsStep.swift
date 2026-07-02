import SwiftUI
import TabletomeDomain

struct SpearheadEnhancementsStep: View {
    @ObservedObject var viewModel: GuidedMatchViewModel
    let parts: GuidedMatchStepParts

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            parts.enhancementCoachingCallout()
            parts.recommendedDefaultsControls()
            parts.armyOptionsSection(
                title: String(localized: "Enhancements"),
                playerOneKeyPath: \.enhancementId,
                playerTwoKeyPath: \.enhancementId,
                options: { army in army.enhancements },
                onSelect: viewModel.setEnhancement
            )
            parts.spearheadBattleTacticsSection()
            if viewModel.eitherArmyHasSecondaryObjectives {
                parts.armyOptionsSection(
                    title: String(localized: "Secondary Objectives"),
                    playerOneKeyPath: \.secondaryObjectiveId,
                    playerTwoKeyPath: \.secondaryObjectiveId,
                    options: { army in army.secondaryObjectives },
                    onSelect: viewModel.setSecondaryObjective
                )
            }
            parts.loadoutSummarySection(
                showRegiment: true,
                showEnhancement: true,
                showSecondary: viewModel.eitherArmyHasSecondaryObjectives
            )
        }
    }
}
