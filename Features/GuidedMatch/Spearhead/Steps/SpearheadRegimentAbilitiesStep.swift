import SwiftUI
import TabletomeDomain

struct SpearheadRegimentAbilitiesStep: View {
    @ObservedObject var viewModel: GuidedMatchViewModel
    let parts: GuidedMatchStepParts

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            parts.regimentAbilityCoachingCallout()
            parts.armyOptionsSection(
                title: String(localized: "Regiment ability (pick one army rule)"),
                playerOneKeyPath: \.regimentAbilityId,
                playerTwoKeyPath: \.regimentAbilityId,
                options: { army in army.regimentAbilities },
                onSelect: viewModel.setRegimentAbility
            )
            parts.loadoutSummarySection(showRegiment: true, showEnhancement: false)
        }
    }
}
