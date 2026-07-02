import XCTest
@testable import TabletomeDomain

final class SpearheadSetupStepIdTests: XCTestCase {
    func testMigratesLegacyCompletedStepsWhenBothWereMarkedComplete() {
        var completed: Set<String> = ["regiment-abilities", "enhancements", "roll-attacker"]

        SpearheadSetupStepId.migrateLegacyCompletedStepIds(&completed)

        XCTAssertTrue(completed.contains(SpearheadSetupStepId.preBattleLoadout))
        XCTAssertFalse(completed.contains("regiment-abilities"))
        XCTAssertFalse(completed.contains("enhancements"))
        XCTAssertTrue(completed.contains("roll-attacker"))
    }

    func testDoesNotMigrateWhenOnlyOneLegacyStepWasComplete() {
        var completed: Set<String> = ["regiment-abilities", "roll-attacker"]

        SpearheadSetupStepId.migrateLegacyCompletedStepIds(&completed)

        XCTAssertFalse(completed.contains(SpearheadSetupStepId.preBattleLoadout))
        XCTAssertFalse(completed.contains("regiment-abilities"))
        XCTAssertTrue(completed.contains("roll-attacker"))
    }
}
