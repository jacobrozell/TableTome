import Foundation
import SwiftData
import TabletomeDomain

@Model
public final class Roster {
    public var id: UUID = UUID()
    public var name: String = ""
    public var game: String = "40k"
    public var faction: String = ""
    public var battleSizeKey: String = "strike-force"
    public var notes: String = ""
    public var createdAt: Date = Date()
    public var updatedAt: Date = Date()
    public var sortIndex: Int = 0
    public var linkedArmyId: UUID?
    public var catalogVersion: String = ""

    @Relationship(deleteRule: .cascade, inverse: \RosterEntry.roster)
    public var entries: [RosterEntry] = []

    public init(name: String, game: String, faction: String, battleSizeKey: String) {
        self.name = name.hobbyCapped(HobbyLimits.maxStringLen)
        self.game = game
        self.faction = faction
        self.battleSizeKey = battleSizeKey
    }
}
