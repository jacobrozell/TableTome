import SwiftUI
import TabletomeDomain

struct BattleTrackerVictoryPointsTabSection: View {
    @ObservedObject var viewModel: BattlePhaseTrackerViewModel
    let isVisible: Bool

    var body: some View {
        if isVisible {
            BattleTrackerVictoryPointsSection(viewModel: viewModel)
        }
    }
}
