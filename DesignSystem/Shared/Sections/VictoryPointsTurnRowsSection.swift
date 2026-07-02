import SwiftUI
import TabletomeDomain

struct VictoryPointsTurnRowsSection: View {
    let round: Int
    let battleRound: Int
    let entry: RoundVictoryPoints
    let playerOneName: String
    let playerTwoName: String
    let turnIsComplete: ((Int, Bool) -> Bool)?
    let turnIsActive: ((Int, Bool) -> Bool)?
    let onSetRoundVictoryPoints: (Int, Bool, Int) -> Void

    private var isCurrentRound: Bool {
        round == battleRound
    }

    private var roundTotal: Int {
        entry.playerOne + entry.playerTwo
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            HStack(alignment: .firstTextBaseline) {
                Text(String(localized: "Round \(round)"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(isCurrentRound ? Color.accentColor : .secondary)
                if isCurrentRound {
                    Text(String(localized: "Now"))
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(Color.accentColor)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.accentColor.opacity(0.12), in: Capsule())
                }
                Spacer(minLength: 0)
                if roundTotal > 0 {
                    Text(String(localized: "+\(roundTotal)"))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
            }

            turnPlayerRow(
                name: playerOneName,
                value: entry.playerOne,
                isPlayerOne: true
            )
            turnPlayerRow(
                name: playerTwoName,
                value: entry.playerTwo,
                isPlayerOne: false
            )
        }
        .padding(DesignTokens.Spacing.sm)
        .background(
            isCurrentRound ? Color.accentColor.opacity(0.08) : Color(.tertiarySystemFill),
            in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm)
        )
    }

    private func turnPlayerRow(name: String, value: Int, isPlayerOne: Bool) -> some View {
        VictoryPointsTurnPlayerRowSection(
            name: name,
            value: value,
            round: round,
            isPlayerOne: isPlayerOne,
            isComplete: turnIsComplete?(round, isPlayerOne) ?? false,
            isActive: turnIsActive?(round, isPlayerOne) ?? false,
            onSetRoundVictoryPoints: onSetRoundVictoryPoints
        )
    }
}
