import SwiftUI
import TabletomeDomain

struct PreBattleLoadoutReviewSection: View {
    @ObservedObject var viewModel: GuidedMatchViewModel
    let ruleSections: [RuleSection]
    let usesPadSplitNavigation: Bool
    @Binding var showsLoadoutSheet: Bool
    let onOpenRegimentStep: () -> Void
    let onOpenEnhancementStep: () -> Void

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
                onOpenRegimentStep: onOpenRegimentStep,
                onOpenEnhancementStep: onOpenEnhancementStep
            )
            .listHeroCardRow()

            Button {
                showsLoadoutSheet = true
            } label: {
                Label(String(localized: "Set Loadout"), systemImage: "tray.and.arrow.down.fill")
            }
            .accessibilityIdentifier("guidedMatch.preBattleLoadout.openSheet")

            if !usesPadSplitNavigation {
                NavigationLink(value: GuidedMatchDestination.step("regiment-abilities")) {
                    Label(String(localized: "Open regiment abilities step"), systemImage: "checklist")
                }
                .accessibilityIdentifier("guidedMatch.preBattleLoadout.regimentLink")

                NavigationLink(value: GuidedMatchDestination.step("enhancements")) {
                    Label(String(localized: "Open enhancements step"), systemImage: "sparkles")
                }
                .accessibilityIdentifier("guidedMatch.preBattleLoadout.enhancementsLink")
            }
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
