import SwiftUI
import TabletomeDomain

struct BattleTrackerReinforcementCallBannerSection: View {
    let prompt: ReinforcementCallPrompt?
    let onDismiss: () -> Void

    var body: some View {
        if let prompt {
            BattleTrackerReinforcementCallBanner(
                prompt: prompt,
                onDismiss: onDismiss
            )
            .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }
}
