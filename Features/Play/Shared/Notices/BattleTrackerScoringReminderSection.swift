import SwiftUI
import TabletomeDomain

struct BattleTrackerScoringReminderSection: View {
    let notice: ScoringReminderNotice?
    let gameSystemId: GameSystemId
    let reduceMotion: Bool
    let onJumpToScoring: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        if let notice {
            BattleTrackerScoringReminderBanner(
                playerName: notice.playerName,
                gameSystemId: gameSystemId,
                onJumpToScoring: onJumpToScoring,
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
