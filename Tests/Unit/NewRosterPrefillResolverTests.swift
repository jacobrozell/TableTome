import XCTest
@testable import Tabletome
@testable import TabletomeDomain

final class NewRosterPrefillResolverTests: XCTestCase {
    override func tearDown() {
        super.tearDown()
        FirstSessionStore.clearPersistedState()
        ActiveGameContextStore.clearPersistedState()
    }

    func testCombatPatrolPrefillIncludesFactionBattleSizeAndGuidance() {
        let prefill = NewRosterPrefillResolver.prefill(
            onboardingChoice: GameSystemId.wh40k10eCp.rawValue,
            activeGameSystemId: GameSystemId.default.rawValue,
            hasExplicitPrefill: false
        )

        XCTAssertEqual(prefill?.suggestedBattleSizeKey, "combat-patrol")
        XCTAssertEqual(prefill?.suggestedFactions, ["Space Marines", "Tyranids"])
        XCTAssertEqual(prefill?.starterBoxGuidance?.gameSystemId, GameSystemId.wh40k10eCp.rawValue)
    }

    func testSpearheadShowsGuidanceWithout40kFactionPrefill() {
        let prefill = NewRosterPrefillResolver.prefill(
            onboardingChoice: GameSystemId.aosSpearhead.rawValue,
            activeGameSystemId: GameSystemId.default.rawValue,
            hasExplicitPrefill: false
        )

        XCTAssertTrue(prefill?.suggestedFactions.isEmpty == true)
        XCTAssertNil(prefill?.suggestedBattleSizeKey)
        XCTAssertEqual(prefill?.starterBoxGuidance?.gameSystemId, GameSystemId.aosSpearhead.rawValue)
    }

    func testExplicitPrefillSkipsStarterBoxGuidance() {
        let prefill = NewRosterPrefillResolver.prefill(
            onboardingChoice: GameSystemId.wh40k10eCp.rawValue,
            activeGameSystemId: GameSystemId.default.rawValue,
            hasExplicitPrefill: true
        )

        XCTAssertNil(prefill?.starterBoxGuidance)
        XCTAssertEqual(prefill?.suggestedBattleSizeKey, "combat-patrol")
    }

    func testRosterFactionLabelMapsCatalogSlug() {
        XCTAssertEqual(
            NewRosterPrefillResolver.rosterFactionLabel(forSlug: "space-marines"),
            "Space Marines"
        )
        XCTAssertEqual(
            NewRosterPrefillResolver.rosterFactionLabel(forSlug: "tyranids"),
            "Tyranids"
        )
        XCTAssertNil(NewRosterPrefillResolver.rosterFactionLabel(forSlug: "stormcast-eternals"))
    }

    func testIsFixedRosterGameSystem() {
        XCTAssertTrue(NewRosterPrefillResolver.isFixedRosterGameSystem(GameSystemId.wh40k10eCp.rawValue))
        XCTAssertTrue(NewRosterPrefillResolver.isFixedRosterGameSystem(GameSystemId.aosSpearhead.rawValue))
        XCTAssertTrue(NewRosterPrefillResolver.isFixedRosterGameSystem(GameSystemId.scTmg.rawValue))
        XCTAssertFalse(NewRosterPrefillResolver.isFixedRosterGameSystem(GameSystemId.wh40k11e.rawValue))
        XCTAssertFalse(NewRosterPrefillResolver.isFixedRosterGameSystem("unknown-game"))
    }
}
