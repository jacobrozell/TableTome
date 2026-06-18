import Foundation

public struct MatchArchiveInput: Sendable {
    public var id: UUID
    public var gameSystemId: String
    public var gameSystemName: String
    public var matchState: GuidedMatchState
    public var trackerState: BattleTrackerState
    public var status: MatchArchiveStatus
    public var startedAt: Date?
    public var endedAt: Date
    public var playerOneArmyLabel: String
    public var playerTwoArmyLabel: String
    public var playerOneVictoryPoints: Int
    public var playerTwoVictoryPoints: Int

    public init(
        id: UUID = UUID(),
        gameSystemId: String,
        gameSystemName: String,
        matchState: GuidedMatchState,
        trackerState: BattleTrackerState,
        status: MatchArchiveStatus,
        startedAt: Date?,
        endedAt: Date = Date(),
        playerOneArmyLabel: String,
        playerTwoArmyLabel: String,
        playerOneVictoryPoints: Int,
        playerTwoVictoryPoints: Int
    ) {
        self.id = id
        self.gameSystemId = gameSystemId
        self.gameSystemName = gameSystemName
        self.matchState = matchState
        self.trackerState = trackerState
        self.status = status
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.playerOneArmyLabel = playerOneArmyLabel
        self.playerTwoArmyLabel = playerTwoArmyLabel
        self.playerOneVictoryPoints = playerOneVictoryPoints
        self.playerTwoVictoryPoints = playerTwoVictoryPoints
    }
}

public enum MatchArchiveBuilder: Sendable {
    public static func buildRecord(from input: MatchArchiveInput) -> MatchRecord {
        MatchRecord(
            id: input.id,
            gameSystemId: input.gameSystemId,
            gameSystemName: input.gameSystemName,
            createdAt: input.startedAt ?? input.endedAt,
            endedAt: input.endedAt,
            status: input.status,
            players: MatchPlayerSummary(
                playerOneName: input.matchState.playerOne.playerName,
                playerTwoName: input.matchState.playerTwo.playerName,
                playerOneArmyLabel: input.playerOneArmyLabel,
                playerTwoArmyLabel: input.playerTwoArmyLabel,
                playerOneFactionId: input.matchState.playerOne.factionId,
                playerTwoFactionId: input.matchState.playerTwo.factionId,
                playerOneArmyId: input.matchState.playerOne.armyId,
                playerTwoArmyId: input.matchState.playerTwo.armyId
            ),
            setup: MatchSetupSummary(
                attackerIsPlayerOne: input.matchState.attackerIsPlayerOne,
                firstTurnIsPlayerOne: input.matchState.firstTurnIsPlayerOne,
                missionId: input.matchState.selectedMissionId
            ),
            result: MatchResultSummary(
                playerOneVictoryPoints: input.playerOneVictoryPoints,
                playerTwoVictoryPoints: input.playerTwoVictoryPoints,
                winner: MatchWinnerResolver.resolve(
                    playerOneVP: input.playerOneVictoryPoints,
                    playerTwoVP: input.playerTwoVictoryPoints
                ),
                battleRound: input.trackerState.battleRound
            )
        )
    }
}
