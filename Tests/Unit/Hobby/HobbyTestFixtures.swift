import Foundation
@testable import TabletomeDomain

/// Lightweight in-memory conformers for the hobby protocols. SwiftData models will
/// take their place in Phase 4 — these only exist so the pure engines can be tested
/// without dragging the persistence layer in.
final class TestSquadMember: SquadMemberLike {
    var index: Int
    var state: String?
    var notes: String?

    init(index: Int, state: String? = nil, notes: String? = nil) {
        self.index = index
        self.state = state
        self.notes = notes
    }
}

final class TestUnit: UnitLike {
    var state: String
    var notes: String
    var modelCount: Int
    var hasSquadMembers: Bool
    var members: [any SquadMemberLike]

    var orderedMembers: [any SquadMemberLike] { members.sorted { $0.index < $1.index } }

    init(state: String,
         modelCount: Int,
         notes: String = "",
         members: [TestSquadMember] = []) {
        self.state = state
        self.notes = notes
        self.modelCount = modelCount
        self.hasSquadMembers = !members.isEmpty
        self.members = members
    }
}

final class TestArmy: ArmyLike {
    var faction: String
    var game: String
    var crestOverride: String?
    var colorOverrideHex: String?
    var customPipeline: [PipelineStage]?

    init(faction: String, game: String,
         crestOverride: String? = nil,
         colorOverrideHex: String? = nil,
         customPipeline: [PipelineStage]? = nil) {
        self.faction = faction
        self.game = game
        self.crestOverride = crestOverride
        self.colorOverrideHex = colorOverrideHex
        self.customPipeline = customPipeline
    }
}
