import XCTest
@testable import TabletomeData
@testable import TabletomeDomain

final class GuidedMatchFeaturedArmiesTests: XCTestCase {
    private var featured: GuidedMatchFeaturedArmies {
        GuidedMatchFeaturedArmies.resolved(for: .aosSpearhead)
    }

    func testStarterMatchupSetsBothArmies() {
        var state = GuidedMatchState()
        featured.applyStarterMatchup(to: &state)

        XCTAssertEqual(state.playerOne.armyId, "vigilant-brotherhood")
        XCTAssertEqual(state.playerTwo.armyId, "gnawfeast-clawpack")
        XCTAssertTrue(state.hasBothArmies)
    }

    func testFeaturedArmiesHaveWarscrolls() async throws {
        let catalog = try await BundledSpearheadCatalogRepository(
            bundle: Bundle(for: GuidedMatchFeaturedArmiesTests.self)
        ).loadCatalog()

        for armyId in featured.armyIds {
            let army = try XCTUnwrap(catalog.factions.flatMap(\.armies).first { $0.id == armyId })
            XCTAssertEqual(army.contentCoverage, .warscrolls, "\(armyId) should have full support")
            XCTAssertFalse(army.units.filter(\.hasWarscroll).isEmpty)
        }
    }
}
