import SwiftUI

struct BattleTrackerDamageUndoSection: View {
    let notice: DamageUndoNotice?
    let reduceMotion: Bool
    let onUndo: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        if let notice {
            BattleTrackerDamageUndoBanner(
                message: notice.message,
                onUndo: {
                    onUndo()
                    withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) {
                        onDismiss()
                    }
                },
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
