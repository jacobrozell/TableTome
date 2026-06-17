import XCTest
@testable import TabletomeDomain

final class CombatMatchupBuffCatalogTests: XCTestCase {
    func testParsesWardFromKeywords() {
        let unit = SpearheadUnit(
            id: "clawlord",
            name: "Clawlord",
            keywords: ["Hero", "Ward (6+)"]
        )
        let buffs = CombatMatchupBuffCatalog.buffs(for: unit, side: .defender)
        XCTAssertTrue(buffs.contains { $0.id == "clawlord-ward-6" && $0.wardTarget == 6 })
    }

    func testParsesHitBuffFromAbilityEffect() {
        let unit = SpearheadUnit(
            id: "lord-vigilant",
            name: "Lord-Vigilant",
            abilities: [
                TriggeredAbility(
                    id: "plan-the-attack",
                    name: "Plan the Attack",
                    source: "Lord-Vigilant",
                    phases: [.hero],
                    usageLimit: .eachTurn,
                    effect: "Add 1 to hit rolls for combat attacks."
                )
            ]
        )
        let buffs = CombatMatchupBuffCatalog.buffs(for: unit, side: .attacker)
        XCTAssertTrue(buffs.contains { $0.name == "Plan the Attack" && $0.hitModifier == 1 })
    }

    func testAggregateModifiersSumsEnabledBuffs() {
        let buffs = [
            CombatMatchupBuff(
                id: "hit",
                name: "Hit",
                summary: "",
                side: .attacker,
                hitModifier: 1,
                source: "Test"
            ),
            CombatMatchupBuff(
                id: "save",
                name: "Save",
                summary: "",
                side: .defender,
                saveModifier: -1,
                source: "Test"
            ),
            CombatMatchupBuff(
                id: "ward",
                name: "Ward",
                summary: "",
                side: .defender,
                wardTarget: 5,
                source: "Test"
            )
        ]
        let mods = CombatMatchupBuffCatalog.aggregateModifiers(from: buffs, enabledIds: ["hit", "save", "ward"])
        XCTAssertEqual(mods.hit, 1)
        XCTAssertEqual(mods.save, -1)
        XCTAssertEqual(mods.wardTarget, 5)
    }
}
