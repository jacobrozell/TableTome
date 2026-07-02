import SwiftUI
import TabletomeDomain

struct BattleTrackerPhaseActionNudgeSection: View {
    let notice: PhaseActionNudgeNotice?
    let reduceMotion: Bool
    let onDismiss: () -> Void

    var body: some View {
        if let notice {
            BattleTrackerPhaseActionBanner(
                phaseTitle: notice.title,
                message: notice.message,
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
