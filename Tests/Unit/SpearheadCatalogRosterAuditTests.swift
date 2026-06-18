import XCTest
@testable import TabletomeData
@testable import TabletomeDomain

final class SpearheadCatalogRosterAuditTests: XCTestCase {
    func testGeneralIsFirstRosterEntryWhenListedSeparately() async throws {
        let catalog = try await BundledSpearheadCatalogRepository().loadCatalog()
        let armies = Dictionary(uniqueKeysWithValues: catalog.factions.flatMap(\.armies).map { ($0.id, $0) })

        let fangs = try XCTUnwrap(armies["fangs-of-the-blood-god"])
        XCTAssertEqual(fangs.name, "Fangs of the Blood God")
        XCTAssertEqual(
            fangs.roster,
            [
                "Karanak",
                "5 Flesh Hounds",
                "5 Flesh Hounds",
                "8 Claws of Karanak"
            ]
        )
        XCTAssertEqual(fangs.unitCount, 4)

        let wallsmasher = try XCTUnwrap(armies["wallsmasher-stomp"])
        XCTAssertEqual(
            wallsmasher.roster,
            [
                "Mancrusher Gargant",
                "1 Mancrusher Gargant",
                "1 Mancrusher Gargant"
            ]
        )
        XCTAssertEqual(wallsmasher.unitCount, 3)
    }

    func testGnawfeastRosterListsTwoClanratUnits() async throws {
        let catalog = try await BundledSpearheadCatalogRepository().loadCatalog()
        let gnawfeast = try XCTUnwrap(
            catalog.factions.flatMap(\.armies).first { $0.id == "gnawfeast-clawpack" }
        )

        XCTAssertEqual(
            gnawfeast.roster.filter { $0 == "10 Clanrats" }.count,
            2,
            "Gnawfeast ships two 10-model Clanrat units"
        )
        XCTAssertEqual(gnawfeast.units.filter { $0.name == "Clanrats" }.count, 2)
    }
}
