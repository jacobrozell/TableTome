import SwiftUI

struct BattleTrackerPhaseActionBanner: View {
    let phaseTitle: String
    let message: String
    let onDismiss: () -> Void

    var body: some View {
        BattleTrackerNoticeBanner(
            systemImage: "hand.point.up.left.fill",
            title: phaseTitle,
            detail: message,
            onDismiss: onDismiss,
            accessibilityIdentifier: "battleTracker.phaseActionNudge"
        )
    }
}
