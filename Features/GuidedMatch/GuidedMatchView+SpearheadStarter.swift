import SwiftUI
import TabletomeDomain
import TabletomeData

extension GuidedMatchView {
    func useStarterMatchup(navigateToSetup: Bool = true) {
        let box = spearheadBoxSets.first { $0.id == selectedSpearheadBoxId } ?? spearheadBoxSets.first
        viewModel.applyStarterMatchup(boxSet: box, household: householdPlayers)
        showsStarterMatchupHandoff = true
        dismissedStarterMatchupHandoff = false
        let note = viewModel.starterMatchupProfileNote
        banners.show(
            BannerItem(
                id: "guidedMatch.starterLoaded",
                message: note ?? String(localized: "Starter matchup loaded"),
                systemImage: "checkmark.circle.fill",
                tone: .success,
                actionTitle: String(localized: "Setup"),
                action: { hubTab = .setup }
            )
        )
        if usesPadSplitNavigation {
            selectedDestination = spearheadPadDetailDestination ?? .battleTracker
        } else if navigateToSetup {
            hubTab = .setup
        }
    }
}
