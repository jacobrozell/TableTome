import SwiftUI
import TabletomeDomain

extension DiceInputMode: Identifiable {
    public var id: String { rawValue }
}

struct DiceInputModePicker: View {
    @Binding var mode: DiceInputMode

    var body: some View {
        TTSegmentedControl(
            selection: $mode,
            options: Array(DiceInputMode.allCases),
            title: { diceTitle($0) },
            systemImage: { $0 == .physical ? "hand.raised" : "dice" }
        )
        .accessibilityIdentifier("diceRoller.inputMode")
        .accessibilityHint(String(localized: "Choose physical dice or simulated rolls"))
    }

    private func diceTitle(_ mode: DiceInputMode) -> String {
        switch mode {
        case .physical: String(localized: "Real dice")
        case .simulated: String(localized: "Roll in app")
        }
    }
}
