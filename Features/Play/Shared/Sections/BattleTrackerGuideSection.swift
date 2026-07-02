import SwiftUI
import TabletomeDomain

struct BattleTrackerGuideSection: View {
    let step: BattleFlowGuideStep?
    let isVisible: Bool
    let onComplete: () -> Void
    let onBattleComplete: () -> Void

    var body: some View {
        if isVisible, let step {
            BattleGuideCard(step: step) {
                if step.kind == .battleComplete {
                    onBattleComplete()
                } else {
                    onComplete()
                }
            }
            .accessibilityIdentifier("battleGuide.section")
        }
    }
}
