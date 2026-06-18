import XCTest
@testable import TabletomeDomain

final class VariableAttackRollEngineTests: XCTestCase {
    func testRollsD6PerModel() {
        var generator = SeededGenerator(seed: 42)
        let outcome = VariableAttackRollEngine.roll(expression: "D6", modelCount: 3, generator: &generator)
        XCTAssertEqual(outcome.perModelTotals.count, 3)
        XCTAssertEqual(outcome.totalAttacks, outcome.perModelTotals.reduce(0, +))
    }

    func testRolls2D6PerModel() {
        var generator = SeededGenerator(seed: 7)
        let outcome = VariableAttackRollEngine.roll(expression: "2D6", modelCount: 1, generator: &generator)
        XCTAssertEqual(outcome.perModelTotals.count, 1)
        XCTAssertGreaterThanOrEqual(outcome.totalAttacks, 2)
        XCTAssertLessThanOrEqual(outcome.totalAttacks, 12)
    }

    func testModelsWithWeaponDefaultDeployedCount() {
        let unit = SpearheadUnit(
            id: "rat-ogors",
            name: "Rat Ogors",
            health: 4,
            modelCount: 3,
            weapons: [
                SpearheadWeapon(
                    id: "warpfire-gun",
                    name: "Warpfire Gun",
                    rangeInches: 10,
                    attacks: "2D6",
                    hit: 2,
                    wound: 4,
                    rend: 2,
                    damage: "1",
                    modelsWithWeapon: 1
                )
            ]
        )
        let weapon = unit.weapons[0]
        XCTAssertEqual(WeaponAttackRollCount.defaultDeployedModelCount(for: unit, weapon: weapon), 1)
    }

    func testResolvedAttackCountUpdatesHitDicePlan() {
        let weapon = SpearheadWeapon(
            id: "warpfire-gun",
            name: "Warpfire Gun",
            rangeInches: 10,
            attacks: "2D6",
            hit: 2,
            wound: 4,
            rend: 2,
            damage: "1"
        )
        let plan = WeaponAttackRollCount.hitDicePlan(
            weapon: weapon,
            deployedModelCount: 1,
            resolvedAttackCount: 9
        )
        XCTAssertEqual(plan.fixedTotalHitDice, 9)
        XCTAssertTrue(plan.summary.contains("9"))
    }

    func testPerModelRollAccumulatesTotals() {
        var generator = SeededGenerator(seed: 99)
        let first = VariableAttackRollEngine.roll(expression: "D6", modelCount: 1, generator: &generator)
        let second = VariableAttackRollEngine.roll(expression: "D6", modelCount: 1, generator: &generator)
        let combined = first.perModelTotals + second.perModelTotals
        XCTAssertEqual(combined.count, 2)
        XCTAssertEqual(combined.reduce(0, +), first.totalAttacks + second.totalAttacks)
    }
}

private struct SeededGenerator: RandomNumberGenerator {
    var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        return state
    }
}
