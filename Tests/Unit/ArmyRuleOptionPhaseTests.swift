import XCTest
@testable import TabletomeDomain

final class ArmyRuleOptionPhaseTests: XCTestCase {
    func testMatchesExplicitPhase() {
        let option = ArmyRuleOption(
            id: "test",
            name: "Test",
            summary: "Summary",
            phases: [.hero]
        )
        XCTAssertTrue(option.matches(phase: .hero))
        XCTAssertFalse(option.matches(phase: .movement))
    }

    func testEmptyPhasesDoNotMatch() {
        let option = ArmyRuleOption(
            id: "test",
            name: "Test",
            summary: "Summary",
            phases: []
        )
        XCTAssertFalse(option.isAvailableIn(phase: .hero))
    }
}
