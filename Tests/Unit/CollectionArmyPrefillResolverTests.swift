import XCTest
@testable import Tabletome
@testable import TabletomeDomain

final class CollectionArmyPrefillResolverTests: XCTestCase {
    override func tearDown() {
        super.tearDown()
        FirstSessionStore.clearPersistedState()
    }

    func testCombatPatrolPrefill40kAndFactions() {
        let prefill = CollectionArmyPrefillResolver.prefill(
            onboardingChoice: GameSystemId.wh40k10eCp.rawValue,
            activeGameSystemId: GameSystemId.default.rawValue
        )

        XCTAssertEqual(prefill?.game, "40k")
        XCTAssertEqual(prefill?.suggestedFactions, ["Space Marines", "Tyranids"])
        XCTAssertEqual(prefill?.suggestedArmyName, "My Space Marines")
    }

    func testSpearheadPrefillAoSAndFactions() {
        let prefill = CollectionArmyPrefillResolver.prefill(
            onboardingChoice: GameSystemId.aosSpearhead.rawValue,
            activeGameSystemId: GameSystemId.default.rawValue
        )

        XCTAssertEqual(prefill?.game, "AoS")
        XCTAssertTrue(prefill?.suggestedFactions.contains("Stormcast Eternals") == true)
    }

    func testWh40k11ePrefillUsesFeaturedFactions() {
        let prefill = CollectionArmyPrefillResolver.prefill(
            onboardingChoice: GameSystemId.wh40k11e.rawValue,
            activeGameSystemId: GameSystemId.default.rawValue
        )

        XCTAssertEqual(prefill?.game, "40k")
        XCTAssertFalse(prefill?.suggestedFactions.isEmpty == true)
    }

    func testStarCraftReturnsNil() {
        let prefill = CollectionArmyPrefillResolver.prefill(
            onboardingChoice: GameSystemId.scTmg.rawValue,
            activeGameSystemId: GameSystemId.default.rawValue
        )

        XCTAssertNil(prefill)
    }

    func testFactionLabelMapsCatalogSlug() {
        XCTAssertEqual(
            CollectionArmyPrefillResolver.factionLabel(forSlug: "space-marines", game: "40k"),
            "Space Marines"
        )
        XCTAssertEqual(
            CollectionArmyPrefillResolver.factionLabel(forSlug: "stormcast-eternals", game: "AoS"),
            "Stormcast Eternals"
        )
        XCTAssertNil(CollectionArmyPrefillResolver.factionLabel(forSlug: "unknown-faction", game: "40k"))
    }
}
