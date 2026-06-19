import XCTest
@testable import TabletomeDomain

final class CombatPatrolStratagemPhaseTests: XCTestCase {
    func testCommandStratagemMatchesCommandPhase() {
        let stratagem = CombatPatrolStratagem(
            id: "duty-and-honour",
            name: "Duty and Honour",
            summary: "Lock objective.",
            cpCost: 1,
            phase: "Command"
        )
        XCTAssertTrue(stratagem.matches(battlePhase: .command))
        XCTAssertFalse(stratagem.matches(battlePhase: .movement))
    }

    func testShootingOrFightMatchesBothPhases() {
        let stratagem = CombatPatrolStratagem(
            id: "hyper-reactive",
            name: "Hyper-reactive",
            summary: "Subtract 1 from Hit rolls.",
            cpCost: 1,
            phase: "Shooting or Fight",
            isReactive: true
        )
        XCTAssertTrue(stratagem.matches(battlePhase: .shooting))
        XCTAssertTrue(stratagem.matches(battlePhase: .combat))
        XCTAssertFalse(stratagem.matches(battlePhase: .command))
    }

    func testNilPhaseDefaultsToCommand() {
        let stratagem = CombatPatrolStratagem(
            id: "generic",
            name: "Generic",
            summary: "Summary"
        )
        XCTAssertTrue(stratagem.matches(battlePhase: .command))
        XCTAssertFalse(stratagem.matches(battlePhase: .movement))
    }
}
