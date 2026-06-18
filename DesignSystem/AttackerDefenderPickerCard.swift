import SwiftUI

struct AttackerDefenderPickerCard: View {
    let playerOneName: String
    let playerTwoName: String
    let attackerIsPlayerOne: Bool?
    let onSelect: (Bool?) -> Void
    var accessibilityPrefix: String = "guidedMatch"

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            SectionHeader(title: String(localized: "Who is the attacker?"), systemImage: "flag.fill")

            Picker(String(localized: "Attacker"), selection: attackerBinding) {
                Text(String(localized: "Not decided")).tag(Optional<Bool>.none)
                Text(playerOneName).tag(Optional(true))
                Text(playerTwoName).tag(Optional(false))
            }
            .pickerStyle(.segmented)
            .accessibilityIdentifier("\(accessibilityPrefix).attackerPicker")

            if let isPlayerOne = attackerIsPlayerOne {
                let attacker = isPlayerOne ? playerOneName : playerTwoName
                let defender = isPlayerOne ? playerTwoName : playerOneName
                Text(
                    String(
                        localized: "\(attacker) attacks. \(defender) defends and chooses the realm side."
                    )
                )
                .font(.callout)
                .foregroundStyle(.secondary)
            }
        }
        .surfaceCard()
    }

    private var attackerBinding: Binding<Bool?> {
        Binding(
            get: { attackerIsPlayerOne },
            set: { onSelect($0) }
        )
    }
}
