import SwiftUI
import TabletomeDomain

struct CombatResolverPanelDiceSection: View {
    @ObservedObject var viewModel: UnitMatchupEvaluatorViewModel
    let isEmbedded: Bool
    let isSimulated: Bool
    let accessibilityPrefix: String

    var body: some View {
        CombatResolverDiceSection(
            viewModel: viewModel,
            isEmbedded: isEmbedded,
            isSimulated: isSimulated,
            accessibilityPrefix: accessibilityPrefix
        )
    }
}
