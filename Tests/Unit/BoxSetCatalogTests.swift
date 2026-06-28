import XCTest
@testable import TabletomeData
@testable import TabletomeDomain

/// Phase 4: box-set definitions move from hardcoded Swift literals into
/// JSON. These tests cover the decoding + the bridge back to the legacy
/// `FeaturedArmiesConfig` so existing call sites keep working.
final class BoxSetCatalogTests: XCTestCase {
    private func decode(_ json: String) throws -> BoxSetCatalog {
        try JSONDecoder().decode(BoxSetCatalog.self, from: Data(json.utf8))
    }

    func testDecodesFullBoxSet() throws {
        let catalog = try decode(
            """
            {
              "schemaVersion": 1,
              "gameSystemId": "wh40k-10e-cp",
              "boxSets": [
                {
                  "id": "space-marines-vs-tyranids",
                  "starterMatchupTitle": "Space Marines vs Tyranids",
                  "starterSetDescription": "Quick-start.",
                  "starterSetBadge": "Combat Patrol starter box",
                  "defaultMissionId": "clash-of-patrols",
                  "armyIds": ["space-marines-combat-patrol", "tyranids-combat-patrol"],
                  "playerOne": { "playerName": "Player 1", "factionId": "space-marines", "armyId": "space-marines-combat-patrol" },
                  "playerTwo": { "playerName": "Player 2", "factionId": "tyranids", "armyId": "tyranids-combat-patrol" }
                }
              ]
            }
            """
        )

        XCTAssertEqual(catalog.schemaVersion, 1)
        XCTAssertEqual(catalog.gameSystemId, "wh40k-10e-cp")
        XCTAssertEqual(catalog.boxSets.count, 1)

        let box = try XCTUnwrap(catalog.boxSets.first)
        XCTAssertEqual(box.id, "space-marines-vs-tyranids")
        XCTAssertEqual(box.defaultMissionId, "clash-of-patrols")
        XCTAssertEqual(box.playerTwo.factionId, "tyranids")
    }

    func testBridgesToFeaturedArmiesConfig() throws {
        let catalog = try decode(
            """
            {
              "schemaVersion": 1,
              "gameSystemId": "sc-tmg",
              "boxSets": [
                {
                  "id": "raynors-raiders-vs-kerrigans-swarm",
                  "starterMatchupTitle": "Raynor's Raiders vs Kerrigan's Swarm",
                  "playerOne": { "factionId": "terran", "armyId": "raynors-raiders" },
                  "playerTwo": { "factionId": "zerg", "armyId": "kerrigans-swarm" }
                }
              ]
            }
            """
        )

        let featured = try XCTUnwrap(catalog.primaryFeaturedArmies)
        XCTAssertEqual(featured.starterMatchupTitle, "Raynor's Raiders vs Kerrigan's Swarm")
        // armyIds defaults to the two players when not explicitly listed.
        XCTAssertEqual(featured.armyIds, ["raynors-raiders", "kerrigans-swarm"])
        XCTAssertTrue(featured.isFeatured("raynors-raiders"))
        XCTAssertNil(featured.defaultMissionId)
    }

    func testLoadsBundledBoxSetsForEverySystem() throws {
        // The box-set JSON bundled for each system must decode and its featured
        // armies must match the registry descriptor that currently hardcodes them.
        let registry = GameSystemRegistry.bundled
        let manifest = try GameSystemsManifestLoader.load(from: .main)

        for entry in manifest.systems {
            guard let bundleName = entry.boxSetBundleName else { continue }
            let catalog = try BoxSetCatalogLoader.load(bundleName: bundleName, from: .main)
            XCTAssertEqual(catalog.gameSystemId, entry.id)

            let featured = try XCTUnwrap(catalog.primaryFeaturedArmies)
            let descriptorFeatured = registry.descriptor(for: entry.id)?.featuredArmies
            if let descriptorFeatured {
                XCTAssertEqual(
                    featured.armyIds, descriptorFeatured.armyIds,
                    "Box-set JSON armyIds drifted from the hardcoded descriptor for \(entry.id)"
                )
                XCTAssertEqual(
                    featured.playerOne.armyId, descriptorFeatured.playerOne.armyId,
                    "playerOne drifted for \(entry.id)"
                )
                XCTAssertEqual(
                    featured.defaultMissionId, descriptorFeatured.defaultMissionId,
                    "defaultMissionId drifted for \(entry.id)"
                )
            }
        }
    }
}
