import Foundation
import TabletomeDomain

extension GuidedMatchViewModel {
    func applyHouseholdDefaultsIfNeeded(_ household: HouseholdPlayersState) {
        guard gameSystemId == .aosSpearhead else { return }

        if matchState.playerOne.armyId.isEmpty,
           let profileId = household.defaultPlayerOneProfileId,
           let profile = household.profile(id: profileId),
           matchState.playerOne.profileId == nil || matchState.playerOne.profileId == profile.id {
            var selection = matchState.playerOne
            selection.profileId = profile.id
            selection.playerName = profile.displayName
            updatePlayerOne(selection)
        }

        if matchState.playerTwo.armyId.isEmpty {
            let profiles = household.sortedProfiles
            if profiles.count == 2 {
                let other = profiles.first { $0.id != household.defaultPlayerOneProfileId } ?? profiles[1]
                if matchState.playerTwo.profileId == nil || matchState.playerTwo.profileId == other.id {
                    var selection = matchState.playerTwo
                    selection.profileId = other.id
                    selection.playerName = other.displayName
                    updatePlayerTwo(selection)
                }
            }
        }
    }
}
