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
            Text(title)
                .font(TTFont.headline)
                .foregroundStyle(TTColor.inkPrimary)

            HStack(spacing: DesignTokens.Spacing.sm) {
                playerButton(isPlayerOne: true, name: playerOneName)
                playerButton(isPlayerOne: false, name: playerTwoName)
            }
            .accessibilityIdentifier("\(accessibilityPrefix).attackerPicker")

            if let isPlayerOne = attackerIsPlayerOne {
                let caption = decidedCaption?(isPlayerOne) ?? defaultCaption(isPlayerOne: isPlayerOne)
                Text(caption)
                    .font(TTFont.footnote)
                    .foregroundStyle(TTColor.inkSecondary)
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

    @ViewBuilder
    private func playerButton(isPlayerOne: Bool, name: String) -> some View {
        let selected = attackerIsPlayerOne == isPlayerOne
        let label = isPlayerOne ? "1  \(name)" : "2  \(name)"
        if selected {
            Button(label) { onSelect(isPlayerOne) }
                .buttonStyle(.ttPlayer(isPlayerOne: isPlayerOne))
                .accessibilityAddTraits(.isSelected)
        } else {
            Button(label) { onSelect(isPlayerOne) }
                .buttonStyle(.ttSecondary)
        }
    }
}
