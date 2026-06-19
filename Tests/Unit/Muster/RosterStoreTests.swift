import XCTest
import SwiftData
@testable import Tabletome
@testable import TabletomeHobbyData
@testable import TabletomeDomain

@MainActor
final class RosterStoreTests: XCTestCase {
    private var context: ModelContext!

    override func setUp() async throws {
        try await super.setUp()
        context = HobbyAppContainer.unitTestContext()
        HobbyAppContainer.resetUnitTestStore()
        UnitCatalogLoader.loadIfNeeded()
    }

    func testAddRosterRejectsEmptyName() {
        XCTAssertThrowsError(
            try RosterStore.addRoster(
                name: "   ",
                game: "40k",
                faction: "Space Marines",
                battleSizeKey: "incursion",
                linkedArmyId: nil,
                in: context
            )
        ) { error in
            XCTAssertEqual(error as? RosterError, .nameEmpty)
        }
    }

    func testAddRosterRejectsDuplicateName() throws {
        _ = try RosterStore.addRoster(
            name: "Ultramarines",
            game: "40k",
            faction: "Space Marines",
            battleSizeKey: "incursion",
            linkedArmyId: nil,
            in: context
        )

        XCTAssertThrowsError(
            try RosterStore.addRoster(
                name: "Ultramarines",
                game: "40k",
                faction: "Space Marines",
                battleSizeKey: "incursion",
                linkedArmyId: nil,
                in: context
            )
        ) { error in
            XCTAssertEqual(error as? RosterError, .nameTaken)
        }
    }

    func testAddEntryMergesDuplicateCatalogUnits() throws {
        let roster = try RosterStore.addRoster(
            name: "Ultramarines",
            game: "40k",
            faction: "Space Marines",
            battleSizeKey: "incursion",
            linkedArmyId: nil,
            in: context
        )
        _ = try RosterStore.addEntry(
            from: "40k:space-marines:captain",
            qty: 1,
            to: roster,
            in: context
        )
        _ = try RosterStore.addEntry(
            from: "40k:space-marines:captain",
            qty: 2,
            to: roster,
            in: context
        )

        XCTAssertEqual(roster.entries.count, 1)
        XCTAssertEqual(roster.entries.first?.qty, 3)
    }

    func testAddEntryRejectsUnknownCatalogUnit() throws {
        let roster = try RosterStore.addRoster(
            name: "Ultramarines",
            game: "40k",
            faction: "Space Marines",
            battleSizeKey: "incursion",
            linkedArmyId: nil,
            in: context
        )

        XCTAssertThrowsError(
            try RosterStore.addEntry(from: "missing-unit", to: roster, in: context)
        ) { error in
            XCTAssertEqual(error as? RosterError, .catalogUnitNotFound)
        }
    }

    func testDuplicateCopiesEntries() throws {
        let roster = try RosterStore.addRoster(
            name: "Ultramarines",
            game: "40k",
            faction: "Space Marines",
            battleSizeKey: "incursion",
            linkedArmyId: nil,
            in: context
        )
        _ = try RosterStore.addEntry(
            from: "40k:space-marines:captain",
            to: roster,
            in: context
        )

        let copy = try RosterStore.duplicate(roster, in: context)

        XCTAssertNotEqual(copy.id, roster.id)
        XCTAssertEqual(copy.orderedEntries.count, 1)
        XCTAssertEqual(copy.orderedEntries.first?.catalogUnitId, "40k:space-marines:captain")
    }

    func testImportMissingToCollectionAddsUnits() throws {
        let roster = try RosterStore.addRoster(
            name: "Ultramarines",
            game: "40k",
            faction: "Space Marines",
            battleSizeKey: "incursion",
            linkedArmyId: nil,
            in: context
        )
        _ = try RosterStore.addEntry(
            from: "40k:space-marines:captain",
            to: roster,
            in: context
        )

        let added = try RosterStore.importMissingToCollection(
            roster: roster,
            pipeline: DefaultPipeline.stages,
            in: context
        )

        XCTAssertEqual(added, 1)
        let armies = try context.fetch(FetchDescriptor<Army>())
        XCTAssertEqual(armies.count, 1)
        XCTAssertEqual(armies.first?.units.first?.name, "Captain")
        XCTAssertEqual(roster.linkedArmyId, armies.first?.id)
    }
}
