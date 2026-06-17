import Foundation

public enum SpearheadFeaturedArmies {
    public static let armyIds: Set<String> = [
        "vigilant-brotherhood",
        "gnawfeast-clawpack"
    ]

    public static let starterMatchupTitle = "Vigilant Brotherhood vs Gnawfeast Clawpack"

    public static func isFeatured(_ armyId: String) -> Bool {
        armyIds.contains(armyId)
    }

    public static func applyStarterMatchup(to state: inout GuidedMatchState) {
        state.playerOne = PlayerArmySelection(
            playerName: "Player 1",
            factionId: "stormcast-eternals",
            armyId: "vigilant-brotherhood"
        )
        state.playerTwo = PlayerArmySelection(
            playerName: "Player 2",
            factionId: "skaven",
            armyId: "gnawfeast-clawpack"
        )
        state.attackerIsPlayerOne = nil
        state.completedStepIds = []
    }
}
