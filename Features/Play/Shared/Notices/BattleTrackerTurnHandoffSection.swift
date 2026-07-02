import SwiftUI

struct BattleTrackerTurnHandoffSection: View {
    let notice: TurnHandoffNotice?
    let reduceMotion: Bool
    let onDismiss: () -> Void

    var body: some View {
        if let notice {
            BattleTrackerTurnHandoffBanner(
                title: notice.title,
                detail: notice.detail,
                onDismiss: {
                    withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) {
                        onDismiss()
                    }
                }
            )
            .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }
}
