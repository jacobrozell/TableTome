import XCTest
@testable import Tabletome

final class FirebaseCrashlyticsEventMappingTests: XCTestCase {
    func testMapsAllowlistedErrorToNonFatal() {
        let entry = LogEntry(
            timestamp: Date(),
            level: .error,
            category: .persistence,
            eventName: "match_history_save_failed",
            message: "Save failed.",
            metadata: [
                "errorCode": "write_failed",
                "gameSystemId": "aos-spearhead",
                "rosterName": "My Army"
            ],
            correlationId: nil
        )

        let error = FirebaseCrashlyticsEventMapping.nonFatalError(for: entry, appVersion: "1.0.0")

        XCTAssertEqual(error?.domain, "com.jacobrozell.tabletome.logger")
        XCTAssertEqual(error?.code, 1002)
        XCTAssertEqual(error?.userInfo["event_name"] as? String, "match_history_save_failed")
        XCTAssertEqual(error?.userInfo["errorCode"] as? String, "write_failed")
        XCTAssertNil(error?.userInfo["rosterName"])
    }

    func testDropsInfoLevelEvents() {
        let entry = LogEntry(
            timestamp: Date(),
            level: .info,
            category: .network,
            eventName: "match_sync_failed",
            message: "Failed.",
            metadata: [:],
            correlationId: nil
        )

        XCTAssertNil(FirebaseCrashlyticsEventMapping.nonFatalError(for: entry, appVersion: nil))
    }

    func testMapsEveryAllowlistedCrashlyticsEventCode() {
        for (eventName, code) in FirebaseCrashlyticsEventMapping.eventCodes {
            let entry = LogEntry(
                timestamp: Date(),
                level: .error,
                category: .persistence,
                eventName: eventName,
                message: "Failure.",
                metadata: ["errorCode": "test"],
                correlationId: nil
            )
            let error = FirebaseCrashlyticsEventMapping.nonFatalError(for: entry, appVersion: "1.0.0")
            XCTAssertEqual(error?.code, code)
            XCTAssertEqual(error?.userInfo["event_name"] as? String, eventName)
        }
    }
}
