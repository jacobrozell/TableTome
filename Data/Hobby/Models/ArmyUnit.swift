import Foundation
import SwiftData
import TabletomeDomain

/// One entry in an army. May represent many physical models. Mirrors the web unit row
/// `{ unit, qty, source, state, spearhead?, notes, members? }`.
@Model
public final class ArmyUnit {
    public var id: UUID = UUID()

    public var name: String = ""        // web: `unit`
    public var qty: Int = 1             // clamped 1...9999
    public var source: String = ""
    public var state: String = ""       // a pipeline stage key
    public var notes: String = ""

    /// Tri-state spearhead (web semantics):
    ///   nil   = army/game does not use spearhead → no control shown
    ///   false = applicable but not picked
    ///   true  = spearhead pick
    public var spearhead: Bool?

    public var order: Int = 0           // position within the army

    public var army: Army?

    @Relationship(deleteRule: .cascade, inverse: \SquadMember.unit)
    public var squadMembers: [SquadMember] = []

    @Relationship(deleteRule: .cascade, inverse: \ModelPhoto.unit)
    public var photos: [ModelPhoto] = []

    @Relationship(deleteRule: .cascade, inverse: \StageEvent.unit)
    public var stageEvents: [StageEvent] = []

    public init(name: String,
         qty: Int = 1,
         source: String = "",
         state: String,
         notes: String = "",
         spearhead: Bool? = nil,
         order: Int = 0) {
        self.name = name
        self.qty = max(1, qty)
        self.source = source
        self.state = state
        self.notes = notes
        self.spearhead = spearhead
        self.order = order
    }
}

extension ArmyUnit {
    /// Estimated physical model count: Qty × (sum of numbers in the first (...) group, or 1).
    public var modelCount: Int { ModelCount.of(name: name, qty: qty) }

    /// True when per-model squad tracking is enabled.
    public var hasSquadMembers: Bool { !squadMembers.isEmpty }

    /// Eligible squad size (== modelCount). Per-model tracking needs >= 2.
    public var squadSize: Int { modelCount }

    /// The squad member at a given 0-based index, if tracking is on.
    public func member(at index: Int) -> SquadMember? {
        squadMembers.first { $0.index == index }
    }

    public var sortedSquadMembers: [SquadMember] {
        squadMembers.sorted { $0.index < $1.index }
    }

    public var coverPhoto: ModelPhoto? {
        photos.first(where: \.isCover) ?? orderedPhotos.first
    }

    public var orderedPhotos: [ModelPhoto] {
        photos.sorted {
            if $0.sortIndex != $1.sortIndex { return $0.sortIndex < $1.sortIndex }
            return $0.createdAt < $1.createdAt
        }
    }

    public var orderedStageEvents: [StageEvent] {
        stageEvents.sorted { $0.occurredAt < $1.occurredAt }
    }
}
