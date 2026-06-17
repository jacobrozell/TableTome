import SwiftUI

struct DiceRollButton: View {
    let label: String
    let accessibilityId: String
    let action: () -> Void

    init(label: String, accessibilityId: String, action: @escaping () -> Void) {
        self.label = label
        self.accessibilityId = accessibilityId
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: "dice.fill")
                .font(.body.weight(.semibold))
                .frame(width: DesignTokens.minTouchTarget, height: DesignTokens.minTouchTarget)
        }
        .buttonStyle(.bordered)
        .accessibilityLabel(String(localized: "Roll \(label)"))
        .accessibilityHint(String(localized: "Simulates a six-sided die roll"))
        .accessibilityIdentifier(accessibilityId)
    }
}
