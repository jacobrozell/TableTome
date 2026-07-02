import SwiftUI
import TabletomeDomain

/// Deployment-phase once-per-battle abilities for both Spearhead armies (setup step 5 + inline compact).
struct SpearheadDeploymentAbilitiesSection: View {
    @ObservedObject var viewModel: GuidedMatchViewModel
    let ruleSections: [RuleSection]

    var body: some View {
        BattleTrackerDeploymentAbilitiesSection(
            playerOneName: viewModel.matchState.playerOne.playerName.isEmpty
                ? String(localized: "Player 1")
                : viewModel.matchState.playerOne.playerName,
            playerTwoName: viewModel.matchState.playerTwo.playerName.isEmpty
                ? String(localized: "Player 2")
                : viewModel.matchState.playerTwo.playerName,
            playerOneArmy: viewModel.army(
                factionId: viewModel.matchState.playerOne.factionId,
                armyId: viewModel.matchState.playerOne.armyId
            ),
            playerTwoArmy: viewModel.army(
                factionId: viewModel.matchState.playerTwo.factionId,
                armyId: viewModel.matchState.playerTwo.armyId
            ),
            usedOncePerBattleAbilityIds: [],
            ruleSections: ruleSections,
            onMarkUsed: nil
        )
    }
}
