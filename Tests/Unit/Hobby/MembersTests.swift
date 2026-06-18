import XCTest
@testable import TabletomeDomain

final class HobbyMembersTests: XCTestCase {
    func testEffectiveStateFallsBackToSquadDefault() {
        let unit = TestUnit(state: "Primed", modelCount: 2,
                            members: [
                                TestSquadMember(index: 0),
                                TestSquadMember(index: 1, state: "Done"),
                            ])
        XCTAssertEqual(Members.effectiveState(of: unit, at: 0), "Primed")
        XCTAssertEqual(Members.effectiveState(of: unit, at: 1), "Done")
    }

    func testStateSummarySortedByCountThenKey() {
        let unit = TestUnit(state: "Primed", modelCount: 4,
                            members: [
                                TestSquadMember(index: 0, state: "Based"),
                                TestSquadMember(index: 1, state: "Based"),
                                TestSquadMember(index: 2, state: "Based"),
                                TestSquadMember(index: 3, state: "Primed"),
                            ])
        XCTAssertEqual(Members.stateSummary(of: unit), "3× Based, 1× Primed")
    }

    func testUnitPassesQuickViewClassifications() {
        let pipeline = DefaultPipeline.stages
        let backlog = TestUnit(state: "Unassembled", modelCount: 1)
        let wip = TestUnit(state: "Primed", modelCount: 1)
        let ready = TestUnit(state: "Done", modelCount: 1)
        XCTAssertTrue(Members.unitPassesQuickView(backlog, pipeline: pipeline, quickView: "backlog"))
        XCTAssertTrue(Members.unitPassesQuickView(wip, pipeline: pipeline, quickView: "wip"))
        XCTAssertTrue(Members.unitPassesQuickView(ready, pipeline: pipeline, quickView: "ready"))
        XCTAssertFalse(Members.unitPassesQuickView(backlog, pipeline: pipeline, quickView: "ready"))
    }
}
