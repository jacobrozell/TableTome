import Foundation

public enum PlayerRematchPreferencesRecorder: Sendable {
    /// After a completed Spearhead match, remember each profiled player's army vs their opponent's army.
    public static func preferredArmyUpdates(
        playerOneProfileId: UUID?,
        playerOneArmyId: String,
        playerTwoProfileId: UUID?,
        playerTwoArmyId: String,
        in household: HouseholdPlayersState
    ) -> [(profileId: UUID, profile: PlayerProfile)] {
        guard !playerOneArmyId.isEmpty, !playerTwoArmyId.isEmpty else { return [] }

        var updates: [(UUID, PlayerProfile)] = []
        if let profileId = playerOneProfileId,
           var profile = household.profile(id: profileId) {
            profile.guidedMatchPreferences.preferredArmyIdByOpponentArmyId[playerTwoArmyId] = playerOneArmyId
            updates.append((profileId, profile))
        }
        if let profileId = playerTwoProfileId,
           var profile = household.profile(id: profileId) {
            profile.guidedMatchPreferences.preferredArmyIdByOpponentArmyId[playerOneArmyId] = playerTwoArmyId
            updates.append((profileId, profile))
        }
        return updates
    }
}
