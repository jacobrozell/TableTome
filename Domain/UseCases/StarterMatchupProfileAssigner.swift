import Foundation

public enum StarterMatchupProfileAssigner: Sendable {
    public enum Result: Sendable, Equatable {
        case assigned
        case notApplicable
        case ambiguous
    }

    /// When both player slots have profiles that own distinct box armies, assign armies to matching owners.
    public static func assignBoxArmiesToProfiles(
        config: FeaturedArmiesConfig,
        household: HouseholdPlayersState,
        state: inout GuidedMatchState
    ) -> Result {
        guard let profileOneId = state.playerOne.profileId,
              let profileTwoId = state.playerTwo.profileId,
              let profileOne = household.profile(id: profileOneId),
              let profileTwo = household.profile(id: profileTwoId) else {
            return .notApplicable
        }

        let boxArmies = [config.playerOne, config.playerTwo]
        let armyForProfileOne = boxArmies.first { profileOne.ownedSpearheadArmyIds.contains($0.armyId) }
        let armyForProfileTwo = boxArmies.first {
            profileTwo.ownedSpearheadArmyIds.contains($0.armyId) && $0.armyId != armyForProfileOne?.armyId
        }

        guard let armyOne = armyForProfileOne, let armyTwo = armyForProfileTwo else {
            return .ambiguous
        }

        state.playerOne = PlayerArmySelection(
            playerName: profileOne.displayName,
            factionId: armyOne.factionId,
            armyId: armyOne.armyId,
            profileId: profileOne.id
        )
        state.playerTwo = PlayerArmySelection(
            playerName: profileTwo.displayName,
            factionId: armyTwo.factionId,
            armyId: armyTwo.armyId,
            profileId: profileTwo.id
        )
        return .assigned
    }
}
