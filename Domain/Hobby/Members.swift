import Foundation

/// Per-model squad helpers. Ports `js/core/members.js` over the protocol abstractions.
/// A member with `nil` state/notes inherits the unit's.
public enum Members {
    public static func effectiveState(of unit: any UnitLike, at index: Int) -> String {
        if unit.hasSquadMembers, let s = unit.member(at: index)?.state, !s.isEmpty {
            return s
        }
        return unit.state
    }

    public static func effectiveNotes(of unit: any UnitLike, at index: Int) -> String {
        if unit.hasSquadMembers, let n = unit.member(at: index)?.notes, !n.isEmpty {
            return n
        }
        return unit.notes
    }

    /// One effective state per model, ordered by member index.
    public static func effectiveStates(of unit: any UnitLike) -> [String] {
        let n = unit.hasSquadMembers ? unit.members.count : unit.modelCount
        return (0..<n).map { effectiveState(of: unit, at: $0) }
    }

    /// "3× Based, 2× Primed" — counts of effective states, by count desc then key asc.
    /// Mirrors `squadStateSummary`.
    public static func stateSummary(of unit: any UnitLike) -> String {
        guard unit.hasSquadMembers else { return "" }
        var counts: [String: Int] = [:]
        for s in effectiveStates(of: unit) { counts[s, default: 0] += 1 }
        return counts
            .sorted { $0.value != $1.value ? $0.value > $1.value : $0.key < $1.key }
            .map { "\($0.value)× \($0.key)" }
            .joined(separator: ", ")
    }

    /// State-filter match (squad-aware). Mirrors `unitMatchesStateFilter`.
    public static func unitMatchesStateFilter(_ unit: any UnitLike, _ filter: String) -> Bool {
        if filter == "All" { return true }
        if !unit.hasSquadMembers { return unit.state == filter }
        return effectiveStates(of: unit).contains(filter)
    }

    /// Quick-view classification. Mirrors `unitPassesQuickView`.
    public static func unitPassesQuickView(_ unit: any UnitLike,
                                           pipeline: [PipelineStage],
                                           quickView: String) -> Bool {
        if quickView == "all" { return true }
        let states = unit.hasSquadMembers ? effectiveStates(of: unit) : [unit.state]
        let first = pipeline.first?.key
        switch quickView {
        case "backlog":
            return states.contains { $0 == first }
        case "wip":
            return states.contains { !Pipeline.doneStates.contains($0) && $0 != first }
        case "ready":
            return states.contains { Pipeline.doneStates.contains($0) }
        default:
            return true
        }
    }
}
