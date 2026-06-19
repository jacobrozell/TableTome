import XCTest
@testable import TabletomeHobbyData
@testable import TabletomeDomain

final class BackupSanitizerTests: XCTestCase {
    func testParseRejectsOversizePayload() {
        let result = BackupSanitizer.parse("{}", byteLength: HobbyLimits.maxImportBytes + 1)
        guard case .failure(.tooLarge(let maxMB)) = result else {
            return XCTFail("Expected tooLarge failure")
        }
        XCTAssertEqual(maxMB, 8)
    }

    func testParseRejectsInvalidJSON() {
        guard case .failure(.invalidJSON) = BackupSanitizer.parse("{not json}") else {
            return XCTFail("Expected invalidJSON failure")
        }
    }

    func testParseRejectsUnknownTopLevelKeys() {
        let json = #"{"version":3,"collection":[],"paints":[],"settings":{},"exportedAt":"2024-01-01T00:00:00Z","extra":true}"#
        guard case .failure(.unknownKeys(let keys)) = BackupSanitizer.parse(json) else {
            return XCTFail("Expected unknownKeys failure")
        }
        XCTAssertEqual(keys, ["extra"])
    }

    func testSanitizeClampsArmyAndUnitNames() {
        let snapshot = Snapshot(
            version: Snapshot.backupVersion,
            collection: [
                ArmyDTO(
                    army: "  My Chapter  ",
                    game: "40k",
                    faction: "Space Marines",
                    units: [UnitDTO(unit: "  Captain  ", qty: 1, state: "Done")]
                )
            ],
            paints: nil,
            settings: nil,
            exportedAt: nil
        )

        let result = BackupSanitizer.sanitize(snapshot)
        guard case .success(let backup) = result else {
            return XCTFail("Expected success")
        }

        XCTAssertEqual(backup.armies.count, 1)
        XCTAssertEqual(backup.armies[0].name, "My Chapter")
        XCTAssertEqual(backup.armies[0].units[0].name, "Captain")
        XCTAssertTrue(backup.preview.contains("1 armies"))
    }

    func testSanitizeMapsWebCsvArmySortToImport() {
        let snapshot = Snapshot(
            version: Snapshot.backupVersion,
            collection: [],
            paints: [],
            settings: SettingsDTO(armySort: "csv"),
            exportedAt: nil
        )

        guard case .success(let backup) = BackupSanitizer.sanitize(snapshot) else {
            return XCTFail("Expected success")
        }
        XCTAssertEqual(backup.settings.armySort, "import")
    }

    func testSanitizeRejectsTooManyArmies() {
        let armies = (0..<HobbyLimits.maxArmies + 1).map { index in
            ArmyDTO(army: "Army \(index)", game: "40k", faction: "SM", units: [])
        }
        let snapshot = Snapshot(version: Snapshot.backupVersion, collection: armies, paints: nil, settings: nil, exportedAt: nil)

        guard case .failure(.overLimit(let message)) = BackupSanitizer.sanitize(snapshot) else {
            return XCTFail("Expected overLimit failure")
        }
        XCTAssertTrue(message.contains("Too many armies"))
    }

    func testParseRoundTripsMinimalValidBackup() {
        let json = """
        {
          "version": 3,
          "collection": [],
          "paints": [],
          "settings": { "theme": "system", "armySort": "csv" },
          "exportedAt": "2024-06-01T12:00:00Z"
        }
        """

        guard case .success(let backup) = BackupSanitizer.parse(json) else {
            return XCTFail("Expected success")
        }
        XCTAssertEqual(backup.settings.theme, .system)
        XCTAssertEqual(backup.settings.armySort, "import")
        XCTAssertEqual(backup.armies.count, 0)
        XCTAssertEqual(backup.paints.count, 0)
    }
}
