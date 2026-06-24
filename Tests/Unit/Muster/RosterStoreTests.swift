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

    func testRefreshCatalogPointsUpdatesStaleEntry() throws {
        let roster = try RosterStore.addRoster(
            name: "Points",
            game: "40k",
            faction: "Space Marines",
            battleSizeKey: "incursion",
            linkedArmyId: nil,
            in: context
        )
        let entry = try RosterStore.addEntry(
            from: "40k:space-marines:aggressor-squad",
            to: roster,
            in: context
        )
        entry.pointsEach = 95
        roster.catalogVersion = "2020.01.1"

        let result = RosterStore.refreshCatalogPoints(for: roster, in: context)

        XCTAssertEqual(result.updated, 1)
        XCTAssertEqual(entry.pointsEach, 100)
        XCTAssertEqual(roster.catalogVersion, UnitCatalogLoader.version)
    }

    func testSetPointsEachMarksCustomOverride() throws {
        let roster = try RosterStore.addRoster(
            name: "Custom",
            game: "40k",
            faction: "Space Marines",
            battleSizeKey: "incursion",
            linkedArmyId: nil,
            in: context
        )
        let entry = try RosterStore.addEntry(
            from: "40k:space-marines:captain",
            to: roster,
            in: context
        )
        XCTAssertFalse(entry.usesCustomPoints)

        RosterStore.setPointsEach(entry, 75, in: context)

        XCTAssertEqual(entry.pointsEach, 75)
        XCTAssertTrue(entry.usesCustomPoints)
    }

    func testRefreshCatalogPointsSkipsCustomEntries() throws {
        let roster = try RosterStore.addRoster(
            name: "Skip custom",
            game: "40k",
            faction: "Space Marines",
            battleSizeKey: "incursion",
            linkedArmyId: nil,
            in: context
        )
        let entry = try RosterStore.addEntry(
            from: "40k:space-marines:aggressor-squad",
            to: roster,
            in: context
        )
        entry.pointsEach = 95
        entry.usesCustomPoints = true

        let result = RosterStore.refreshCatalogPoints(for: roster, in: context)

        XCTAssertEqual(result.updated, 0)
        XCTAssertEqual(entry.pointsEach, 95)
        XCTAssertTrue(entry.usesCustomPoints)
    }

    func testResetPointsToCatalog() throws {
        let roster = try RosterStore.addRoster(
            name: "Reset",
            game: "40k",
            faction: "Space Marines",
            battleSizeKey: "incursion",
            linkedArmyId: nil,
            in: context
        )
        let entry = try RosterStore.addEntry(
            from: "40k:space-marines:captain",
            to: roster,
            in: context
        )
        RosterStore.setPointsEach(entry, 75, in: context)
        XCTAssertTrue(entry.usesCustomPoints)

        XCTAssertTrue(RosterStore.resetPointsToCatalog(entry, in: context))
        XCTAssertEqual(entry.pointsEach, 80)
        XCTAssertFalse(entry.usesCustomPoints)
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
