import Foundation
import SwiftData
import TabletomeDomain

@Model
public final class RosterEntry {
    public var id: UUID = UUID()
    public var catalogUnitId: String = ""
    public var displayName: String = ""
    public var qty: Int = 1
    public var pointsEach: Int = 0
    /// When true, roster refresh and catalog sync skip this entry's points.
    public var usesCustomPoints: Bool = false
    public var sortIndex: Int = 0
    public var wargearSelectionJSON: String? = nil

    public var roster: Roster?

    public var pointsTotal: Int { qty * pointsEach }

    public init(catalogUnitId: String, displayName: String, qty: Int, pointsEach: Int, sortIndex: Int) {
        self.catalogUnitId = catalogUnitId
        self.displayName = displayName.hobbyCapped(HobbyLimits.maxStringLen)
        self.qty = max(1, min(qty, HobbyLimits.maxRosterQty))
        self.pointsEach = max(0, pointsEach)
        self.sortIndex = sortIndex
    }
}
