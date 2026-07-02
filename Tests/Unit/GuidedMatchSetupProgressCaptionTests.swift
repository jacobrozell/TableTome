import XCTest
@testable import TabletomeDomain

final class GuidedMatchSetupProgressCaptionTests: XCTestCase {
    func testSummaryIncludesDoneAndNextSteps() {
        var state = GuidedMatchState()
        state.completedStepIds = ["choose-armies", "roll-attacker"]
        let steps = [
            MatchSetupStep(
                id: "choose-armies",
                order: 1,
                title: "Choose armies",
                summary: "",
                body: ""
            ),
            MatchSetupStep(
                id: "roll-attacker",
                order: 2,
                title: "Roll attacker",
                summary: "",
                body: ""
            ),
            MatchSetupStep(
                id: "regiment-abilities",
                order: 3,
                title: "Regiment abilities",
                summary: "",
                body: ""
            ),
        ]

        let summary = GuidedMatchSetupProgressCaption.summary(matchState: state, steps: steps)

        XCTAssertNotNil(summary)
        XCTAssertTrue(summary?.contains("2 of 3 complete") == true)
        XCTAssertTrue(summary?.contains("Choose armies") == true)
        XCTAssertTrue(summary?.contains("Regiment abilities") == true)
    }

    func testSummaryNilWhenSetupComplete() {
        var state = GuidedMatchState()
        state.completedStepIds = ["choose-armies", "roll-attacker"]
        let steps = [
            MatchSetupStep(
                id: "choose-armies",
                order: 1,
                title: "Choose armies",
                summary: "",
                body: ""
            ),
            MatchSetupStep(
                id: "roll-attacker",
                order: 2,
                title: "Roll attacker",
                summary: "",
                body: ""
            ),
        ]

        XCTAssertNil(GuidedMatchSetupProgressCaption.summary(matchState: state, steps: steps))
    }
}
