import XCTest
@testable import TabletomeDomain

/// Guarantees simulated dice rolls and the combat engine always agree.
final class CombatSimulatorTrustTests: XCTestCase {
    func testSimulatorMatchesEngineForRepresentativeScenarios() {
        for fixture in TrustFixture.all {
            let result = CombatRollSimulator.rollAndEvaluate(
                parameters: fixture.parameters,
                d6Faces: fixture.d6Faces,
                variableDamageFaces: fixture.variableDamageFaces
            )

            XCTAssertEqual(
                result.rolls.rolls.count,
                fixture.expectedRollCount,
                fixture.name
            )
            XCTAssertEqual(
                result.evaluation.damageDealt,
                fixture.expectedDamage,
                fixture.name
            )
            XCTAssertEqual(
                result.evaluation.damageDealt,
                manualEvaluation(from: result.rolls, parameters: fixture.parameters).damageDealt,
                "\(fixture.name): simulator must match manual engine input"
            )
        }
    }

    func testResolutionPredicatesMatchEngineSteps() {
        for fixture in TrustFixture.all {
            let result = CombatRollSimulator.rollAndEvaluate(
                parameters: fixture.parameters,
                d6Faces: fixture.d6Faces,
                variableDamageFaces: fixture.variableDamageFaces
            )
            let input = CombatRollResolution.input(
                from: fixture.parameters,
                hitRoll: result.rolls.hitRoll,
                woundRoll: result.rolls.woundRoll,
                saveRoll: result.rolls.saveRoll,
                wardRoll: result.rolls.wardRoll,
                damage: result.rolls.damage
            )

            XCTAssertEqual(
                result.evaluation.steps.first { $0.id == "hit" }?.outcome,
                CombatRollResolution.hitSucceeded(input) ? .success : .failure
            )

            if CombatRollResolution.hitSucceeded(input) {
                XCTAssertEqual(
                    result.evaluation.steps.first { $0.id == "wound" }?.outcome,
                    CombatRollResolution.woundSucceeded(input) ? .success : .failure
                )
            }

            if CombatRollResolution.damageWouldBeDealt(input) {
                XCTAssertEqual(result.evaluation.steps.last?.id, "damage")
            }
        }
    }

    func testEngineDamageMatchesResolutionPredicate() {
        let inputs: [AttackRollInput] = [
            AttackRollInput(
                hitTarget: 4, woundTarget: 4, saveTarget: 4, rend: 0, damage: 2,
                hitRoll: 4, woundRoll: 4, saveRoll: 2
            ),
            AttackRollInput(
                hitTarget: 4, woundTarget: 4, saveTarget: 4, rend: -1, damage: 3,
                hitRoll: 6, woundRoll: 1, saveRoll: 4,
                critAutoWound: true
            ),
            AttackRollInput(
                hitTarget: 4, woundTarget: 4, saveTarget: 5, rend: 0, damage: 1,
                hitRoll: 4, woundRoll: 4, saveRoll: 3,
                wardTarget: 5, wardRoll: 5
            ),
            AttackRollInput(
                hitTarget: 4, woundTarget: 4, saveTarget: 4, rend: 0, damage: 4,
                hitRoll: 4, woundRoll: 6, saveRoll: 4,
                critMortal: true
            ),
            AttackRollInput(
                hitTarget: 4, woundTarget: 4, saveTarget: 4, rend: 0, damage: 2,
                hitRoll: 4, woundRoll: 4, saveRoll: 4,
                mortalDamage: true
            ),
        ]

        for input in inputs {
            let evaluation = CombatRollEngine.evaluate(input)
            let expectedDamage = CombatRollResolution.damageWouldBeDealt(input) ? input.damage : 0
            XCTAssertEqual(evaluation.damageDealt, expectedDamage)
        }
    }

    func testCritAutoWoundNeverRollsWoundDie() {
        var parameters = TrustFixture.successfulHit.parameters
        parameters.critAutoWound = true
        let result = CombatRollSimulator.rollAndEvaluate(
            parameters: parameters,
            d6Faces: [6, 2, 2]
        )
        XCTAssertFalse(result.rolls.rolls.contains { $0.purpose == .wound })
        XCTAssertTrue(result.evaluation.steps.contains { $0.id == "wound" && $0.outcome == .success })
    }

    func testMortalDamageSkipsSaveRoll() {
        var parameters = TrustFixture.successfulHit.parameters
        parameters.mortalDamage = true
        let result = CombatRollSimulator.rollAndEvaluate(
            parameters: parameters,
            d6Faces: [4, 4, 2]
        )
        XCTAssertEqual(result.rolls.rolls.map(\.purpose), [.hit, .wound])
        XCTAssertEqual(result.evaluation.damageDealt, parameters.damage)
    }

    func testRendAppliedToSave() {
        var parameters = TrustFixture.successfulHit.parameters
        parameters.rend = -1
        parameters.saveTarget = 4
        let result = CombatRollSimulator.rollAndEvaluate(
            parameters: parameters,
            d6Faces: [4, 4, 4]
        )
        XCTAssertEqual(result.evaluation.damageDealt, parameters.damage)
        XCTAssertTrue(result.evaluation.steps.first { $0.id == "save" }?.outcome == .failure)
    }

