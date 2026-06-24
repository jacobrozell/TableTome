import XCTest
@testable import TabletomeDomain

final class RosterCatalogSyncTests: XCTestCase {
    override func setUp() {
        super.setUp()
        UnitCatalogLoader.loadIfNeeded()
    }

    func testDetectsPointsDrift() {
        let status = RosterCatalogSync.status(
            entries: [
                RosterCatalogSync.EntrySnapshot(catalogUnitId: "40k:space-marines:captain", pointsEach: 70)
            ],
            rosterCatalogVersion: UnitCatalogLoader.version
        )
        XCTAssertTrue(status.hasPointsDrift)
        XCTAssertEqual(status.driftCount, 1)
        XCTAssertEqual(status.driftedEntries.first?.catalogPoints, 80)
    }

    func testDetectsCatalogVersionDrift() {
        let status = RosterCatalogSync.status(
            entries: [
                RosterCatalogSync.EntrySnapshot(catalogUnitId: "40k:space-marines:captain", pointsEach: 80)
            ],
            rosterCatalogVersion: "2020.01.1"
        )
        XCTAssertTrue(status.hasVersionDrift)
        XCTAssertTrue(status.needsRefresh)
    }

    func testCurrentEntriesDoNotNeedRefresh() {
        guard let captain = UnitCatalogLoader.unit(id: "40k:space-marines:captain") else {
            return XCTFail("missing captain")
        }
        let status = RosterCatalogSync.status(
            entries: [
                RosterCatalogSync.EntrySnapshot(catalogUnitId: captain.id, pointsEach: captain.basePoints)
            ],
            rosterCatalogVersion: UnitCatalogLoader.version
        )
        XCTAssertFalse(status.needsRefresh)
    }
}
