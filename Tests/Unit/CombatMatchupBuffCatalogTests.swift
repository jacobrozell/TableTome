import XCTest
@testable import TabletomeDomain

final class CombatMatchupBuffCatalogTests: XCTestCase {
    func testParsesWardFromKeyword() {
        let unit = SpearheadUnit(
            id: "grey-seer",
            name: "Grey Seer",
            save: 5,
            keywords: ["Ward (6+)"]
        )

        let buffs = CombatMatchupBuffCatalog.buffs(for: unit, side: .defender)

        XCTAssertTrue(buffs.contains { $0.wardTarget == 6 })
    }

    func testParsesWardFromAbilityEffect() {
        let unit = SpearheadUnit(
            id: "clawlord",
            name: "Clawlord",
            save: 4,
            abilities: [
                TriggeredAbility(
                    id: "warp-shield",
                    name: "Warp-shield",
                    source: "Clawlord",
                    phases: [.hero],
                    usageLimit: .oncePerBattle,
                    effect: "This unit has Ward (5+) until the start of your next turn.",
                    kind: .ability
                )
            ]
        )

        let buffs = CombatMatchupBuffCatalog.buffs(for: unit, side: .defender)

        XCTAssertTrue(buffs.contains { $0.wardTarget == 5 })
    }

    func testGenericWardBuffsAvailableForDefender() {
        let buffs = CombatMatchupBuffCatalog.genericBuffs(for: .defender)

        XCTAssertTrue(buffs.contains { $0.id == "generic-defender-ward-5" })
    }
}
