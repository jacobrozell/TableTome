import SwiftUI
import TabletomeDomain

struct CombatResolverBatchCombatSection: View {
    @ObservedObject var batchViewModel: BatchCombatEvaluatorViewModel
    @ObservedObject var combatViewModel: UnitMatchupEvaluatorViewModel
    let accessibilityPrefix: String
    var defenderWoundsRemaining: Int?
    var onApplyDamage: ((Int, CombatBatchLogContext?) -> Void)?

    var body: some View {
        BatchCombatResolverSection(
            batchViewModel: batchViewModel,
            combatViewModel: combatViewModel,
            accessibilityPrefix: accessibilityPrefix,
            defenderName: combatViewModel.selectedDefenderUnit?.name,
            defenderWoundsRemaining: defenderWoundsRemaining,
            onApplyDamage: onApplyDamage
        )
    }
}
