import SwiftUI
import TabletomeDomain
import TabletomeData

struct BattleTrackerContentSection: View {
    @ObservedObject var viewModel: BattlePhaseTrackerViewModel
    let ruleSections: [RuleSection]
    let supportsBattleTracker: Bool
    let showsActivationBar: Bool
    let usesGuidedBattleTracker: Bool
    let showsEmbeddedCombatTools: Bool
    let onResolveAttack: (TriggeredAbility) -> Void

    var body: some View {
        if !supportsBattleTracker {
            BattleTrackerEmptyStateSection(
                showsActivationBar: showsActivationBar,
                usesGuidedBattleTracker: usesGuidedBattleTracker
            )
        } else if showsActivationBar {
            BattleTrackerSCTrackerPlaceholderSection()
        } else {
            BattleTrackerAbilitySections(
                viewModel: viewModel,
                ruleSections: ruleSections,
                showsEmbeddedCombatTools: showsEmbeddedCombatTools,
                onResolveAttack: onResolveAttack
            )
        }
    }
}
