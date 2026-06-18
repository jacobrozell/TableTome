import Foundation

public struct StarterArmySelection: Sendable, Equatable {
    public let playerName: String
    public let factionId: String
    public let armyId: String

    public init(playerName: String, factionId: String, armyId: String) {
        self.playerName = playerName
        self.factionId = factionId
        self.armyId = armyId
    }

    public func playerArmySelection() -> PlayerArmySelection {
        PlayerArmySelection(playerName: playerName, factionId: factionId, armyId: armyId)
    }
}

public struct FeaturedArmiesConfig: Sendable, Equatable {
    public let armyIds: Set<String>
    public let starterMatchupTitle: String
    public let starterSetDescription: String
    public let starterSetBadge: String
    public let playerOne: StarterArmySelection
    public let playerTwo: StarterArmySelection
    public let defaultMissionId: String?

    public init(
        armyIds: Set<String>,
        starterMatchupTitle: String,
        starterSetDescription: String,
        starterSetBadge: String,
        playerOne: StarterArmySelection,
        playerTwo: StarterArmySelection,
        defaultMissionId: String? = nil
    ) {
        self.armyIds = armyIds
        self.starterMatchupTitle = starterMatchupTitle
        self.starterSetDescription = starterSetDescription
        self.starterSetBadge = starterSetBadge
        self.playerOne = playerOne
        self.playerTwo = playerTwo
        self.defaultMissionId = defaultMissionId
    }

    public func isFeatured(_ armyId: String) -> Bool {
        armyIds.contains(armyId)
    }

    public func applyStarterMatchup(to state: inout GuidedMatchState) {
        state.playerOne = playerOne.playerArmySelection()
        state.playerTwo = playerTwo.playerArmySelection()
        state.attackerIsPlayerOne = nil
        state.firstTurnIsPlayerOne = nil
        state.completedStepIds = []
        state.selectedMissionId = defaultMissionId
    }
}
