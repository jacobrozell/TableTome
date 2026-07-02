import SwiftUI
import TabletomeDomain

struct VictoryPointsPerTurnBreakdownSection: View {
    @Binding var showsPerTurnDetails: Bool
    let visibleRounds: [Int]
    let battleRound: Int
    let victoryPointsByRound: [Int: RoundVictoryPoints]
    let playerOneName: String
    let playerTwoName: String
    let turnIsComplete: ((Int, Bool) -> Bool)?
    let turnIsActive: ((Int, Bool) -> Bool)?
    let onSetRoundVictoryPoints: (Int, Bool, Int) -> Void

    var body: some View {
        DisclosureGroup(isExpanded: $showsPerTurnDetails) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                ForEach(visibleRounds, id: \.self) { round in
                    VictoryPointsTurnRowsSection(
                        round: round,
                        battleRound: battleRound,
                        entry: victoryPointsByRound[round] ?? RoundVictoryPoints(),
                        playerOneName: playerOneName,
                        playerTwoName: playerTwoName,
                        turnIsComplete: turnIsComplete,
                        turnIsActive: turnIsActive,
                        onSetRoundVictoryPoints: onSetRoundVictoryPoints
                    )
                }
            }
            .padding(.top, DesignTokens.Spacing.xs)
        } label: {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                SectionHeader(title: String(localized: "Score by turn"), systemImage: "list.number")
                Text(
                    String(
                        localized: "Use the steppers on each row to match what you scored that round at the table."
                    )
                )
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
