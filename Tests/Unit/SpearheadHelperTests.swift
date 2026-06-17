import XCTest
@testable import TabletomeDomain

final class BattleRoundChecklistTests: XCTestCase {
    func testRoundOneFirstTurnTitle() {
        let step = BattleRoundChecklistStep.firstTurnOrPriority
        XCTAssertTrue(step.title(round: 1).contains("Attacker"))
        XCTAssertTrue(step.title(round: 2).contains("Priority"))
    }

    func testCompletionTracking() {
        var completed: [String: Set<String>] = [:]
        let round = 1
        let key = BattleRoundChecklist.storageKey(round: round)
        completed[key] = [BattleRoundChecklistStep.drawTwistCard.rawValue]
        XCTAssertTrue(BattleRoundChecklist.isComplete(step: .drawTwistCard, round: round, completedSteps: completed))
        XCTAssertFalse(BattleRoundChecklist.isComplete(step: .identifyUnderdog, round: round, completedSteps: completed))
        XCTAssertEqual(BattleRoundChecklist.completionCount(round: round, completedSteps: completed).done, 1)
    }
}

final class UnitWoundCapacityTests: XCTestCase {
    func testCapacityUsesModelCount() {
        let unit = SpearheadUnit(id: "liberators", name: "Liberators", health: 2, modelCount: 5)
        XCTAssertEqual(UnitWoundCapacity.capacity(for: unit), 10)
    }

    func testHeroDefaultsToSingleModel() {
        let unit = SpearheadUnit(id: "grey-seer", name: "Grey Seer", health: 5)
        XCTAssertEqual(UnitWoundCapacity.capacity(for: unit), 5)
    }
}

final class SpearheadGotchaCatalogTests: XCTestCase {
    func testFeaturedArmiesHaveGotchas() {
        XCTAssertFalse(SpearheadGotchaCatalog.gotchas(for: "vigilant-brotherhood").isEmpty)
        XCTAssertFalse(SpearheadGotchaCatalog.gotchas(for: "gnawfeast-clawpack").isEmpty)
        XCTAssertTrue(SpearheadGotchaCatalog.gotchas(for: "unknown").isEmpty)
    }
}

final class DeploymentChecklistTests: XCTestCase {
    func testDeploymentStepsComplete() {
        var completed: Set<String> = [DeploymentChecklistStep.setupTerrain.rawValue]
        XCTAssertTrue(DeploymentChecklist.isComplete(step: .setupTerrain, completedSteps: completed))
        XCTAssertEqual(DeploymentChecklist.completionCount(completedSteps: completed).done, 1)
    }
}

final class SpearheadRulesGlossaryTests: XCTestCase {
    func testFindsReferencedTerms() {
        let entries = SpearheadRulesGlossary.entriesReferenced(
            in: "Pick a visible enemy wholly within 12\" contesting an objective."
        )
        XCTAssertTrue(entries.contains { $0.id == "visible" })
        XCTAssertTrue(entries.contains { $0.id == "wholly-within" })
        XCTAssertTrue(entries.contains { $0.id == "contest" })
    }

    func testFindsNewPlayerTerms() {
        let entries = SpearheadRulesGlossary.entriesReferenced(
            in: "Review your warscroll, pick a regiment ability, and draw a twist card for victory points."
        )
        XCTAssertTrue(entries.contains { $0.id == "warscroll" })
        XCTAssertTrue(entries.contains { $0.id == "regiment-ability" })
        XCTAssertTrue(entries.contains { $0.id == "twist-card" })
        XCTAssertTrue(entries.contains { $0.id == "victory-points" })
    }

    func testGlossaryHasNewcomerEntries() {
        XCTAssertGreaterThanOrEqual(SpearheadRulesGlossary.entries.count, 16)
    }

    func testBattleTacticsReferenceHasSections() {
        XCTAssertFalse(SpearheadBattleTacticsReference.sections.isEmpty)
    }
}

final class CombatRollOptionsTests: XCTestCase {
    func testWeaponParsesCritMortal() {
        let weapon = SpearheadWeapon(
            id: "warhammer",
            name: "Warhammer",
            attacks: "2",
            hit: 3,
            wound: 3,
            rend: 1,
            damage: "1",
            ability: "Crit (Mortal)"
        )
        XCTAssertTrue(weapon.hasCritMortal)
        XCTAssertEqual(CombatRollOptions.from(weapon: weapon).critMortal, true)
    }

    func testCritMortalSkipsSave() {
        let input = AttackRollInput(
            hitTarget: 3, woundTarget: 3, saveTarget: 4, rend: 0, damage: 2,
            hitRoll: 4, woundRoll: 6, saveRoll: 6,
            critMortal: true
        )
        let result = CombatRollEngine.evaluate(input)
        XCTAssertEqual(result.damageDealt, 2)
        XCTAssertTrue(result.steps.contains { $0.id == "save" && $0.explanation.contains("Mortal") })
    }

    func testCritAutoWoundOnHitSix() {
        let input = AttackRollInput(
            hitTarget: 3, woundTarget: 4, saveTarget: 4, rend: 0, damage: 1,
            hitRoll: 6, woundRoll: 1, saveRoll: 3,
            critAutoWound: true
        )
        let result = CombatRollEngine.evaluate(input)
        XCTAssertGreaterThan(result.damageDealt, 0)
    }
}
