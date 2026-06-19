import XCTest
@testable import TabletomeHobbyData

final class RosterPointsTests: XCTestCase {
    private func makeRoster(
        battleSizeKey: String = "strike-force",
        entries: [RosterEntry]
    ) -> Roster {
        let roster = Roster(name: "Test", game: "40k", faction: "Space Marines", battleSizeKey: battleSizeKey)
        for entry in entries {
            entry.roster = roster
        }
        roster.entries = entries
        return roster
    }

    func testTotalSumsEntryPoints() {
        let entries = [
            RosterEntry(catalogUnitId: "a", displayName: "A", qty: 2, pointsEach: 80, sortIndex: 0),
            RosterEntry(catalogUnitId: "b", displayName: "B", qty: 1, pointsEach: 65, sortIndex: 1)
        ]
        XCTAssertEqual(RosterPoints.total(entries), 225)
    }

    func testLimitResolvesFromBattleSize() {
        let combatPatrol = makeRoster(battleSizeKey: "combat-patrol", entries: [])
        XCTAssertEqual(RosterPoints.limit(for: combatPatrol), 500)
        let incursion = makeRoster(battleSizeKey: "incursion", entries: [])
        XCTAssertEqual(RosterPoints.limit(for: incursion), 1000)
        XCTAssertEqual(RosterPoints.limit(for: makeRoster(battleSizeKey: "strike-force", entries: [])), 2000)
        let custom = makeRoster(battleSizeKey: "custom:750", entries: [])
        XCTAssertEqual(RosterPoints.limit(for: custom), 750)
    }

    func testRemainingAndOverLimit() {
        let roster = makeRoster(
            battleSizeKey: "incursion",
            entries: [RosterEntry(catalogUnitId: "a", displayName: "A", qty: 1, pointsEach: 950, sortIndex: 0)]
        )
        XCTAssertEqual(RosterPoints.remaining(for: roster), 50)
        XCTAssertFalse(RosterPoints.isOverLimit(roster))

        roster.entries.append(
            RosterEntry(catalogUnitId: "b", displayName: "B", qty: 1, pointsEach: 100, sortIndex: 1)
        )
        XCTAssertTrue(RosterPoints.isOverLimit(roster))
    }

    func testFillFractionClampsAtOne() {
        let roster = makeRoster(
            battleSizeKey: "incursion",
            entries: [RosterEntry(catalogUnitId: "a", displayName: "A", qty: 1, pointsEach: 2000, sortIndex: 0)]
        )
        XCTAssertEqual(RosterPoints.fillFraction(roster), 1)
    }
}

final class RosterExportTests: XCTestCase {
    func testPlainTextIncludesHeaderTotalsAndEntries() {
        let roster = Roster(name: "Ultramarines", game: "40k", faction: "Space Marines", battleSizeKey: "incursion")
        let entry = RosterEntry(
            catalogUnitId: "40k:space-marines:captain",
            displayName: "Captain",
            qty: 1,
            pointsEach: 80,
            sortIndex: 0
        )
        entry.roster = roster
        roster.entries = [entry]

        let text = RosterExport.plainText(roster: roster, overrides: [])

        XCTAssertTrue(text.contains("Ultramarines — Incursion (1000 pts)"))
        XCTAssertTrue(text.contains("Total: 80 pts"))
        XCTAssertTrue(text.contains("• Captain ×1 — 80 pts"))
        XCTAssertTrue(text.contains("Built with Tabletome"))
    }
}
