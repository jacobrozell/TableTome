import SwiftUI

/// Segmented picker for a single D6 result (1–6).
struct DiceValuePicker: View {
    let label: String
    @Binding var value: Int
    let accessibilityId: String

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Text(label)
                .font(.subheadline.weight(.medium))
            Picker(label, selection: $value) {
                ForEach(1...6, id: \.self) { face in
                    Text("\(face)").tag(face)
                }
            }
            .pickerStyle(.segmented)
            .accessibilityIdentifier(accessibilityId)
        }
    }
}
