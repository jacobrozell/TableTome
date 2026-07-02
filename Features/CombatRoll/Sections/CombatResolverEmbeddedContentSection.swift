import SwiftUI
import TabletomeDomain

struct CombatResolverEmbeddedContentSection: View {
    @ObservedObject var viewModel: UnitMatchupEvaluatorViewModel
    @ObservedObject var multiAttackViewModel: MultiAttackEvaluatorViewModel
    @ObservedObject var batchViewModel: BatchCombatEvaluatorViewModel
    @Binding var showsCombatSequencePrimer: Bool
    @Binding var showsAdvancedSingleAttack: Bool
    @Binding var showsMultiAttack: Bool
    @Binding var showsAdvancedOptions: Bool
    @Binding var diceInputModeRaw: String
    let showsDiceInputMode: Bool
    let ruleSections: [RuleSection]
    let panelSpacing: CGFloat
    let isEmbedded: Bool
    let isSimulated: Bool
    let accessibilityPrefix: String
    let attackerPlayerName: String?
    let defenderPlayerName: String?
    let unitWoundsRemaining: [String: Int]
    let defenderWoundsRemaining: Int?
    let onSyncMultiAttack: () -> Void
    var onApplyDamage: ((Int, CombatBatchLogContext?) -> Void)?

    var body: some View {
        Group {
            if viewModel.canEvaluate {
                CombatResolverAttackContextCard(
                    viewModel: viewModel,
                    attackerPlayerName: attackerPlayerName,
                    defenderPlayerName: defenderPlayerName,
                    unitWoundsRemaining: unitWoundsRemaining,
                    defenderWoundsRemaining: defenderWoundsRemaining,
                    accessibilityPrefix: accessibilityPrefix
                )
                CombatResolverDeployedModelSection(
                    viewModel: viewModel,
                    accessibilityPrefix: accessibilityPrefix,
                    onSyncMultiAttack: onSyncMultiAttack
                )
                CombatResolverHitDiceBannerSection(
                    viewModel: viewModel,
                    accessibilityPrefix: accessibilityPrefix,
                    onSyncMultiAttack: onSyncMultiAttack
                )
                CombatResolverCombatSequencePrimerSection(
                    isExpanded: $showsCombatSequencePrimer,
                    gameSystemId: viewModel.gameSystemId
                )
                if !isSimulated {
                    CombatResolverBatchCombatSection(
                        batchViewModel: batchViewModel,
                        combatViewModel: viewModel,
                        accessibilityPrefix: accessibilityPrefix,
                        defenderWoundsRemaining: defenderWoundsRemaining,
                        onApplyDamage: onApplyDamage
                    )
                }
            } else {
                CombatResolverSetupGate(
                    hasAttacker: viewModel.selectedAttackerUnit != nil,
                    hasDefender: viewModel.selectedDefenderUnit != nil,
                    hasWeapon: viewModel.selectedAttackerWeapon?.isRollEvaluable == true,
                    accessibilityPrefix: accessibilityPrefix
                )
                CombatResolverCombatSequencePrimerSection(
                    isExpanded: $showsCombatSequencePrimer,
                    gameSystemId: viewModel.gameSystemId
                )
            }
            CombatResolverAdvancedSingleAttackSection(
                viewModel: viewModel,
                multiAttackViewModel: multiAttackViewModel,
                showsAdvancedSingleAttack: $showsAdvancedSingleAttack,
                showsMultiAttack: $showsMultiAttack,
                ruleSections: ruleSections,
                panelSpacing: panelSpacing,
                isEmbedded: isEmbedded,
                isSimulated: isSimulated,
                accessibilityPrefix: accessibilityPrefix,
                defenderWoundsRemaining: defenderWoundsRemaining,
                onApplyDamage: onApplyDamage
            )
            CombatResolverWardReminderSection(
                viewModel: viewModel,
                showsAdvancedOptions: $showsAdvancedOptions
            )
            CombatResolverOptionsSection(
                viewModel: viewModel,
                showsAdvancedOptions: $showsAdvancedOptions,
                diceInputModeRaw: $diceInputModeRaw,
                showsDiceInputMode: showsDiceInputMode,
                isEmbedded: isEmbedded,
                accessibilityPrefix: accessibilityPrefix
            )
        }
    }
}
