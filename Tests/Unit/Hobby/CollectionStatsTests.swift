import XCTest
@testable import TabletomeDomain

final class HobbyCollectionStatsTests: XCTestCase {
    func testSnapshotCountsBucketsAndOverallPercent() {
        let pipeline = DefaultPipeline.stages
        let units: [any UnitLike] = [
            TestUnit(state: "Unassembled", modelCount: 5), // todo
            TestUnit(state: "Primed", modelCount: 5),      // wip
            TestUnit(state: "Based", modelCount: 5),       // based + done bucket
            TestUnit(state: "Done", modelCount: 5),        // done
        ]
        let snap = CollectionStats.snapshot(units: units, pipeline: pipeline)
        XCTAssertEqual(snap.unitEntries, 4)
        XCTAssertEqual(snap.models, 20)
        XCTAssertEqual(snap.todo, 1)
        XCTAssertEqual(snap.wip, 1)
        XCTAssertEqual(snap.based, 1)
        XCTAssertEqual(snap.done, 1)
        XCTAssertGreaterThan(snap.overallPercent, 0)
        XCTAssertEqual(Set(snap.segments.map(\.key)),
                       ["Unassembled", "Primed", "Based", "Done"])
    }

    func testSnapshotEmptyCollection() {
        let snap = CollectionStats.snapshot(units: [], pipeline: DefaultPipeline.stages)
        XCTAssertEqual(snap.models, 0)
        XCTAssertEqual(snap.overallPercent, 0)
        XCTAssertTrue(snap.segments.isEmpty)
    }
}
