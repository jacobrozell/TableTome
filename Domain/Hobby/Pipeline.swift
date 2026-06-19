import Foundation

/// One step in the painting pipeline. Value type so the domain engines never
/// touch SwiftData. The Phase 4 SwiftData `PipelineStage` model will map to/from
/// this value at the boundary.
public struct PipelineStage: Hashable, Sendable, Codable, Identifiable {
    public var key: String
    public var hex: String
    public var id: String { key }

    public init(key: String, hex: String) {
        self.key = key
        self.hex = hex
    }
}

/// The default 9-stage painting pipeline. Ports `DEFAULT_PIPELINE`
/// (`MiniMuster/js/core/constants.js`).
public enum DefaultPipeline {
    public static let stages: [PipelineStage] = [
        .init(key: "Unassembled", hex: "#4a4d57"),
        .init(key: "Assembled",   hex: "#6366f1"),
        .init(key: "Magnetising", hex: "#0ea5e9"),
        .init(key: "Magnetised",  hex: "#06b6d4"),
        .init(key: "Primed",      hex: "#f97316"),
        .init(key: "Base Coated", hex: "#eab308"),
        .init(key: "Detailed",    hex: "#84cc16"),
        .init(key: "Based",       hex: "#16a34a"),
        .init(key: "Done",        hex: "#22c55e"),
    ]
}

/// A non-normalized stacked-meter segment. Mirrors the web `progressSegments` output.
public struct ProgressSegment: Identifiable, Hashable, Sendable {
    public let key: String
    public let hex: String
    public let pct: Double   // 0...100 share of total models in this stage
    public var id: String { key }

    public init(key: String, hex: String, pct: Double) {
        self.key = key
        self.hex = hex
        self.pct = pct
    }
}

public struct NormalizedState: Equatable, Sendable {
    public let state: String
    public let warning: String?

    public init(state: String, warning: String?) {
        self.state = state
        self.warning = warning
    }
}

/// Pure pipeline + progress maths. Ports `js/core/pipeline.js`.
public enum Pipeline {
    public static let doneStates: Set<String> = ["Based", "Done"]

    /// Global pipeline = custom (sanitized) or default.
    public static func resolve(_ custom: [PipelineStage]?) -> [PipelineStage] {
        guard let custom, !custom.isEmpty else { return DefaultPipeline.stages }
        return custom.map { PipelineStage(key: $0.key, hex: safeColor($0.hex)) }
    }

    /// Per-army pipeline = army custom or the global one.
    public static func forArmy(_ army: any ArmyLike, global: [PipelineStage]?) -> [PipelineStage] {
        resolve(army.customPipeline ?? global)
    }

    public static func index(of state: String, in pipeline: [PipelineStage]) -> Int? {
        pipeline.firstIndex { $0.key == state }
    }

    /// Canonicalize an imported state value. Mirrors `normalizeState`.
    public static func normalizeState(_ raw: String, pipeline: [PipelineStage]) -> NormalizedState {
        let first = pipeline.first?.key ?? "Unassembled"
        let s = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.isEmpty { return NormalizedState(state: first, warning: nil) }
        if let match = pipeline.first(where: { $0.key.lowercased() == s.lowercased() }) {
            return NormalizedState(state: match.key, warning: nil)
        }
        return NormalizedState(state: first, warning: "Unknown state \"\(s)\" — using \(first)")
    }

    /// Fraction 0...1 for a single state: (idx ?? 0) / max(n-1, 1).
    public static func stageProgress(_ state: String, _ pipeline: [PipelineStage]) -> Double {
        let idx = index(of: state, in: pipeline) ?? 0
        let denom = Double(max(pipeline.count - 1, 1))
        return Double(idx) / denom
    }

    /// Next stage key after `current`, or nil if last/unknown. Mirrors `nextPipelineState`.
    public static func next(after current: String, in pipeline: [PipelineStage]) -> String? {
        guard let i = index(of: current, in: pipeline), i < pipeline.count - 1 else { return nil }
        return pipeline[i + 1].key
    }

    /// Weighted progress contribution of ONE unit (not normalized).
    public static func unitWeightedProgress(_ unit: any UnitLike, _ pipeline: [PipelineStage]) -> Double {
        if unit.hasSquadMembers {
            return Members.effectiveStates(of: unit)
                .reduce(0) { $0 + stageProgress($1, pipeline) }
        }
        return stageProgress(unit.state, pipeline) * Double(unit.modelCount)
    }

    /// Collection/army progress 0...1 = Σ unitWeightedProgress / Σ modelCount.
    public static func progress(of units: [any UnitLike], _ pipeline: [PipelineStage]) -> Double {
        let total = units.reduce(0) { $0 + $1.modelCount }
        guard total > 0 else { return 0 }
        return units.reduce(0) { $0 + unitWeightedProgress($1, pipeline) } / Double(total)
    }

    /// Stacked-meter segments in pipeline order, skipping empty stages.
    public static func segments(of units: [any UnitLike], _ pipeline: [PipelineStage]) -> [ProgressSegment] {
        let totalModels = units.reduce(0) { $0 + $1.modelCount }
        guard totalModels > 0 else { return [] }
        var counts: [String: Int] = [:]
        for u in units {
            if u.hasSquadMembers {
                for st in Members.effectiveStates(of: u) { counts[st, default: 0] += 1 }
            } else {
                counts[u.state, default: 0] += u.modelCount
            }
        }
        return pipeline.compactMap { stage in
            guard let c = counts[stage.key], c > 0 else { return nil }
            return ProgressSegment(key: stage.key, hex: stage.hex,
                                   pct: Double(c) / Double(totalModels) * 100)
        }
    }

    /// True if the unit's squad default OR any member can advance. Mirrors the
    /// `squadNext || memberNext` checks used by bulk advance.
    public static func canAdvance(_ unit: any UnitLike, _ pipeline: [PipelineStage]) -> Bool {
        if next(after: unit.state, in: pipeline) != nil { return true }
        guard unit.hasSquadMembers else { return false }
        return unit.members.contains {
            next(after: Members.effectiveState(of: unit, at: $0.index), in: pipeline) != nil
        }
    }

    /// Advance a unit one pipeline step. Ports `advanceUnitOneStep`, including the
    /// "clear member override when it now matches the squad default" rule. Mutates
    /// the model graph in place.
    public static func advanceOneStep(_ unit: any UnitLike, _ pipeline: [PipelineStage]) {
        let priorSquadState = unit.state
        let squadNext = next(after: priorSquadState, in: pipeline)
        if unit.hasSquadMembers {
            let targetSquadState = squadNext ?? priorSquadState
            for member in unit.orderedMembers {
                let current = member.state.flatMap { $0.isEmpty ? nil : $0 } ?? priorSquadState
                guard let nextState = next(after: current, in: pipeline) else { continue }
                member.state = (nextState == targetSquadState) ? nil : nextState
            }
            if let squadNext { unit.state = squadNext }
            return
        }
        if let squadNext { unit.state = squadNext }
    }
}
