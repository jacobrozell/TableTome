import SwiftUI
import TabletomeDomain

/// Routes Spearhead setup step ids to dedicated step views (§15 module).
struct SpearheadMatchStepRouter: View {
    let step: MatchSetupStep
    @ObservedObject var viewModel: GuidedMatchViewModel
    let ruleSections: [RuleSection]
    let usesSideBySideColumns: Bool

    private var parts: GuidedMatchStepParts {
        GuidedMatchStepParts(
            viewModel: viewModel,
            ruleSections: ruleSections,
            usesSideBySideColumns: usesSideBySideColumns
        )
    }

    var body: some View {
        switch step.id {
        case "choose-armies":
            SpearheadChooseArmiesStep(viewModel: viewModel)
        case "roll-attacker":
            SpearheadRollAttackerStep(viewModel: viewModel)
        case "pre-battle-loadout":
            SpearheadPreBattleLoadoutStep(viewModel: viewModel, parts: parts, ruleSections: ruleSections)
        case "realm-battlefield":
            SpearheadRealmBattlefieldStep(viewModel: viewModel, ruleSections: ruleSections)
        case "fight-battle":
            SpearheadFightBattleStep(gameSystemId: viewModel.gameSystemId)
        default:
            EmptyView()
        }
    }
}
