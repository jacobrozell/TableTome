import Foundation

public struct CombatPatrolMission: Codable, Sendable, Identifiable, Equatable {
    public let id: String
    public let name: String
    public let d6Result: Int?
    public let recommendedForFirstGame: Bool?
    public let missionRuleSummary: String
    public let primaryObjectiveSummary: String
    public let scoringNotes: String?

    public init(
        id: String,
        name: String,
        d6Result: Int? = nil,
        recommendedForFirstGame: Bool? = nil,
        missionRuleSummary: String,
        primaryObjectiveSummary: String,
        scoringNotes: String? = nil
    ) {
        self.id = id
        self.name = name
        self.d6Result = d6Result
        self.recommendedForFirstGame = recommendedForFirstGame
        self.missionRuleSummary = missionRuleSummary
        self.primaryObjectiveSummary = primaryObjectiveSummary
        self.scoringNotes = scoringNotes
    }
}
