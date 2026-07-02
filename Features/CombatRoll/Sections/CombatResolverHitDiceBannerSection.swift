import SwiftUI
import TabletomeDomain

struct CombatResolverHitDiceBannerSection: View {
    @ObservedObject var viewModel: UnitMatchupEvaluatorViewModel
    let accessibilityPrefix: String
    let onSyncMultiAttack: () -> Void

    var body: some View {
        if viewModel.selectedAttackerWeapon?.hasCritAutoWound == true,
           !CombatRollEngineRouter.usesWh40kRules(gameSystemId: viewModel.gameSystemId) {
            CritAutoWoundCoachingHint()
        }
        if viewModel.attackerUsesVariableAttacks {
            VariableAttacksRollCard(
                expression: viewModel.selectedAttackerWeapon?.attacks ?? "D6",
                modelCount: viewModel.attackerDeployedModelCount,
                perModelTotals: viewModel.variableAttackPerModelTotals,
                resolvedAttackCount: $viewModel.resolvedVariableAttackCount,
                breakdown: viewModel.variableAttackRollBreakdown,
                onRollAll: {
                    viewModel.rollVariableAttacks()
                    onSyncMultiAttack()
                },
                onRollNextModel: {
                    viewModel.rollVariableAttacksForNextModel()
                    onSyncMultiAttack()
                },
                accessibilityPrefix: accessibilityPrefix
            )
        }
        if let plan = viewModel.attackerHitDicePlan {
            CombatRollCountBanner(
                plan: plan,
                accessibilityPrefix: accessibilityPrefix
            )
        }
    }
}
