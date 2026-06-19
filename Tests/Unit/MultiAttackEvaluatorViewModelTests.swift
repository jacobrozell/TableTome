import XCTest
@testable import Tabletome
@testable import TabletomeDomain

@MainActor
final class MultiAttackEvaluatorViewModelTests: XCTestCase {
    func testEvaluateCurrentAttackAppendsResult() {
        let viewModel = MultiAttackEvaluatorViewModel()
        viewModel.attackCount = 2
        viewModel.hitRoll = 6
        viewModel.woundRoll = 6
        viewModel.saveRoll = 2
        viewModel.saveTarget = 5
        viewModel.damage = 1

        viewModel.evaluateCurrentAttack()

        XCTAssertEqual(viewModel.results.count, 1)
        XCTAssertEqual(viewModel.attacksRemaining, 1)
        XCTAssertFalse(viewModel.isSequenceComplete)
        XCTAssertEqual(viewModel.lastEvaluation?.damageDealt, 1)
    }

    func testResolveBatchHitsAdvancesSequence() {
        let viewModel = MultiAttackEvaluatorViewModel()
        viewModel.attackCount = 3
        viewModel.hitRoll = 6
        viewModel.woundRoll = 6
        viewModel.saveRoll = 2
        viewModel.saveTarget = 5
        viewModel.damage = 1

        viewModel.resolveBatchHits(2)

        XCTAssertEqual(viewModel.results.count, 2)
        XCTAssertEqual(viewModel.totalDamage, 2)
    }

    func testResetSequenceClearsResults() {
        let viewModel = MultiAttackEvaluatorViewModel()
        viewModel.evaluateCurrentAttack()

        viewModel.resetSequence()

        XCTAssertTrue(viewModel.results.isEmpty)
        XCTAssertNil(viewModel.lastEvaluation)
        XCTAssertEqual(viewModel.currentAttackIndex, 0)
    }
}
