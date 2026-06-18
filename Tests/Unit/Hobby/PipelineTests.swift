import XCTest
@testable import TabletomeDomain

final class HobbyPipelineTests: XCTestCase {
    private let pipeline = DefaultPipeline.stages

    func testResolveReturnsDefaultWhenNoCustom() {
        XCTAssertEqual(Pipeline.resolve(nil), DefaultPipeline.stages)
        XCTAssertEqual(Pipeline.resolve([]), DefaultPipeline.stages)
    }

    func testResolveSanitizesCustomColors() {
        let custom = [PipelineStage(key: "Step", hex: "not-a-color")]
        XCTAssertEqual(Pipeline.resolve(custom).first?.hex, "#888")
    }

    func testNormalizeStateMatchesCaseInsensitively() {
        let r = Pipeline.normalizeState("based", pipeline: pipeline)
        XCTAssertEqual(r.state, "Based")
        XCTAssertNil(r.warning)
    }

    func testNormalizeStateFallsBackToFirstWithWarning() {
        let r = Pipeline.normalizeState("Glittered", pipeline: pipeline)
        XCTAssertEqual(r.state, "Unassembled")
        XCTAssertNotNil(r.warning)
    }

    func testNextReturnsFollowingStageOrNil() {
        XCTAssertEqual(Pipeline.next(after: "Primed", in: pipeline), "Base Coated")
        XCTAssertNil(Pipeline.next(after: "Done", in: pipeline))
        XCTAssertNil(Pipeline.next(after: "Glittered", in: pipeline))
    }

    func testProgressZeroWhenNoModels() {
        XCTAssertEqual(Pipeline.progress(of: [], pipeline), 0)
    }

    func testProgressAcrossSimpleUnits() {
        let units: [any UnitLike] = [
            TestUnit(state: "Unassembled", modelCount: 5),
            TestUnit(state: "Done", modelCount: 5),
        ]
        XCTAssertEqual(Pipeline.progress(of: units, pipeline), 0.5, accuracy: 0.0001)
    }

    func testSegmentsSkipsEmptyStagesAndPreservesPipelineOrder() {
        let units: [any UnitLike] = [
            TestUnit(state: "Primed", modelCount: 3),
            TestUnit(state: "Done", modelCount: 1),
        ]
        let segments = Pipeline.segments(of: units, pipeline)
        XCTAssertEqual(segments.map(\.key), ["Primed", "Done"])
        XCTAssertEqual(segments[0].pct, 75, accuracy: 0.001)
        XCTAssertEqual(segments[1].pct, 25, accuracy: 0.001)
    }

    func testCanAdvanceFalseWhenAllAtFinalStage() {
        let unit = TestUnit(state: "Done", modelCount: 1)
        XCTAssertFalse(Pipeline.canAdvance(unit, pipeline))
    }

    func testAdvanceOneStepMovesSquadDefaultAndClearsRedundantMemberOverrides() {
        let m0 = TestSquadMember(index: 0, state: nil)
        let m1 = TestSquadMember(index: 1, state: "Primed")
        let unit = TestUnit(state: "Primed", modelCount: 2, members: [m0, m1])
        Pipeline.advanceOneStep(unit, pipeline)
        XCTAssertEqual(unit.state, "Base Coated")
        // m0 inherited from the squad before — should jump alongside and stay nil.
        XCTAssertNil(m0.state)
        // m1 had an explicit override at the same value — advances by one, now matches
        // the squad default again, so the override is cleared.
        XCTAssertNil(m1.state)
    }
}
