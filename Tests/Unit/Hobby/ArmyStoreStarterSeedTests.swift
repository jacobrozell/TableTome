import XCTest
import SwiftData
@testable import Tabletome
@testable import TabletomeHobbyData
@testable import TabletomeDomain

@MainActor
final class ArmyStoreStarterSeedTests: XCTestCase {
    private var context: ModelContext!

    override func setUp() async throws {
        try await super.setUp()
        context = HobbyAppContainer.unitTestContext()
        HobbyAppContainer.resetUnitTestStore()
    }

    func testSeedStarterUnitsAddsRows() throws {
        XCTAssertTrue(ArmyStore.addArmy(name: "Chapter", game: "AoS", faction: "Stormcast Eternals", in: context))
        let army = try XCTUnwrap((try? context.fetch(FetchDescriptor<Army>()))?.first)
        let seeds = [
            StarterBoxCollectionPrefillResolver.UnitSeed(
                name: "Liberators (5)", qty: 1, source: "Spearhead starter box", spearhead: true
            ),
            StarterBoxCollectionPrefillResolver.UnitSeed(
                name: "Lord-Vigilant on Gryph-stalker", qty: 1, source: "Spearhead starter box", spearhead: true
            )
        ]

        let added = ArmyStore.seedStarterUnits(seeds, to: army, in: context)

        XCTAssertEqual(added, 2)
        XCTAssertEqual(army.units.count, 2)
        XCTAssertEqual(army.units.first?.state, "Unassembled")
        XCTAssertEqual(army.units.first?.source, "Spearhead starter box")
        XCTAssertEqual(army.units.first?.spearhead, true)
    }
}
