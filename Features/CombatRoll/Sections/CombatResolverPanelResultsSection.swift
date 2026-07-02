import SwiftUI
import TabletomeDomain

struct CombatResolverPanelResultsSection: View {
    @ObservedObject var viewModel: UnitMatchupEvaluatorViewModel
    let isEmbedded: Bool
    let accessibilityPrefix: String
    var defenderWoundsRemaining: Int?
    var onApplyDamage: ((Int, CombatBatchLogContext?) -> Void)?

    var body: some View {
        CombatResolverResultsSection(
            viewModel: viewModel,
            isEmbedded: isEmbedded,
            accessibilityPrefix: accessibilityPrefix,
            defenderWoundsRemaining: defenderWoundsRemaining,
            onApplyDamage: onApplyDamage
        )
    }
}
