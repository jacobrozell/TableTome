import SwiftUI
import TabletomeDomain

struct InlineRollPickerCard: View {
    let playerOneName: String
    let playerTwoName: String
    let attackerIsPlayerOne: Bool?
    let title: String
    let onSelect: (Bool?) -> Void
    let decidedCaption: (Bool) -> String

    var body: some View {
        AttackerDefenderPickerCard(
            playerOneName: playerOneName,
            playerTwoName: playerTwoName,
            attackerIsPlayerOne: attackerIsPlayerOne,
            onSelect: onSelect,
            title: title,
            decidedCaption: decidedCaption,
            accessibilityPrefix: "guidedMatch.inlineRoll"
        )
    }
}

struct RollPromptSection: View {
    @ObservedObject var viewModel: GuidedMatchViewModel
    let gameSystemId: GameSystemId
    let inlineRollPickerTitle: String
    let playerOneRollLabel: String
    let playerTwoRollLabel: String
    let inlineRollDecidedCaption: (Bool) -> String

    var body: some View {
        if viewModel.matchState.hasBothArmies,
           viewModel.matchState.attackerIsPlayerOne != nil,
           viewModel.nextIncompleteStep?.id == "roll-attacker" {
            Section {
                InlineRollPickerCard(
                    playerOneName: playerOneRollLabel,
                    playerTwoName: playerTwoRollLabel,
                    attackerIsPlayerOne: viewModel.matchState.attackerIsPlayerOne,
                    title: inlineRollPickerTitle,
                    onSelect: viewModel.setAttacker,
                    decidedCaption: inlineRollDecidedCaption
                )
                .listRowInsets(
                    EdgeInsets(
                        top: DesignTokens.Spacing.sm,
                        leading: 0,
                        bottom: DesignTokens.Spacing.sm,
                        trailing: 0
                    )
                )
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            } header: {
                Text(String(localized: "At the table"))
            } footer: {
                Text(
                    String(
                        localized: "Confirm who won the roll-off — change the picker if your table decided differently."
                    )
                )
            }
        }
    }
}
