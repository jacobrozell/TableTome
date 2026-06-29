import SwiftUI
import TabletomeDomain

extension BattlePhaseTrackerView {
    func focusCombatResolverSection() {
        let targetTab: BattleTrackerSectionTab = viewModel.playContext.capabilities.showsDedicatedCombatTab
            ? .combat
            : .turn
        if selectedSectionTab == targetTab {
            scrollToCombatResolver = true
        } else {
            selectedSectionTab = targetTab
            pendingCombatResolverScroll = true
        }
    }
}
