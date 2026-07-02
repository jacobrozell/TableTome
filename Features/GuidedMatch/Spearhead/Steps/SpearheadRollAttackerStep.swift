import SwiftUI
import TabletomeDomain

struct SpearheadRollAttackerStep: View {
    @ObservedObject var viewModel: GuidedMatchViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            AttackerDefenderPickerCard(
                playerOneName: viewModel.matchState.playerOne.playerName,
                playerTwoName: viewModel.matchState.playerTwo.playerName,
                attackerIsPlayerOne: viewModel.matchState.attackerIsPlayerOne,
                onSelect: viewModel.setAttacker
            )
            Text(
                String(
                    localized: """
                    Attacker picks regiment abilities and enhancements first; defender picks board side. \
                    Who goes first in round 1 is decided on the Battle tab — not the same as attacker.
                    """
                )
            )
            .font(.caption)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
        }
    }
}
