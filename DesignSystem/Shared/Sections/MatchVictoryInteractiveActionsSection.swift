import SwiftUI

struct MatchVictoryInteractiveActionsSection: View {
    let onAdjustScore: () -> Void
    let onRematch: () -> Void
    let onDone: () -> Void

    var body: some View {
        Button(String(localized: "Rematch"), action: onRematch)
            .buttonStyle(.ttPrimary)
            .accessibilityIdentifier("matchVictory.rematch")
        Button(String(localized: "Save & Finish"), action: onDone)
            .buttonStyle(.ttSecondary)
            .accessibilityIdentifier("matchVictory.done")
        Button(String(localized: "Adjust final score"), action: onAdjustScore)
            .buttonStyle(.ttTertiary)
            .accessibilityIdentifier("matchVictory.adjustScore")
    }
}
