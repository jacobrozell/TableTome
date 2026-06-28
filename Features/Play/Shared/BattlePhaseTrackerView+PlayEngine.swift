import SwiftUI
import TabletomeDomain

extension BattlePhaseTrackerView {
    @ViewBuilder
    var engineDeploymentSection: some View {
        if viewModel.playContext.usesAlternatingActivation {
            alternatingActivationDeploymentSection
        } else {
            phasedRoundDeploymentSection
        }
    }

    @ViewBuilder
    var engineSecondarySections: some View {
        if viewModel.playContext.usesAlternatingActivation {
            alternatingActivationSecondarySections
        } else {
            phasedRoundSecondarySections
        }
        BattleTrackerReferenceLinksSection(
            ruleSections: ruleSections,
            gameSystemId: viewModel.gameSystemId
        )
    }
}
