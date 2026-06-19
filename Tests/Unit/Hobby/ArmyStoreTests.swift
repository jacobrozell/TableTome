import XCTest
import SwiftData
@testable import Tabletome
@testable import TabletomeHobbyData
@testable import TabletomeDomain

@MainActor
final class ArmyStoreTests: XCTestCase {
    private var context: ModelContext!

    override func setUp() async throws {
        try await super.setUp()
        context = HobbyAppContainer.unitTestContext()
        HobbyAppContainer.resetUnitTestStore()
    }

    func testAddArmyRejectsDuplicateName() {
        XCTAssertTrue(ArmyStore.addArmy(name: "Ultramarines", game: "40k", faction: "Space Marines", in: context))
        XCTAssertFalse(ArmyStore.addArmy(name: "Ultramarines", game: "40k", faction: "Space Marines", in: context))
    }

    func testAddArmyRejectsBlankName() {
        XCTAssertFalse(ArmyStore.addArmy(name: "   ", game: "40k", faction: "Space Marines", in: context))
    }

    func testAddUnitAppendsToArmy() throws {
        XCTAssertTrue(ArmyStore.addArmy(name: "Ultramarines", game: "40k", faction: "Space Marines", in: context))
        let army = try XCTUnwrap((try? context.fetch(FetchDescriptor<Army>()))?.first)

        XCTAssertTrue(ArmyStore.addUnit(to: army, name: "Captain", qty: 1, source: "Box", state: "Unassembled", in: context))

        XCTAssertEqual(army.units.count, 1)
        XCTAssertEqual(army.units.first?.name, "Captain")
        XCTAssertEqual(army.units.first?.state, "Unassembled")
    }

    func testRenameArmyRejectsDuplicate() throws {
        XCTAssertTrue(ArmyStore.addArmy(name: "First", game: "40k", faction: "SM", in: context))
        XCTAssertTrue(ArmyStore.addArmy(name: "Second", game: "40k", faction: "SM", in: context))
        let second = try XCTUnwrap((try? context.fetch(FetchDescriptor<Army>()))?.first { $0.name == "Second" })

        XCTAssertFalse(ArmyStore.rename(second, to: "First", in: context))
    }

    func testAdvanceMovesUnitToNextPipelineStage() throws {
        XCTAssertTrue(ArmyStore.addArmy(name: "Chapter", game: "40k", faction: "SM", in: context))
        let army = try XCTUnwrap((try? context.fetch(FetchDescriptor<Army>()))?.first)
        XCTAssertTrue(ArmyStore.addUnit(to: army, name: "Captain", qty: 1, source: "", state: "Unassembled", in: context))
        let unit = try XCTUnwrap(army.units.first)

        ArmyStore.advance(unit, pipeline: DefaultPipeline.stages, in: context)

        XCTAssertEqual(unit.state, "Assembled")
    }
}
