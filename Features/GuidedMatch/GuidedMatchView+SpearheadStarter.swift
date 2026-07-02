import SwiftUI
import TabletomeDomain
import TabletomeData

extension GuidedMatchView {
    @ViewBuilder
    var starterMatchupHandoffSection: some View {
        if showsStarterMatchupHandoff,
           !dismissedStarterMatchupHandoff,
           let summary = viewModel.matchupSummary {
            Section {
                StarterMatchupHandoffBanner(
                    matchupSummary: summary,
                    nextStepTitle: viewModel.nextIncompleteStep?.title,
                    attackerLabel: spearheadAttackerLabel,
                    usesSpearheadCopy: gameSystemId == .aosSpearhead
                ) {
                    dismissedStarterMatchupHandoff = true
                    showsStarterMatchupHandoff = false
                }
                .listHeroCardRow()
            }
        }
    }

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
