import XCTest
@testable import Tabletome
@testable import TabletomeData
@testable import TabletomeDomain

final class BundledRulesRepositoryTests: XCTestCase {
    private var testRepository: BundledRulesRepository {
        BundledRulesRepository(bundle: Bundle(for: BundledRulesRepositoryTests.self))
    }

    func testDecodesProductionBundle() async throws {
        let repo = testRepository
        let bundle = try await repo.loadBundle()
        XCTAssertEqual(bundle.schemaVersion, 1)
        XCTAssertFalse(bundle.gameSystems.isEmpty)
    }

    func testSpearheadHasOrderedGuideSteps() async throws {
        let system = try await testRepository.gameSystem(id: "aos-spearhead")
        let orders = system.gettingStartedSteps.map(\.order)
        XCTAssertEqual(orders, orders.sorted())
        XCTAssertEqual(system.gettingStartedSteps.count, 5)
    }

    func testSpearheadHasCoreAndSpearheadRuleSections() async throws {
        let system = try await testRepository.gameSystem(id: "aos-spearhead")
        let ids = Set(system.ruleSections.map(\.id))
        let required = [
            "combat-sequence",
            "turn-structure",
            "movement-phase",
            "shooting-phase",
            "charge-phase",
            "combat-phase-fight",
            "weapon-abilities",
            "spearhead-overview",
            "spearhead-format",
            "spearhead-deployment",
            "spearhead-scoring",
            "glossary-contest"
        ]
        XCTAssertEqual(system.ruleSections.count, 20)
        XCTAssertTrue(required.allSatisfy { ids.contains($0) })
    }

    func testWh40k11eHasGuideContent() async throws {
        let system = try await testRepository.gameSystem(id: "wh40k-11e")
        XCTAssertEqual(system.availability, .available)
        XCTAssertEqual(system.gettingStartedSteps.count, 7)
        XCTAssertEqual(system.editionMigrationSteps.count, 11)
        XCTAssertEqual(system.ruleSections.count, 17)
        XCTAssertFalse(system.externalLinks?.isEmpty ?? true)

        let gettingStartedOrders = system.gettingStartedSteps.map(\.order)
        XCTAssertEqual(gettingStartedOrders, gettingStartedOrders.sorted())

        let migrationOrders = system.editionMigrationSteps.map(\.order)
        XCTAssertEqual(migrationOrders, migrationOrders.sorted())
    }

    func testScTmgHasGuideContent() async throws {
        let system = try await testRepository.gameSystem(id: "sc-tmg")
        XCTAssertEqual(system.availability, .available)
        XCTAssertEqual(system.gettingStartedSteps.count, 7)
        XCTAssertEqual(system.editionMigrationSteps.count, 5)
        XCTAssertEqual(system.ruleSections.count, 10)
        XCTAssertFalse(system.externalLinks?.isEmpty ?? true)
    }

    func testWh40k11eBattleShockUsesCorrectPassCondition() async throws {
        let system = try await testRepository.gameSystem(id: "wh40k-11e")
        let section = try XCTUnwrap(system.ruleSections.first { $0.id == "11e-battle-shock" })
        XCTAssertTrue(section.content.contains("equal to or greater than"))
        XCTAssertTrue(section.content.contains("cannot be targeted by Stratagems"))
        XCTAssertFalse(section.content.contains("≤"))
        XCTAssertFalse(section.content.contains("cannot use Stratagems"))
    }

    func testWh40k11eHiddenRequiresLightOrDenseAndNoRangedAttacks() async throws {
        let system = try await testRepository.gameSystem(id: "wh40k-11e")
        let section = try XCTUnwrap(system.ruleSections.first { $0.id == "11e-cover-hidden" })
        XCTAssertTrue(section.content.contains("Light or Dense"))
        XCTAssertTrue(section.content.contains("ranged attacks"))
        XCTAssertFalse(section.content.localizedCaseInsensitiveContains("did not shoot"))
    }

    func testWh40k11eScoringUsesBattleRoundCaps() async throws {
        let system = try await testRepository.gameSystem(id: "wh40k-11e")
        let section = try XCTUnwrap(system.ruleSections.first { $0.id == "11e-scoring-overview" })
        XCTAssertTrue(section.content.contains("battle round"))
        XCTAssertFalse(section.content.localizedCaseInsensitiveContains("per turn"))
    }

    func testWh40k10eCpHasGuideContent() async throws {
        let system = try await testRepository.gameSystem(id: "wh40k-10e-cp")
        XCTAssertEqual(system.availability, .available)
        XCTAssertEqual(system.gettingStartedSteps.count, 7)
        XCTAssertEqual(system.ruleSections.count, 29)
        XCTAssertFalse(system.externalLinks?.isEmpty ?? true)

        let ids = Set(system.ruleSections.map(\.id))
        let requiredCore = ["10e-overview", "10e-turn-overview", "10e-attack-sequence"]
        let requiredFormat = ["cp-overview", "cp-missions", "cp-scoring", "cp-securing"]
        let requiredGlossary = ["glossary-cp-secure", "glossary-oc-10e"]
        XCTAssertTrue(requiredCore.allSatisfy { ids.contains($0) })
        XCTAssertTrue(requiredFormat.allSatisfy { ids.contains($0) })
        XCTAssertTrue(requiredGlossary.allSatisfy { ids.contains($0) })
    }

    func testWh40k10eCpSectionIdsUseModePrefixes() async throws {
        let system = try await testRepository.gameSystem(id: "wh40k-10e-cp")
        for section in system.ruleSections {
            switch section.category {
            case .core:
                XCTAssertTrue(
                    section.id.hasPrefix("10e-"),
                    "Core section \(section.id) must use 10e- prefix"
                )
            case .combatPatrol:
                XCTAssertTrue(
                    section.id.hasPrefix("cp-"),
                    "Combat Patrol section \(section.id) must use cp- prefix"
                )
            case .glossary:
                XCTAssertTrue(
                    section.id.hasPrefix("glossary-"),
                    "Glossary section \(section.id) must use glossary- prefix"
                )
            case .spearhead:
                XCTFail("Spearhead category must not appear in wh40k-10e-cp")
            }
        }
    }

    func testWh40k10eCpHasCombatPatrolCategorySections() async throws {
        let system = try await testRepository.gameSystem(id: "wh40k-10e-cp")
        let cpSections = system.ruleSections.filter { $0.category == .combatPatrol }
        XCTAssertEqual(cpSections.count, 13)
    }

    func testGameSystemNotFound() async {
        do {
            _ = try await testRepository.gameSystem(id: "missing")
            XCTFail("Expected error")
        } catch let error as RulesRepositoryError {
            XCTAssertEqual(error, .gameSystemNotFound(id: "missing"))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
