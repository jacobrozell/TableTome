import Foundation

public struct CombatPatrolStratagem: Codable, Sendable, Identifiable, Equatable {
    public let id: String
    public let name: String
    public let summary: String
    public let cpCost: Int
    public let phase: String?
    public let isReactive: Bool?

    public init(
        id: String,
        name: String,
        summary: String,
        cpCost: Int = 1,
        phase: String? = nil,
        isReactive: Bool? = nil
    ) {
        self.id = id
        self.name = name
        self.summary = summary
        self.cpCost = cpCost
        self.phase = phase
        self.isReactive = isReactive
    }
}
