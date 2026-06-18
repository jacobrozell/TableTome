import SwiftUI
import TabletomeDomain

extension BattlePhaseTrackerView {
    /// Wh40k battle trackers embed the resolver on the Turn tab — Spearhead uses Combat.
    func focusCombatResolverSection() {
        if viewModel.playContext.usesGuidedBattleTracker {
            selectedSectionTab = .turn
        } else {
            selectedSectionTab = .combat
        }
        scrollToCombatResolver = true
    }
}
