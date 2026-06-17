import SwiftUI
import TabletomeDomain

struct DiceInputModePicker: View {
  @Binding var mode: DiceInputMode

  var body: some View {
    Picker(String(localized: "Dice input"), selection: $mode) {
      Text(String(localized: "Physical dice")).tag(DiceInputMode.physical)
      Text(String(localized: "Roll in app")).tag(DiceInputMode.simulated)
    }
    .pickerStyle(.segmented)
    .accessibilityIdentifier("diceRoller.inputMode")
    .accessibilityHint(String(localized: "Choose physical dice or simulated rolls"))
  }
}
