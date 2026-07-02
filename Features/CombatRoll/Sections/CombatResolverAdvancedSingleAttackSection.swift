import SwiftUI
import TabletomeDomain

struct CombatResolverAdvancedSingleAttackSection: View {
    @ObservedObject var viewModel: UnitMatchupEvaluatorViewModel
    @ObservedObject var multiAttackViewModel: MultiAttackEvaluatorViewModel
    @Binding var showsAdvancedSingleAttack: Bool
    @Binding var showsMultiAttack: Bool
    let ruleSections: [RuleSection]
    let panelSpacing: CGFloat
    let isEmbedded: Bool
    let isSimulated: Bool
    let accessibilityPrefix: String
    var defenderWoundsRemaining: Int?
    var onApplyDamage: ((Int, CombatBatchLogContext?) -> Void)?

    var body: some View {
        DisclosureGroup(isExpanded: $showsAdvancedSingleAttack) {
            VStack(alignment: .leading, spacing: panelSpacing) {
                CombatResolverPanelDiceSection(
                    viewModel: viewModel,
                    isEmbedded: isEmbedded,
                    isSimulated: isSimulated,
                    accessibilityPrefix: accessibilityPrefix
                )
                CombatResolverPanelResultsSection(
                    viewModel: viewModel,
                    isEmbedded: isEmbedded,
                    accessibilityPrefix: accessibilityPrefix,
                    defenderWoundsRemaining: defenderWoundsRemaining,
                    onApplyDamage: onApplyDamage
                )
                CombatResolverSimulatedActionsSection(
                    viewModel: viewModel,
                    isSimulated: isSimulated,
                    accessibilityPrefix: accessibilityPrefix
                )
                CombatResolverMultiAttackSection(
                    viewModel: viewModel,
                    multiAttackViewModel: multiAttackViewModel,
                    showsMultiAttack: $showsMultiAttack,
                    ruleSections: ruleSections,
                    isEmbedded: isEmbedded,
                    isSimulated: isSimulated
                )
            }
            .padding(.top, DesignTokens.Spacing.sm)
        } label: {
            Text(String(localized: "Single attack & coaching"))
                .font(.subheadline.weight(.semibold))
        }
    }
}
