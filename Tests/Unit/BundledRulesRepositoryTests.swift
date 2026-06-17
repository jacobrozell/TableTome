import XCTest
@testable import Spearhead
@testable import SpearheadData
@testable import SpearheadDomain

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
