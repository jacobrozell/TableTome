import Foundation
import SwiftData
import TabletomeDomain

/// Automatic log when a unit or squad member painting state changes.
@Model
public final class StageEvent {
    public var id: UUID = UUID()
    public var occurredAt: Date = Date()
    public var stageKey: String = ""
    public var previousStageKey: String?
    /// nil = unit-level; non-nil = squad member index.
    public var memberIndex: Int?
    public var unit: ArmyUnit?

    public init(stageKey: String, previousStageKey: String?, memberIndex: Int? = nil) {
        self.stageKey = stageKey
        self.previousStageKey = previousStageKey
        self.memberIndex = memberIndex
    }
}
