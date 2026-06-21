import XCTest
@testable import TabletomeData
@testable import TabletomeDomain

final class GameSystemRegistryTests: XCTestCase {
    private let registry = GameSystemRegistry.bundled

    func testLoadsAllBundledSystems() {
        XCTAssertEqual(GameSystemId.allCases.count, 4)
        XCTAssertEqual(registry.allDescriptors.count, GameSystemId.allCases.count)
        XCTAssertTrue(registry.isKnownSystem("aos-spearhead"))
        XCTAssertTrue(registry.isKnownSystem("wh40k-11e"))
        XCTAssertTrue(registry.isKnownSystem("wh40k-10e-cp"))
        XCTAssertTrue(registry.isKnownSystem("sc-tmg"))
    }

    func testSpearheadPlayEngine() throws {
        let descriptor = try registry.requireDescriptor(for: GameSystemId.aosSpearhead.rawValue)
        XCTAssertEqual(descriptor.playEngine.playEngineId, PlayEngineId.phasedRound)
        XCTAssertEqual(descriptor.playEngine.battleRoundCount(), 4)
        XCTAssertTrue(descriptor.capabilities.showsBattleTacticDecks)
        XCTAssertTrue(descriptor.capabilities.showsCombatResolver)
    }

    func testScTmgPlayEngine() throws {
        let descriptor = try registry.requireDescriptor(for: GameSystemId.scTmg.rawValue)
        XCTAssertEqual(descriptor.playEngine.playEngineId, PlayEngineId.alternatingActivation)
        XCTAssertEqual(
            descriptor.playEngine.mainPhases(),
            [BattleTurnPhase.movement, .assault, .combat, .scoring]
        )
        XCTAssertTrue(descriptor.capabilities.showsActivationBar)
    }

    func testFeaturedArmiesForSpearhead() throws {
        let featured = try XCTUnwrap(registry.featuredArmies(for: "aos-spearhead"))
        XCTAssertTrue(featured.isFeatured("vigilant-brotherhood"))
        XCTAssertTrue(featured.isFeatured("gnawfeast-clawpack"))
    }

    func testCombatPatrolStarterMission() throws {
        let featured = try XCTUnwrap(registry.featuredArmies(for: "wh40k-10e-cp"))
        var state = GuidedMatchState()
        featured.applyStarterMatchup(to: &state)
        XCTAssertEqual(state.selectedMissionId, "clash-of-patrols")
    }

    func testCopyFor40k11e() throws {
        let copy = try XCTUnwrap(registry.copy(for: "wh40k-11e"))
        XCTAssertEqual(copy.shortLabel, "40k")
        XCTAssertEqual(copy.rulesTitle, "40k Rules")
    }

    func testUnknownSystemThrows() {
        XCTAssertThrowsError(try registry.requireDescriptor(for: "blood-bowl")) { error in
            guard case let GameSystemRegistryError.systemNotFound(id) = error else {
                return XCTFail("Expected systemNotFound")
            }
            XCTAssertEqual(id, "blood-bowl")
        }
    }

    func testManifestMatchesBundledRegistry() throws {
        let manifest = try GameSystemsManifestLoader.load(
            from: Bundle(for: GameSystemRegistryTests.self)
        )
        let issues = GameSystemsManifestLoader.validateAgainstRegistry(manifest)
        XCTAssertTrue(issues.isEmpty, "Manifest drift: \(issues)")
    }

    func testVictoryPointsScoringForCombatPatrol() {
        let scoring = GameSystemPlayContext.context(for: "wh40k-10e-cp").victoryPointsScoring
        XCTAssertEqual(scoring.primaryQuickAddAmount, 5)
        XCTAssertEqual(scoring.secondaryQuickAddAmount, 10)
    }

    func testCombatPatrolShowsDedicatedCombatTab() throws {
        let descriptor = try registry.requireDescriptor(for: GameSystemId.wh40k10eCp.rawValue)
        XCTAssertTrue(descriptor.capabilities.showsDedicatedCombatTab)
    }

    func testWh40kHidesDedicatedCombatTab() throws {
        let descriptor = try registry.requireDescriptor(for: GameSystemId.wh40k11e.rawValue)
        XCTAssertFalse(descriptor.capabilities.showsDedicatedCombatTab)
    }

    func testCombatPatrolUsesWh40k10eCombatRollEngine() throws {
        let descriptor = try registry.requireDescriptor(for: GameSystemId.wh40k10eCp.rawValue)
        XCTAssertTrue(descriptor.capabilities.usesWh40k10eCombatRollEngine)
        XCTAssertFalse(descriptor.capabilities.usesWh40k11eCombatRollEngine)
    }

    func testWh40k11eUsesDedicated11eCombatRollEngine() throws {
        let descriptor = try registry.requireDescriptor(for: GameSystemId.wh40k11e.rawValue)
        XCTAssertTrue(descriptor.capabilities.usesWh40k11eCombatRollEngine)
        XCTAssertFalse(descriptor.capabilities.usesWh40k10eCombatRollEngine)
        XCTAssertTrue(descriptor.capabilities.showsCombatResolver)
    }
}

final class BundledPlayCatalogRepositoryTests: XCTestCase {
    func testLoadsSpearheadCatalog() async throws {
        let repository = BundledPlayCatalogRepository(
            bundle: Bundle(for: BundledPlayCatalogRepositoryTests.self)
        )
        let catalog = try await repository.loadCatalog(for: "aos-spearhead")
        XCTAssertFalse(catalog.factions.isEmpty)
    }

    func testLoadsScTmgCatalog() async throws {
        let repository = BundledPlayCatalogRepository(
            bundle: Bundle(for: BundledPlayCatalogRepositoryTests.self)
        )
        let catalog = try await repository.loadCatalog(for: "sc-tmg")
        XCTAssertEqual(catalog.factions.count, 3)
    }
}
