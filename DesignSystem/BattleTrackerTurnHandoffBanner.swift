import SwiftUI

struct BattleTrackerTurnHandoffBanner: View {
    let title: String
    let detail: String
    let onDismiss: () -> Void

    var body: some View {
        BattleTrackerNoticeBanner(
            systemImage: "arrow.left.arrow.right.circle.fill",
            title: title,
            detail: detail,
            onDismiss: onDismiss,
            accessibilityIdentifier: "battleTracker.turnHandoff"
        )
    }
}
