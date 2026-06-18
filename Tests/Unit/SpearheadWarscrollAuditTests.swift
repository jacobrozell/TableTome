import XCTest
@testable import TabletomeData
@testable import TabletomeDomain

final class SpearheadWarscrollAuditTests: XCTestCase {
    private struct UnitProfile {
        let health: Int
        let control: Int
        let modelCount: Int
    }

    func testAllSpearheadArmiesHavePerUnitWoundTracking() async throws {
        let catalog = try await BundledSpearheadCatalogRepository().loadCatalog()
        let armies = catalog.factions.flatMap(\.armies)

        XCTAssertEqual(armies.count, 48)

        for army in armies {
            XCTAssertEqual(
                army.units.count,
                army.roster.count,
                "\(army.id) should declare one tracked unit per roster entry"
            )

            for unit in army.units {
                XCTAssertNotNil(unit.health, "\(army.id)/\(unit.id) should declare health")
                XCTAssertNotNil(unit.control, "\(army.id)/\(unit.id) should declare control")
                XCTAssertNotNil(unit.modelCount, "\(army.id)/\(unit.id) should declare modelCount")
                XCTAssertGreaterThan(unit.health ?? 0, 0)
                XCTAssertGreaterThan(unit.control ?? -1, 0)
                XCTAssertGreaterThan(unit.modelCount ?? 0, 0)
                XCTAssertGreaterThan(
                    UnitWoundCapacity.capacity(for: unit),
                    0,
                    "\(army.id)/\(unit.id) should have positive wound capacity"
                )
            }
        }
    }

    func testFeaturedArmyUnitProfilesMatchSpearheadPDFs() async throws {
        let repository = BundledSpearheadCatalogRepository()
        let catalog = try await repository.loadCatalog()

        let expectedProfiles: [String: [String: UnitProfile]] = [
            "gnawfeast-clawpack": [
                "clawlord": UnitProfile(health: 7, control: 2, modelCount: 1),
                "grey-seer": UnitProfile(health: 5, control: 2, modelCount: 1),
                "warlock-engineer": UnitProfile(health: 5, control: 2, modelCount: 1),
                "clanrats": UnitProfile(health: 1, control: 1, modelCount: 10),
                "clanrats-2": UnitProfile(health: 1, control: 1, modelCount: 10),
                "rat-ogors": UnitProfile(health: 4, control: 1, modelCount: 3)
            ],
            "vigilant-brotherhood": [
                "lord-vigilant": UnitProfile(health: 8, control: 2, modelCount: 1),
                "lord-veritant": UnitProfile(health: 6, control: 2, modelCount: 1),
                "prosecutors": UnitProfile(health: 2, control: 1, modelCount: 3),
                "liberators": UnitProfile(health: 2, control: 1, modelCount: 5)
            ]
        ]

        for army in catalog.factions.flatMap(\.armies) where SpearheadFeaturedArmies.isFeatured(army.id) {
            guard let expectedUnits = expectedProfiles[army.id] else {
                XCTFail("Missing profile audit fixture for featured army \(army.id)")
                continue
            }

            for unit in army.units {
                guard let expected = expectedUnits[unit.id] else {
                    XCTFail("Missing profile audit for \(army.id)/\(unit.id)")
                    continue
                }
                XCTAssertEqual(unit.health, expected.health, "\(unit.name) health should be \(expected.health)")
                XCTAssertEqual(unit.control, expected.control, "\(unit.name) control should be \(expected.control)")
                XCTAssertEqual(
                    unit.modelCount,
                    expected.modelCount,
                    "\(unit.name) modelCount should be \(expected.modelCount)"
                )
            }
        }
    }

    func testAllSpearheadArmiesSupportBattleTracker() async throws {
        let catalog = try await BundledSpearheadCatalogRepository().loadCatalog()
        let armies = catalog.factions.flatMap(\.armies)

        for army in armies {
            XCTAssertTrue(
                army.supportsBattleTracker,
                "\(army.id) should support per-unit wound tracking in the battle tracker"
            )
            XCTAssertGreaterThanOrEqual(
                army.contentCoverage,
                .battleTracker,
                "\(army.id) should expose battle-tracker content coverage"
            )
        }
    }
}
