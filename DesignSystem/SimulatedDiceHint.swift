import SwiftUI

struct SimulatedDiceHint: View {
    var body: some View {
        Text(
            "Roll Attack simulates each die in order. "
                + "Use the dice buttons beside a field to re-roll just that die."
        )
        .font(.caption)
        .foregroundStyle(.secondary)
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityIdentifier("diceRoller.simulatedHint")
    }
}
