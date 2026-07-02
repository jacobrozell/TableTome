import SwiftUI
import TabletomeDomain

struct DiceCoachingHint: View {
    let hint: DiceRollCoach.Hint

    var body: some View {
        Text(hint.text)
            .font(.caption)
            .foregroundStyle(hint.passed ? .green : .orange)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityLabel(hint.text)
    }
}
