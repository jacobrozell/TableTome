import Foundation
import TabletomeHobbyData
import TabletomeDomain
import SwiftData
import TabletomeDomain

/// Per-model squad tracking mutations. Ports `enableSquadMembers`, `disableSquadMembers`,
/// `updateMember`, and the member-advance logic (`js/core/store.js`, `render/armies.js`).
/// See `docs/ios-spec/04-squad-tracking.md`.
@MainActor
enum SquadStore {

    /// Enable per-model tracking (modelCount >= 2). Creates inheriting members.
    @discardableResult
    static func enable(_ unit: ArmyUnit, in ctx: ModelContext) -> Bool {
        guard !unit.hasSquadMembers, unit.modelCount >= 2 else { return false }
        for i in 0..<unit.modelCount {
            let m = SquadMember(index: i)
            m.unit = unit
            ctx.insert(m)
        }
        try? ctx.save()
        return true
    }

    static func disable(_ unit: ArmyUnit, in ctx: ModelContext) {
        for m in unit.squadMembers { ctx.delete(m) }
        try? ctx.save()
    }

    /// Set a member's state, clearing the override when it equals the unit default (inherit).
    static func setMemberState(_ unit: ArmyUnit, index: Int, state: String, in ctx: ModelContext) {
        guard let m = unit.member(at: index) else { return }
        let previous = Members.effectiveState(of: unit, at: index)
        m.state = (state == unit.state) ? nil : state
        let next = Members.effectiveState(of: unit, at: index)
        if previous != next {
            StageEventStore.record(unit: unit, stageKey: next, previousStageKey: previous,
                                   memberIndex: index, in: ctx)
        }
        try? ctx.save()
    }

    static func setMemberNotes(_ unit: ArmyUnit, index: Int, notes: String, in ctx: ModelContext) {
        guard let member = unit.squadMembers.first(where: { $0.index == index }) else { return }
        member.notes = notes.isEmpty ? nil : notes
        try? ctx.save()
    }

    /// Advance one member one step, applying the inherit-on-match rule.
    static func advanceMember(_ unit: ArmyUnit, index: Int, pipeline: [PipelineStage], in ctx: ModelContext) {
        guard let m = unit.member(at: index) else { return }
        let cur = Members.effectiveState(of: unit, at: index)
        guard let next = Pipeline.next(after: cur, in: pipeline) else { return }
        m.state = (next == unit.state) ? nil : next
        let effective = Members.effectiveState(of: unit, at: index)
        if cur != effective {
            StageEventStore.record(unit: unit, stageKey: effective, previousStageKey: cur,
                                   memberIndex: index, in: ctx)
        }
        try? ctx.save()
    }
}
