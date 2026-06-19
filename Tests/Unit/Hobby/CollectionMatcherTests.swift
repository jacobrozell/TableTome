import XCTest
import SwiftData
@testable import TabletomeHobbyData
@testable import TabletomeDomain

@MainActor
final class CollectionMatcherTests: XCTestCase {
    private var context: ModelContext!

    override func setUp() async throws {
        try await super.setUp()
        context = HobbyAppContainer.unitTestContext()
        HobbyAppContainer.resetUnitTestStore()
        UnitCatalogLoader.loadIfNeeded()
    }

    private func requireCatalogUnit(id: String, file: StaticString = #filePath, line: UInt = #line) -> CatalogUnit {
        guard let unit = UnitCatalogLoader.unit(id: id) else {
            XCTFail("Catalog unit \(id) not found — ensure Catalogs are in the test host bundle", file: file, line: line)
            fatalError("Catalog unit required for test")
        }
        return unit
    }

    func testMatchOwnedWhenCollectionHasRequiredModels() {
        _ = requireCatalogUnit(id: "40k:space-marines:captain")
        let entry = RosterEntry(
            catalogUnitId: "40k:space-marines:captain",
            displayName: "Captain",
            qty: 1,
            pointsEach: 80,
            sortIndex: 0
        )
        let unit = ArmyUnit(name: "Captain", state: "Done")

        let result = CollectionMatcher.match(entry: entry, collectionUnits: [unit])

        XCTAssertEqual(result.status, .owned)
        XCTAssertEqual(result.requiredQty, 1)
        XCTAssertEqual(result.ownedQty, 1)
    }

    func testMatchPartialWhenSomeModelsOwned() {
        _ = requireCatalogUnit(id: "40k:space-marines:intercessor-squad")
        let entry = RosterEntry(
            catalogUnitId: "40k:space-marines:intercessor-squad",
            displayName: "Intercessor Squad",
            qty: 1,
            pointsEach: 80,
            sortIndex: 0
        )
        let unit = ArmyUnit(name: "Intercessors (2)", qty: 1, state: "Primed")

        let result = CollectionMatcher.match(entry: entry, collectionUnits: [unit])

        XCTAssertEqual(result.status, .partial)
        XCTAssertEqual(result.requiredQty, 5)
        XCTAssertEqual(result.ownedQty, 2)
    }

    func testMatchOwnedViaAlias() {
        _ = requireCatalogUnit(id: "40k:space-marines:intercessor-squad")
        let entry = RosterEntry(
            catalogUnitId: "40k:space-marines:intercessor-squad",
            displayName: "Intercessor Squad",
            qty: 1,
            pointsEach: 80,
            sortIndex: 0
        )
        let unit = ArmyUnit(name: "Intercessors (5)", qty: 1, state: "Done")

        let result = CollectionMatcher.match(entry: entry, collectionUnits: [unit])

        XCTAssertEqual(result.status, .owned)
        XCTAssertEqual(result.ownedQty, 5)
    }

    func testMatchUnknownWhenCatalogUnitMissing() {
        let entry = RosterEntry(
            catalogUnitId: "missing-unit",
            displayName: "Ghost Unit",
            qty: 1,
            pointsEach: 0,
            sortIndex: 0
        )

        let result = CollectionMatcher.match(entry: entry, collectionUnits: [])

        XCTAssertEqual(result.status, .unknown)
    }

    func testMatchAllScopesUnitsToLinkedArmy() throws {
        _ = requireCatalogUnit(id: "40k:space-marines:captain")

        let linkedArmy = Army(name: "Ultramarines", game: "40k", faction: "Space Marines")
        linkedArmy.units = [ArmyUnit(name: "Captain", state: "Done")]

        let otherArmy = Army(name: "Deathwatch", game: "40k", faction: "Space Marines")
        otherArmy.units = [ArmyUnit(name: "Captain", qty: 3, state: "Done")]

        let roster = Roster(name: "List", game: "40k", faction: "Space Marines", battleSizeKey: "incursion")
        roster.linkedArmyId = linkedArmy.id
        let entry = RosterEntry(
            catalogUnitId: "40k:space-marines:captain",
            displayName: "Captain",
            qty: 1,
            pointsEach: 80,
            sortIndex: 0
        )
        entry.roster = roster
        roster.entries = [entry]

        let results = CollectionMatcher.matchAll(roster: roster, armies: [linkedArmy, otherArmy], in: context)
        let match = try XCTUnwrap(results.first?.1)

        XCTAssertEqual(match.status, .owned)
        XCTAssertEqual(match.ownedQty, 1)
    }

    func testFieldablePercentCountsFullyOwnedEntries() {
        _ = requireCatalogUnit(id: "40k:space-marines:captain")
        _ = requireCatalogUnit(id: "40k:space-marines:librarian")

        let army = Army(name: "Ultramarines", game: "40k", faction: "Space Marines")
        army.units = [
            ArmyUnit(name: "Captain", state: "Done"),
            ArmyUnit(name: "Librarian", state: "Done")
        ]

        let roster = Roster(name: "List", game: "40k", faction: "Space Marines", battleSizeKey: "incursion")
        let captain = RosterEntry(
            catalogUnitId: "40k:space-marines:captain",
            displayName: "Captain",
            qty: 1,
            pointsEach: 80,
            sortIndex: 0
        )
        let librarian = RosterEntry(
            catalogUnitId: "40k:space-marines:librarian",
            displayName: "Librarian",
            qty: 1,
            pointsEach: 65,
            sortIndex: 1
        )
        captain.roster = roster
        librarian.roster = roster
        roster.entries = [captain, librarian]

        let percent = CollectionMatcher.fieldablePercent(roster: roster, armies: [army], in: context)

        XCTAssertEqual(percent, 100)
    }
}
