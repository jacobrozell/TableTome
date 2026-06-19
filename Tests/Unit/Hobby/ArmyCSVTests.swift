import XCTest
@testable import TabletomeHobbyData
@testable import TabletomeDomain

final class ArmyCSVTests: XCTestCase {
    private let pipeline = DefaultPipeline.stages

    func testImportRejectsMissingRequiredHeaders() {
        let rows = [["Army", "Unit"], ["My Chapter", "Captain"]]
        let result = ArmyCSV.import(rows, pipeline: pipeline, overrides: [])
        XCTAssertFalse(result.ok)
        XCTAssertTrue(result.errors.joined().contains("Missing required columns"))
    }

    func testImportParsesArmyAndNormalizesState() {
        let rows = [
            ["Game", "Faction", "Army", "Unit", "Qty", "Source", "State"],
            ["40k", "Space Marines", "My Chapter", "Captain", "1", "Box", "based"]
        ]
        let result = ArmyCSV.import(rows, pipeline: pipeline, overrides: [])

        XCTAssertTrue(result.ok)
        XCTAssertEqual(result.armies?.count, 1)
        XCTAssertEqual(result.armies?.first?.name, "My Chapter")
        XCTAssertEqual(result.armies?.first?.units.first?.name, "Captain")
        XCTAssertEqual(result.armies?.first?.units.first?.state, "Based")
    }

    func testImportMergesSquadMemberRows() throws {
        let rows = [
            ["Game", "Faction", "Army", "Unit", "Qty", "Source", "State", "Member", "MemberState"],
            ["40k", "Space Marines", "My Chapter", "Intercessors (5)", "1", "", "Primed", "1", "Base Coated"],
            ["40k", "Space Marines", "My Chapter", "Intercessors (5)", "1", "", "Primed", "2", "Detailed"]
        ]
        let result = ArmyCSV.import(rows, pipeline: pipeline, overrides: [])

        XCTAssertTrue(result.ok)
        let unit = try XCTUnwrap(result.armies?.first?.units.first)
        XCTAssertEqual(unit.name, "Intercessors (5)")
        XCTAssertEqual(unit.members.count, 5)
        XCTAssertEqual(unit.members[0].state, "Base Coated")
        XCTAssertEqual(unit.members[1].state, "Detailed")
    }

    func testImportReportsMissingArmyRow() {
        let rows = [
            ["Game", "Faction", "Army", "Unit"],
            ["40k", "Space Marines", "", "Captain"]
        ]
        let result = ArmyCSV.import(rows, pipeline: pipeline, overrides: [])

        XCTAssertFalse(result.ok)
        XCTAssertTrue(result.errors.joined().contains("missing Army"))
    }
}

final class CSVSchemaTests: XCTestCase {
    func testDetectIdentifiesArmyAndPaintSchemas() {
        let armyRows = [["Game", "Faction", "Army", "Unit"]]
        let paintRows = [["Name", "Type", "Brand"]]

        XCTAssertEqual(CSVSchema.detect(armyRows), .armies)
        XCTAssertEqual(CSVSchema.detect(paintRows), .paints)
    }
}

final class PaintCSVTests: XCTestCase {
    func testImportMergesDuplicatePaintNames() {
        let rows = [
            ["Name", "Type", "Brand", "Source", "Quantity", "Notes"],
            ["Macragge Blue", "Base", "Citadel", "Set", "1", ""],
            ["macragge blue", "Base", "Citadel", "Extra", "2", "spare"]
        ]
        let result = PaintCSV.import(rows)

        XCTAssertTrue(result.ok)
        XCTAssertEqual(result.paints?.count, 1)
        XCTAssertEqual(result.paints?.first?.qty, 3)
        XCTAssertTrue(result.warnings.joined().contains("Merged duplicate paint"))
    }

    func testImportFailsWhenNoPaintRows() {
        let rows = [["Name", "Type"], ["", "Base"]]
        let result = PaintCSV.import(rows)

        XCTAssertFalse(result.ok)
        XCTAssertTrue(result.errors.joined().contains("No paint rows found"))
    }
}
