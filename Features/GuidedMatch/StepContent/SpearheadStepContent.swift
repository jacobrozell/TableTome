import SwiftUI
import TabletomeDomain

/// Spearhead setup steps route through the dedicated step router.
struct SpearheadStepContent: View {
    let step: MatchSetupStep
    @ObservedObject var viewModel: GuidedMatchViewModel
    let ruleSections: [RuleSection]
    let usesSideBySideColumns: Bool

    var body: some View {
        SpearheadMatchStepRouter(
            step: step,
            viewModel: viewModel,
            ruleSections: ruleSections,
            usesSideBySideColumns: usesSideBySideColumns
        )
    }
}
