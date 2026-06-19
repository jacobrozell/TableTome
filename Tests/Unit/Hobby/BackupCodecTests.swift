import XCTest
import SwiftData
@testable import Tabletome
@testable import TabletomeHobbyData
@testable import TabletomeDomain

@MainActor
final class BackupCodecTests: XCTestCase {
    private var context: ModelContext!

    override func setUp() async throws {
        try await super.setUp()
        context = HobbyAppContainer.unitTestContext()
        HobbyAppContainer.resetUnitTestStore()
    }

    func testExportRestoreRoundTripPreservesArmy() throws {
        XCTAssertTrue(ArmyStore.addArmy(name: "Ultramarines", game: "40k", faction: "Space Marines", in: context))

        let exported = BackupCodec.export(context)
        guard case .success(let backup) = BackupSanitizer.parse(exported) else {
            return XCTFail("Exported backup should parse")
        }

        BackupCodec.restore(backup, into: context)

        let armies = try context.fetch(FetchDescriptor<Army>())
        XCTAssertEqual(armies.count, 1)
        XCTAssertEqual(armies.first?.name, "Ultramarines")
        XCTAssertEqual(armies.first?.units.count, 0)
    }

    func testExportIncludesPaintAndSettings() throws {
        XCTAssertTrue(ArmyStore.addArmy(name: "Chapter", game: "40k", faction: "SM", in: context))
        let paint = HobbyPaint(name: "Macragge Blue", type: "Base", swatchHex: "#0000ff", qty: 1)
        context.insert(paint)
        try context.save()

        let exported = BackupCodec.export(context)

        XCTAssertTrue(exported.contains("Macragge Blue"))
        XCTAssertTrue(exported.contains("\"version\""))
        guard case .success(let backup) = BackupSanitizer.parse(exported) else {
            return XCTFail("Exported backup should parse")
        }
        XCTAssertEqual(backup.paints.count, 1)
        XCTAssertEqual(backup.paints.first?.name, "Macragge Blue")
    }
}
