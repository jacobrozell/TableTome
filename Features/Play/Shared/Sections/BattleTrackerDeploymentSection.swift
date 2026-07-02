import SwiftUI
import TabletomeDomain

struct BattleTrackerDeploymentSection<DeploymentContent: View>: View {
    let battleRound: Int
    let deploymentIsComplete: Bool
    @Binding var showsDeploymentSetup: Bool
    @ViewBuilder let deploymentContent: () -> DeploymentContent

    var body: some View {
        if battleRound == 1 {
            DisclosureGroup(isExpanded: $showsDeploymentSetup) {
                deploymentContent()
            } label: {
                Label(String(localized: "Battlefield setup"), systemImage: "map")
                    .font(.headline)
            }
            .surfaceCard()
            .onAppear {
                showsDeploymentSetup = !deploymentIsComplete
            }
        }
    }
}
