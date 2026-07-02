import SwiftUI
import TabletomeDomain
import TabletomeData

extension GuidedMatchView {
    func useStarterMatchup(navigateToSetup: Bool = true) {
        let box = spearheadBoxSets.first { $0.id == selectedSpearheadBoxId } ?? spearheadBoxSets.first
        viewModel.applyStarterMatchup(boxSet: box)
        showsStarterMatchupHandoff = true
        dismissedStarterMatchupHandoff = false
        if usesPadSplitNavigation {
            selectedDestination = spearheadPadDetailDestination ?? .battleTracker
        } else if navigateToSetup {
            hubTab = .setup
        }
    }
}
