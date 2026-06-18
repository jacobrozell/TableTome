import Foundation

/// Collection summary numbers for the armies tab header. Keeps stat maths out of SwiftUI.
/// Ported from MiniMuster `Domain/CollectionStats.swift` over the protocol abstractions.
public enum CollectionStats {
    public struct Snapshot: Equatable, Sendable {
        public var unitEntries: Int
        public var models: Int
        public var based: Int
        public var done: Int
        public var wip: Int
        public var todo: Int
        public var overallPercent: Int
        public var segments: [ProgressSegment]

        public init(unitEntries: Int, models: Int, based: Int, done: Int,
                    wip: Int, todo: Int, overallPercent: Int, segments: [ProgressSegment]) {
            self.unitEntries = unitEntries
            self.models = models
            self.based = based
            self.done = done
            self.wip = wip
            self.todo = todo
            self.overallPercent = overallPercent
            self.segments = segments
        }
    }

    public static func basedStage(in pipeline: [PipelineStage]) -> PipelineStage? {
        pipeline.first { $0.key == "Based" }
            ?? (pipeline.count >= 2 ? pipeline[pipeline.count - 2] : nil)
    }

    public static func doneStage(in pipeline: [PipelineStage]) -> PipelineStage? {
        pipeline.first { $0.key == "Done" } ?? pipeline.last
    }

    public static func snapshot(units: [any UnitLike], pipeline: [PipelineStage]) -> Snapshot {
        let models = units.reduce(0) { $0 + $1.modelCount }
        let basedKey = basedStage(in: pipeline)?.key
        let doneKey = doneStage(in: pipeline)?.key
        let based = basedKey.map { key in units.filter { $0.state == key }.count } ?? 0
        let done = doneKey.map { key in units.filter { $0.state == key }.count } ?? 0
        let first = pipeline.first?.key
        let wip = units.filter { !Pipeline.doneStates.contains($0.state) && $0.state != first }.count
        let todo = units.filter { $0.state == first }.count
        let overall = Int((Pipeline.progress(of: units, pipeline) * 100).rounded())
        let segments = Pipeline.segments(of: units, pipeline)
        return Snapshot(unitEntries: units.count, models: models, based: based, done: done,
                        wip: wip, todo: todo, overallPercent: overall, segments: segments)
    }
}
