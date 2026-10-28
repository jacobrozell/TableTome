import SwiftUI
import TabletomeDomain

struct DiceCoachingHint: View {
    let hint: DiceRollCoach.Hint
    @State private var dismissed = false

    var body: some View {
        if !dismissed {
            TTNotice(
                title: String(localized: "Dice"),
                message: hint.text,
                systemImage: hint.passed ? "checkmark.circle" : "dice",
                tone: hint.passed ? .success : .brand,
                onDismiss: { dismissed = true }
            )
            .accessibilityLabel(hint.text)
        }
    }
}
