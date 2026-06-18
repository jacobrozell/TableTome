import XCTest
@testable import TabletomeData
@testable import TabletomeDomain

final class SpearheadWarscrollAuditTests: XCTestCase {
    func testFeaturedArmyUnitHealthMatchesSpearheadPDFs() async throws {
        let repository = BundledSpearheadCatalogRepository()
        let catalog = try await repository.loadCatalog()

        let expectedHealth: [String: [String: Int]] = [
            "gnawfeast-clawpack": [
                "clawlord": 7,
                "grey-seer": 5,
                "warlock-engineer": 4,
                "clanrats": 1,
                "rat-ogors": 4
            ],
            "vigilant-brotherhood": [
                "lord-vigilant": 8,
                "lord-veritant": 6,
                "prosecutors": 2,
                "liberators": 2
            ]
        ]

        for army in catalog.factions.flatMap(\.armies) where SpearheadFeaturedArmies.isFeatured(army.id) {
            guard let expectedUnits = expectedHealth[army.id] else {
                XCTFail("Missing health audit fixture for featured army \(army.id)")
                continue
            }
            for unit in army.units {
                guard let expected = expectedUnits[unit.id] else {
                    XCTFail("Missing health audit for \(army.id)/\(unit.id)")
                    continue
                }
                XCTAssertEqual(
                    unit.health,
                    expected,
                    "\(unit.name) health should be \(expected) per Spearhead PDF"
                )
            }
        }
    }

    func testDetailFileUnitsDeclareHealth() async throws {
        let repository = BundledSpearheadCatalogRepository()
        let catalog = try await repository.loadCatalog()

        let armiesWithUnits = catalog.factions
            .flatMap(\.armies)
            .filter { !$0.units.isEmpty }

        XCTAssertFalse(armiesWithUnits.isEmpty)
        for army in armiesWithUnits {
            for unit in army.units {
                XCTAssertNotNil(
                    unit.health,
                    "\(army.id)/\(unit.id) should declare health in the detail overlay"
                )
                XCTAssertGreaterThan(
                    unit.health ?? 0,
                    0,
                    "\(army.id)/\(unit.id) health should be positive"
                )
            }
        }
    }
}
