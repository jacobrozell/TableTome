import SwiftUI
import TabletomeDomain

/// Always-visible round 1 control — correct who goes first without End of Turn or consuming a turn.
struct SpearheadRoundOneFirstTurnCard: View {
    let playerOneName: String
    let playerTwoName: String
    let attackerName: String?
    let firstTurnIsPlayerOne: Bool?
    let onSelect: (Bool) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Label(String(localized: "Who goes first?"), systemImage: "arrow.triangle.2.circlepath")
                .font(.headline)

            Text(
                String(
                    localized: """
                    Pick who takes the first turn in round 1. You can change this anytime — it does not pass a turn \
                    or require End of Turn.
                    """
                )
            )
            .font(.callout)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)

            if let attackerName {
                Text(String(localized: "\(attackerName) (attacker) usually chooses who goes first."))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Picker(String(localized: "First turn"), selection: binding) {
                Text(playerOneName).tag(Optional(true))
                Text(playerTwoName).tag(Optional(false))
            }
            .pickerStyle(.segmented)
            .accessibilityIdentifier("battleTracker.roundOneFirstTurn")
        }
        .accentHighlightCard()
    }

    private var binding: Binding<Bool> {
        Binding(
            get: { firstTurnIsPlayerOne ?? true },
            set: { onSelect($0) }
        )
    }
}
