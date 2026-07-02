import SwiftUI
import TabletomeDomain

struct BattleTrackerCoachSection: View {
    let gameSystemId: GameSystemId
    let isVisible: Bool
    let reduceMotion: Bool
    let onDismiss: () -> Void

    var body: some View {
        if isVisible {
            BattleTrackerCoachCard(gameSystemId: gameSystemId) {
                withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) {
                    onDismiss()
                }
            }
            .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }
}
