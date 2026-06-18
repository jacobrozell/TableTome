import Foundation

public enum MatchArchiveStatus: String, Codable, Sendable {
    case completed
    case abandoned
}

public enum MatchWinner: String, Codable, Sendable {
    case playerOne
    case playerTwo
    case tie
    case undecided
}

public struct MatchPlayerSummary: Codable, Sendable, Equatable {
    public var playerOneName: String
    public var playerTwoName: String
    public var playerOneArmyLabel: String
    public var playerTwoArmyLabel: String
    public var playerOneFactionId: String
    public var playerTwoFactionId: String
    public var playerOneArmyId: String
    public var playerTwoArmyId: String

    public init(
        playerOneName: String,
        playerTwoName: String,
        playerOneArmyLabel: String,
        playerTwoArmyLabel: String,
        playerOneFactionId: String = "",
        playerTwoFactionId: String = "",
        playerOneArmyId: String = "",
        playerTwoArmyId: String = ""
    ) {
        self.playerOneName = playerOneName
        self.playerTwoName = playerTwoName
        self.playerOneArmyLabel = playerOneArmyLabel
        self.playerTwoArmyLabel = playerTwoArmyLabel
        self.playerOneFactionId = playerOneFactionId
        self.playerTwoFactionId = playerTwoFactionId
        self.playerOneArmyId = playerOneArmyId
        self.playerTwoArmyId = playerTwoArmyId
    }
}

public struct MatchSetupSummary: Codable, Sendable, Equatable {
    public var attackerIsPlayerOne: Bool?
    public var firstTurnIsPlayerOne: Bool?
    public var missionId: String?

    public init(
        attackerIsPlayerOne: Bool? = nil,
        firstTurnIsPlayerOne: Bool? = nil,
        missionId: String? = nil
    ) {
        self.attackerIsPlayerOne = attackerIsPlayerOne
        self.firstTurnIsPlayerOne = firstTurnIsPlayerOne
        self.missionId = missionId
    }
}

public struct MatchResultSummary: Codable, Sendable, Equatable {
    public var playerOneVictoryPoints: Int
    public var playerTwoVictoryPoints: Int
    public var winner: MatchWinner
    public var battleRound: Int

    public init(
        playerOneVictoryPoints: Int,
        playerTwoVictoryPoints: Int,
        winner: MatchWinner,
        battleRound: Int
    ) {
        self.playerOneVictoryPoints = playerOneVictoryPoints
        self.playerTwoVictoryPoints = playerTwoVictoryPoints
        self.winner = winner
        self.battleRound = battleRound
    }
}

public struct MatchRecord: Codable, Sendable, Identifiable, Equatable {
    public static let currentSchemaVersion = 1

    public let id: UUID
    public let gameSystemId: String
    public let gameSystemName: String
    public let createdAt: Date
    public let endedAt: Date
    public let status: MatchArchiveStatus
    public let players: MatchPlayerSummary
    public let setup: MatchSetupSummary
    public let result: MatchResultSummary
    public let schemaVersion: Int

    public init(
        id: UUID = UUID(),
        gameSystemId: String,
        gameSystemName: String,
        createdAt: Date,
        endedAt: Date,
        status: MatchArchiveStatus,
        players: MatchPlayerSummary,
        setup: MatchSetupSummary,
        result: MatchResultSummary,
        schemaVersion: Int = MatchRecord.currentSchemaVersion
    ) {
        self.id = id
        self.gameSystemId = gameSystemId
        self.gameSystemName = gameSystemName
        self.createdAt = createdAt
        self.endedAt = endedAt
        self.status = status
        self.players = players
        self.setup = setup
        self.result = result
        self.schemaVersion = schemaVersion
    }

    public var duration: TimeInterval {
        max(0, endedAt.timeIntervalSince(createdAt))
    }

    public var winnerPlayerName: String? {
        switch result.winner {
        case .playerOne:
            players.playerOneName
        case .playerTwo:
            players.playerTwoName
        case .tie, .undecided:
            nil
        }
    }
}
