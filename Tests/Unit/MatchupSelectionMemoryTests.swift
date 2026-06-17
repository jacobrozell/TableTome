import XCTest
@testable import TabletomeDomain

final class MatchupSelectionMemoryTests: XCTestCase {
    private let armyId = "test-army"

    override func tearDown() {
        MatchupSelectionMemory.resetAll()
        super.tearDown()
    }

    func testRemembersAttackerSelection() {
        MatchupSelectionMemory.saveAttacker(armyId: armyId, unitId: "unit-a", weaponId: "weapon-a")
        let selection = MatchupSelectionMemory.attackerSelection(for: armyId)
        XCTAssertEqual(selection?.unitId, "unit-a")
        XCTAssertEqual(selection?.weaponId, "weapon-a")
    }

    func testRemembersDefenderSelection() {
        MatchupSelectionMemory.saveDefender(armyId: armyId, unitId: "unit-b")
        XCTAssertEqual(MatchupSelectionMemory.defenderUnitId(for: armyId), "unit-b")
    }
}
