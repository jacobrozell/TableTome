import SwiftUI
import TabletomeDomain

struct PreBattleLoadoutReviewSection: View {
    @ObservedObject var viewModel: GuidedMatchViewModel
    let ruleSections: [RuleSection]
    @Binding var showsLoadoutSheet: Bool

    var body: some View {
        Section {
            PreBattleLoadoutReviewCard(
                playerOneName: viewModel.matchState.playerOne.playerName.isEmpty
                    ? String(localized: "Player 1")
                    : viewModel.matchState.playerOne.playerName,
                playerTwoName: viewModel.matchState.playerTwo.playerName.isEmpty
                    ? String(localized: "Player 2")
                    : viewModel.matchState.playerTwo.playerName,
                playerOneRegiment: viewModel.regimentAbility(for: viewModel.matchState.playerOne),
                playerTwoRegiment: viewModel.regimentAbility(for: viewModel.matchState.playerTwo),
                playerOneEnhancement: viewModel.enhancement(for: viewModel.matchState.playerOne),
                playerTwoEnhancement: viewModel.enhancement(for: viewModel.matchState.playerTwo),
                onOpenLoadout: { showsLoadoutSheet = true }
            )
            .listHeroCardRow()
        } header: {
            Text(String(localized: "Pre-battle picks"))
        } footer: {
            Text(
                String(
                    localized: "These are physical cards in your box — do not skip them. Mark each setup step complete when done."
                )
            )
        }
        .sheet(isPresented: $showsLoadoutSheet) {
            SpearheadLoadoutSheet(
                viewModel: viewModel,
                ruleSections: ruleSections,
                onConfirm: {
                    viewModel.setStepComplete("regiment-abilities", complete: true)
                    viewModel.setStepComplete("enhancements", complete: true)
                }
            )
        }
    }
}
