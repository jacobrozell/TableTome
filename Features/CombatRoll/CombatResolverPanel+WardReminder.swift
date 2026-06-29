import SwiftUI
import TabletomeDomain

extension CombatResolverPanel {
    var usesWh40kRules: Bool {
        CombatRollEngineRouter.usesWh40kRules(gameSystemId: viewModel.gameSystemId)
    }

    /// The protective value already applied for the defender (Ward in AoS, Invulnerable in 40k).
    /// When non-nil the reminder stays hidden so we never nag players about rules already handled.
    var activeProtection: Int? {
        usesWh40kRules ? viewModel.activeInvulnTarget : viewModel.activeWardTarget
    }

    @ViewBuilder
    var wardReminderSection: some View {
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
