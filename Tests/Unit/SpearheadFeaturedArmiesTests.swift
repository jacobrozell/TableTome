import XCTest
@testable import TabletomeData
@testable import TabletomeDomain

final class SpearheadFeaturedArmiesTests: XCTestCase {
    func testStarterMatchupSetsBothArmies() {
        var state = GuidedMatchState()
        SpearheadFeaturedArmies.applyStarterMatchup(to: &state)

        XCTAssertEqual(state.playerOne.armyId, "vigilant-brotherhood")
        XCTAssertEqual(state.playerTwo.armyId, "gnawfeast-clawpack")
        XCTAssertTrue(state.hasBothArmies)
    }

    func testFeaturedArmiesHaveWarscrolls() async throws {
        let catalog = try await BundledSpearheadCatalogRepository(
            bundle: Bundle(for: SpearheadFeaturedArmiesTests.self)
        ).loadCatalog()

        for armyId in SpearheadFeaturedArmies.armyIds {
            let army = try XCTUnwrap(catalog.factions.flatMap(\.armies).first { $0.id == armyId })
            XCTAssertEqual(army.contentCoverage, .warscrolls, "\(armyId) should have full support")
            XCTAssertFalse(army.units.filter(\.hasWarscroll).isEmpty)
        }
    }
}
