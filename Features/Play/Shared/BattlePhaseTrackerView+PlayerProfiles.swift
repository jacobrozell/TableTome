import SwiftUI
import TabletomeDomain

extension BattlePhaseTrackerView {
    var activePlayerProfile: PlayerProfile? {
        let selection = viewModel.trackerState.activePlayerIsOne
            ? viewModel.matchState.playerOne
            : viewModel.matchState.playerTwo
        guard let profileId = selection.profileId else { return nil }
        return householdProfiles.first { $0.id == profileId }
    }

    func applyDiceModeForActivePlayer() {
        guard ReleaseSurface.allowsSimulatedDice(for: viewModel.gameSystemId) else { return }
        let deviceMode = DiceInputMode(rawValue: diceInputModeRaw) ?? .physical
        let effective = PlayerDiceInputResolver.effectiveMode(
            profile: activePlayerProfile,
            deviceMode: deviceMode
        )
        diceInputModeRaw = effective.rawValue
    }
}
