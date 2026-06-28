import SwiftUI

struct AttackerDefenderPickerCard: View {
    let playerOneName: String
    let playerTwoName: String
    let attackerIsPlayerOne: Bool?
    let onSelect: (Bool?) -> Void
    var title: String = String(localized: "Who is the attacker?")
    var decidedCaption: ((Bool) -> String)? = nil
    var accessibilityPrefix: String = "guidedMatch"

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            SectionHeader(title: title, systemImage: "flag.fill")

            Picker(String(localized: "Attacker"), selection: attackerBinding) {
                Text(String(localized: "Not decided")).tag(Optional<Bool>.none)
                Text(playerOneName).tag(Optional(true))
                Text(playerTwoName).tag(Optional(false))
            }
            .pickerStyle(.segmented)
            .accessibilityIdentifier("\(accessibilityPrefix).attackerPicker")

            if let isPlayerOne = attackerIsPlayerOne {
                let caption = decidedCaption?(isPlayerOne) ?? defaultCaption(isPlayerOne: isPlayerOne)
                Text(caption)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
        .surfaceCard()
    }

    private func defaultCaption(isPlayerOne: Bool) -> String {
        let attacker = isPlayerOne ? playerOneName : playerTwoName
        let defender = isPlayerOne ? playerTwoName : playerOneName
        return String(
            localized: "\(attacker) attacks. \(defender) defends and chooses the realm side."
        )
    }

    private var attackerBinding: Binding<Bool?> {
        Binding(
            get: { attackerIsPlayerOne },
            set: { onSelect($0) }
        )
    }
}
