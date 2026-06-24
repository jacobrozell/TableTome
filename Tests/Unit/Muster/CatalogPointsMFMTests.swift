import XCTest
@testable import TabletomeDomain

/// Spot-check bundled points against GW Munitorum Field Manual (June 2025 vintage).
final class CatalogPointsMFMTests: XCTestCase {
    override func setUp() {
        super.setUp()
        UnitCatalogLoader.loadIfNeeded()
    }

    func testManifestTracksMFMVintage() {
        XCTAssertEqual(UnitCatalogLoader.pointsKey, "2025-06")
        XCTAssertFalse(UnitCatalogLoader.version.isEmpty)
    }

    func testSpaceMarineJune2025Points() {
        XCTAssertEqual(UnitCatalogLoader.unit(id: "40k:space-marines:aggressor-squad")?.basePoints, 100)
        XCTAssertEqual(UnitCatalogLoader.unit(id: "40k:space-marines:heavy-intercessors")?.basePoints, 100)
        XCTAssertEqual(UnitCatalogLoader.unit(id: "40k:space-marines:hellblaster-squad")?.basePoints, 110)
        XCTAssertEqual(UnitCatalogLoader.unit(id: "40k:space-marines:captain")?.basePoints, 80)
    }

    func testGreyKnightsMFMPoints() {
        XCTAssertEqual(UnitCatalogLoader.unit(id: "40k:grey-knights:brotherhood-librarian")?.basePoints, 120)
        XCTAssertEqual(UnitCatalogLoader.unit(id: "40k:grey-knights:interceptor-squad")?.basePoints, 125)
        XCTAssertEqual(UnitCatalogLoader.unit(id: "40k:grey-knights:strike-squad")?.basePoints, 120)
    }

    func testChaosSpaceMarineMFMPoints() {
        XCTAssertEqual(UnitCatalogLoader.unit(id: "40k:chaos-space-marines:abaddon-the-despoiler")?.basePoints, 280)
        XCTAssertEqual(UnitCatalogLoader.unit(id: "40k:chaos-space-marines:legionaries")?.basePoints, 90)
    }
}
