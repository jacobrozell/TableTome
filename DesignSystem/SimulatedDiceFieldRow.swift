import SwiftUI
import TabletomeDomain

struct SimulatedDiceFieldRow: View {
    let label: String
    @Binding var value: Int
    let accessibilityId: String
    let rollAccessibilityId: String
    let isSimulated: Bool
    let onRoll: () -> Void

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            DiceValuePicker(label: label, value: $value, accessibilityId: accessibilityId)
            if isSimulated {
                DiceRollButton(label: label, accessibilityId: rollAccessibilityId, action: onRoll)
            }
        }
    }
}
