import SwiftUI

struct BattleTrackerHeroRoundOneSection: View {
    let isVisible: Bool
    let onDismiss: () -> Void

    var body: some View {
        if isVisible {
            HeroPhaseRoundOneBanner(onDismiss: onDismiss)
                .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }
}
