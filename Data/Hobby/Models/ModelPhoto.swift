import Foundation
import SwiftData
import TabletomeDomain

/// A JPEG checkpoint attached to a unit. Bytes live on disk; this row stores metadata only.
@Model
public final class ModelPhoto {
    public var id: UUID = UUID()
    public var createdAt: Date = Date()
    /// Pipeline stage key at capture time (e.g. "Primed").
    public var stageKey: String = ""
    public var caption: String = ""
    /// File name relative to `PhotoFileStore.directory` (e.g. `a1b2….jpg`).
    public var fileName: String = ""
    public var isCover: Bool = false
    public var sortIndex: Int = 0
    /// nil = unit-level; non-nil = per-model index when squad tracking is on.
    public var memberIndex: Int?

    public var unit: ArmyUnit?

    public init(stageKey: String, fileName: String, memberIndex: Int? = nil) {
        self.stageKey = stageKey
        self.fileName = fileName
        self.memberIndex = memberIndex
    }
}
