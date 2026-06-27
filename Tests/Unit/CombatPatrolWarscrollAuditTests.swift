import XCTest
@testable import TabletomeData
@testable import TabletomeDomain

final class CombatPatrolWarscrollAuditTests: XCTestCase {
    private var repository: BundledPlayCatalogRepository {
        BundledPlayCatalogRepository(bundle: Bundle(for: CombatPatrolWarscrollAuditTests.self))
    }

    private static let detailArmyIds: Set<String> = [
        "space-marines-combat-patrol",
        "tyranids-combat-patrol",
        "orks-combat-patrol",
        "necrons-combat-patrol",
        "adeptus-custodes-combat-patrol",
        "astra-militarum-combat-patrol",
        "adepta-sororitas-combat-patrol",
        "adeptus-mechanicus-combat-patrol",
        "grey-knights-combat-patrol",
        "imperial-agents-combat-patrol",
        "imperial-knights-combat-patrol",
        "chaos-space-marines-combat-patrol",
        "chaos-daemons-combat-patrol",
        "chaos-knights-combat-patrol",
        "death-guard-combat-patrol",
        "emperors-children-combat-patrol",
        "thousand-sons-combat-patrol",
        "world-eaters-combat-patrol",
        "aeldari-combat-patrol",
        "drukhari-combat-patrol",
        "genestealer-cults-combat-patrol",
        "leagues-of-votann-combat-patrol",
        "tau-empire-combat-patrol"
    ]

    func testDetailArmiesHaveWoundTrackingAndWeapons() async throws {
        let catalog = try await repository.loadCatalog(for: "wh40k-10e-cp")
        let armies = catalog.factions.flatMap(\.armies).filter { Self.detailArmyIds.contains($0.id) }

        XCTAssertEqual(armies.count, Self.detailArmyIds.count)

        for army in armies {
            XCTAssertFalse(army.units.isEmpty, "\(army.id) should declare units")
            for unit in army.units {
                XCTAssertNotNil(unit.health, "\(army.id)/\(unit.id) health")
                XCTAssertNotNil(unit.control, "\(army.id)/\(unit.id) control")
                XCTAssertNotNil(unit.modelCount, "\(army.id)/\(unit.id) modelCount")
                XCTAssertGreaterThan(unit.health ?? 0, 0)
                XCTAssertGreaterThanOrEqual(unit.control ?? 0, 0)
                XCTAssertGreaterThan(unit.modelCount ?? 0, 0)
                XCTAssertGreaterThan(UnitWoundCapacity.capacity(for: unit), 0)
                XCTAssertTrue(unit.hasWarscroll, "\(army.id)/\(unit.id) warscroll")
                XCTAssertFalse(unit.weapons.isEmpty, "\(army.id)/\(unit.id) weapons")
            }
        }
    }
}
