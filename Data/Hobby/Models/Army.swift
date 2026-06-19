import Foundation
import SwiftData
import TabletomeDomain

/// A named list grouping unit entries. Mirrors the web `Army` typedef
/// (`js/core/constants.js`). We store only crest/colour *overrides* and resolve the
/// displayed crest/colour live from the faction catalogue (`FactionResolver`), matching the
/// direction of the web `getArmyPresentation`.
///
/// CloudKit-readiness (`docs/ios-spec/01-data-model.md §9`): every property has a default or
/// is optional, relationships are optional with inverses, and no `@Attribute(.unique)` is
/// used — uniqueness of `name` is enforced in app logic instead.
@Model
public final class Army {
    public var id: UUID = UUID()

    public var name: String = ""            // web: `army` (display label + import grouping key)
    public var game: String = ""            // e.g. "40k", "AoS"
    public var faction: String = ""         // e.g. "Grey Knights"

    public var crestOverride: String?       // <= 8 chars; nil = use faction preset
    public var colorOverrideHex: String?    // validated hex; nil = use faction preset

    /// nil = use the global pipeline. Non-empty = army-specific stages.
    public var customPipeline: [PipelineStage]?

    public var sortIndex: Int = 0           // import / first-seen order
    public var isCollapsed: Bool = false

    @Relationship(deleteRule: .cascade, inverse: \ArmyUnit.army)
    public var units: [ArmyUnit] = []

    public init(name: String, game: String, faction: String, sortIndex: Int = 0) {
        self.name = name
        self.game = game
        self.faction = faction
        self.sortIndex = sortIndex
    }
}

extension Army {
    /// Units in their persisted order (relationships are unordered in SwiftData).
    public var orderedUnits: [ArmyUnit] {
        units.sorted { $0.order < $1.order }
    }
}
