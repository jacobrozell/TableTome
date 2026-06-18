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
