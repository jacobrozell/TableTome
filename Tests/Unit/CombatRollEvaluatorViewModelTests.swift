import XCTest
@testable import Tabletome
@testable import TabletomeDomain

@MainActor
final class CombatRollEvaluatorViewModelTests: XCTestCase {
    func testEvaluateProducesSteps() {
        let viewModel = CombatRollEvaluatorViewModel()
        viewModel.hitRoll = 4
        viewModel.woundRoll = 5
        viewModel.saveRoll = 3
        viewModel.saveTarget = 5
        viewModel.rend = -1
        viewModel.damage = 2

        viewModel.evaluate()

        XCTAssertNotNil(viewModel.evaluation)
        XCTAssertEqual(viewModel.evaluation?.damageDealt, 2)
        XCTAssertEqual(viewModel.evaluation?.steps.count, 4)
    }

    func testClearResultsOnInputChange() {
        let viewModel = CombatRollEvaluatorViewModel()
        viewModel.evaluate()
        XCTAssertNotNil(viewModel.evaluation)

        viewModel.clearResults()
        XCTAssertNil(viewModel.evaluation)
    }

    func testResetAllRestoresDefaults() {
        let viewModel = CombatRollEvaluatorViewModel()
        viewModel.hitTarget = 2
        viewModel.hitRoll = 1
        viewModel.evaluate()

        viewModel.resetAll()

        XCTAssertEqual(viewModel.hitTarget, 4)
        XCTAssertEqual(viewModel.hitRoll, 4)
        XCTAssertNil(viewModel.evaluation)
    }
}