    func testPositiveRendImprovesSave() {
        let input = AttackRollInput(
            hitTarget: 4, woundTarget: 4, saveTarget: 4, rend: 1, damage: 2,
            hitRoll: 4, woundRoll: 4, saveRoll: 3
        )
        XCTAssertEqual(CombatRollEngine.evaluate(input).damageDealt, 0)
    }

    private func manualEvaluation(
        from rolls: SimulatedAttackRolls,
        parameters: AttackRollParameters
    ) -> AttackRollEvaluation {
        let input = CombatRollResolution.input(
            from: parameters,
            hitRoll: rolls.hitRoll,
            woundRoll: rolls.woundRoll,
            saveRoll: rolls.saveRoll,
            wardRoll: rolls.wardRoll,
            damage: rolls.damage
        )
        return CombatRollEngine.evaluate(input)
    }
}

private struct TrustFixture {
    let name: String
    let parameters: AttackRollParameters
    let d6Faces: [Int]
    let variableDamageFaces: [Int]
    let expectedRollCount: Int
    let expectedDamage: Int

    static let successfulHit = TrustFixture(
        name: "failed hit stops sequence",
        parameters: AttackRollParameters(
            hitTarget: 4, woundTarget: 4, saveTarget: 4, rend: 0, damage: 1
        ),
        d6Faces: [1],
        variableDamageFaces: [],
        expectedRollCount: 1,
        expectedDamage: 0
    )

    static let all: [TrustFixture] = [
        successfulHit,
        TrustFixture(
            name: "failed wound stops before save",
            parameters: AttackRollParameters(
                hitTarget: 4, woundTarget: 4, saveTarget: 4, rend: 0, damage: 2
            ),
            d6Faces: [4, 2],
            variableDamageFaces: [],
            expectedRollCount: 2,
            expectedDamage: 0
        ),
        TrustFixture(
            name: "successful save prevents damage",
            parameters: AttackRollParameters(
                hitTarget: 4, woundTarget: 4, saveTarget: 4, rend: 0, damage: 2
            ),
            d6Faces: [4, 4, 5],
            variableDamageFaces: [],
            expectedRollCount: 3,
            expectedDamage: 0
        ),
        TrustFixture(
            name: "failed save deals damage",
            parameters: AttackRollParameters(
                hitTarget: 4, woundTarget: 4, saveTarget: 4, rend: 0, damage: 2
            ),
            d6Faces: [4, 4, 2],
            variableDamageFaces: [],
            expectedRollCount: 3,
            expectedDamage: 2
        ),
        TrustFixture(
            name: "ward prevents damage",
            parameters: AttackRollParameters(
                hitTarget: 4, woundTarget: 4, saveTarget: 4, rend: 0, damage: 2,
                wardTarget: 4
            ),
            d6Faces: [4, 4, 2, 5],
            variableDamageFaces: [],
            expectedRollCount: 4,
            expectedDamage: 0
        ),
        TrustFixture(
            name: "failed ward deals damage",
            parameters: AttackRollParameters(
                hitTarget: 4, woundTarget: 4, saveTarget: 4, rend: 0, damage: 2,
                wardTarget: 4
            ),
            d6Faces: [4, 4, 2, 2],
            variableDamageFaces: [],
            expectedRollCount: 4,
            expectedDamage: 2
        ),
        TrustFixture(
            name: "variable d6 damage applied",
            parameters: AttackRollParameters(
                hitTarget: 4, woundTarget: 4, saveTarget: 4, rend: 0, damage: 1,
                variableDamage: .d6
            ),
            d6Faces: [4, 4, 2],
            variableDamageFaces: [5],
            expectedRollCount: 4,
            expectedDamage: 5
        ),
        TrustFixture(
            name: "variable d3 damage applied",
            parameters: AttackRollParameters(
                hitTarget: 4, woundTarget: 4, saveTarget: 4, rend: 0, damage: 1,
                variableDamage: .d3
            ),
            d6Faces: [4, 4, 2, 5],
            variableDamageFaces: [],
            expectedRollCount: 4,
            expectedDamage: 3
        ),
        TrustFixture(
            name: "crit mortal skips save and deals mortal damage",
            parameters: AttackRollParameters(
                hitTarget: 4, woundTarget: 4, saveTarget: 4, rend: 0, damage: 3,
                critMortal: true
            ),
            d6Faces: [4, 6],
            variableDamageFaces: [],
            expectedRollCount: 2,
            expectedDamage: 3
        ),
        TrustFixture(
            name: "hit modifier capped but still hits",
            parameters: AttackRollParameters(
                hitTarget: 4, woundTarget: 4, saveTarget: 4, rend: 0, damage: 1,
                hitModifier: 5
            ),
            d6Faces: [3, 4, 2],
            variableDamageFaces: [],
            expectedRollCount: 3,
            expectedDamage: 1
        ),
    ]
}
