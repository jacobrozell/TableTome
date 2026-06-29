import XCTest
@testable import Tabletome

final class FirebaseAnalyticsEventMappingTests: XCTestCase {
    func testMapsBootstrapReadyToAppOpen() {
        let entry = LogEntry(
            timestamp: Date(),
            level: .info,
            category: .appLifecycle,
            eventName: "app_bootstrap_ready",
            message: "Ready.",
            metadata: [:],
            correlationId: nil
        )

        XCTAssertEqual(FirebaseAnalyticsEventMapping.map(entry, appVersion: nil)?.name, "app_open")
    }

    func testMapsGuidedMatchStartedWithGameSystemId() {
        let entry = LogEntry(
            timestamp: Date(),
            level: .info,
            category: .guidedMatch,
            eventName: "guided_match_started",
            message: "Started.",
            metadata: [
                "gameSystemId": "aos-spearhead",
                "rosterId": "secret-should-drop"
            ],
            correlationId: nil
        )

        let event = FirebaseAnalyticsEventMapping.map(entry, appVersion: "1.0.0")
        XCTAssertEqual(event?.name, "guided_match_started")
        XCTAssertEqual(event?.parameters["gameSystemId"], "aos-spearhead")
        XCTAssertNil(event?.parameters["rosterId"])
        XCTAssertEqual(event?.parameters["app_version"], "1.0.0")
    }

    func testDropsNonAllowlistedEvents() {
        let entry = LogEntry(
            timestamp: Date(),
            level: .info,
            category: .ui,
            eventName: "tab_tapped",
            message: "Tapped.",
            metadata: [:],
            correlationId: nil
        )

        XCTAssertNil(FirebaseAnalyticsEventMapping.map(entry, appVersion: nil))
    }

    func testMapsOnboardingCompletedEvent() {
        let entry = LogEntry(
            timestamp: Date(),
            level: .info,
            category: .ui,
            eventName: "onboarding_completed",
            message: "Finished.",
            metadata: [
                "skipped": "false",
                "onboardingChoice": "aos-spearhead",
                "completionType": "guided_match"
            ],
            correlationId: nil
        )

        let event = FirebaseAnalyticsEventMapping.map(entry, appVersion: "1.0.0")
        XCTAssertEqual(event?.name, "onboarding_completed")
        XCTAssertEqual(event?.parameters["onboardingChoice"], "aos-spearhead")
    }

    func testMapsClientEnvironmentChanged() {
        let entry = LogEntry(
            timestamp: Date(),
            level: .info,
            category: .appLifecycle,
            eventName: "client_environment_changed",
            message: "Changed.",
            metadata: [
                "deviceClass": "iphone",
                "trigger": "voiceover",
                "changedSignals": "voiceover"
            ],
            correlationId: nil
        )

        let event = FirebaseAnalyticsEventMapping.map(entry, appVersion: nil)
        XCTAssertEqual(event?.name, "client_environment_changed")
        XCTAssertEqual(event?.parameters["trigger"], "voiceover")
    }
}
