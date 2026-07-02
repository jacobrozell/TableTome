import SwiftUI
import TabletomeDomain

struct CombatResolverWardReminderSection: View {
    @ObservedObject var viewModel: UnitMatchupEvaluatorViewModel
    @Binding var showsAdvancedOptions: Bool

    private var usesWh40kRules: Bool {
        CombatRollEngineRouter.usesWh40kRules(gameSystemId: viewModel.gameSystemId)
    }

    private var activeProtection: Int? {
        usesWh40kRules ? viewModel.activeInvulnTarget : viewModel.activeWardTarget
    }

    var body: some View {
        if viewModel.canEvaluate, activeProtection == nil, !showsAdvancedOptions {
            CombatWardReminderHint(
                keyword: usesWh40kRules
                    ? String(localized: "Invulnerable save")
                    : String(localized: "Ward"),
                example: usesWh40kRules
                    ? String(localized: "Invulnerable 4+")
                    : String(localized: "Ward (5+)")
            ) {
                withAnimation(.easeInOut(duration: 0.25)) {
                    showsAdvancedOptions = true
                }
            }
        }
    }
}
