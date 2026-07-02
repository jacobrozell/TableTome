import SwiftUI
import TabletomeDomain

struct CombatResolverSimulatedActionsSection: View {
    @ObservedObject var viewModel: UnitMatchupEvaluatorViewModel
    let isSimulated: Bool
    let accessibilityPrefix: String

    var body: some View {
        if isSimulated {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                SimulatedDiceHint()
                SimulatedRollSummaryView(rolls: viewModel.lastRolls)
                PrimaryButton(
                    title: String(localized: "Roll Attack"),
                    accessibilityId: "\(accessibilityPrefix).roll.attack"
                ) {
                    viewModel.rollAttack()
                }
            }
            .surfaceCard()
        }
    }
}
