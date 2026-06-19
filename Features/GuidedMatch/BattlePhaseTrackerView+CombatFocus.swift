import SwiftUI
import TabletomeDomain

extension BattlePhaseTrackerView {
    func focusCombatResolverSection() {
        if viewModel.playContext.capabilities.showsDedicatedCombatTab {
            selectedSectionTab = .combat
        } else {
            selectedSectionTab = .turn
        }
        scrollToCombatResolver = true
    }
}
