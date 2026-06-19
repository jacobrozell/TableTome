import Foundation
import SwiftData
import TabletomeDomain

/// A per-model override within a multi-model unit. Mirrors the web `{ state?, notes? }`
/// member, with an explicit `index` because SwiftData relationships are unordered.
/// `nil` state/notes mean "inherit from the unit" (`Members.effectiveState`).
@Model
public final class SquadMember {
    public var id: UUID = UUID()
    public var index: Int = 0       // 0-based model position within the unit
    public var state: String?       // nil = inherit the unit's state
    public var notes: String?       // nil = inherit the unit's notes
    public var unit: ArmyUnit?

    public init(index: Int, state: String? = nil, notes: String? = nil) {
        self.index = index
        self.state = state
        self.notes = notes
    }
}
