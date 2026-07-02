import SwiftUI

struct BattleTrackerRoundOpenerNoticeSection: View {
    let notice: RoundOpenerNotice?
    let reduceMotion: Bool
    let onJumpToChecklist: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        if let notice {
            BattleTrackerRoundOpenerBanner(
                round: notice.round,
                nextStepTitle: notice.nextStepTitle,
                onJumpToChecklist: onJumpToChecklist,
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
