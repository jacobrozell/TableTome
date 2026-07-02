import SwiftUI

struct BattleTrackerPlayerSwitcher: View {
    let playerOneName: String
    let playerTwoName: String
    let activePlayerIsOne: Bool
    let label: String
    let onSelect: (Bool) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            Picker(label, selection: Binding(
                get: { activePlayerIsOne },
                set: { onSelect($0) }
            )) {
                Text(playerOneName).tag(true)
                Text(playerTwoName).tag(false)
            }
            .pickerStyle(.segmented)
            .accessibilityIdentifier("battleTracker.activePlayer")
        }
    }
}

extension BattleTrackerPlayerSwitcher {
    static func label(
        round: Int,
        playerOneVictoryPoints: Int,
        playerTwoVictoryPoints: Int,
        completedTurnsThisRound: Int = 0,
        roundOpenerIncomplete: Bool = false
    ) -> String {
        if roundOpenerIncomplete {
            return round == 1
                ? String(localized: "Attacker picks first turn")
                : String(localized: "Priority roll — pick first turn")
        }
        if round == 1, playerOneVictoryPoints == 0, playerTwoVictoryPoints == 0 {
            return String(localized: "Who goes first?")
        }
        if completedTurnsThisRound == 0 {
            return String(localized: "Active player · Turn 1 this round")
        }
        if completedTurnsThisRound == 1 {
            return String(localized: "Active player · Turn 2 this round")
        }
        return String(localized: "Active player")
    }
}
