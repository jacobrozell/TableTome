import XCTest
@testable import Tabletome
import TabletomeDomain

final class AnalyticsFeatureUsageStoreTests: XCTestCase {
    override func tearDown() {
        AnalyticsFeatureUsageStore.clearPersistedState()
        super.tearDown()
    }

    func testRecordsFirstTabVisitAndSegment() {
        XCTAssertNotNil(AnalyticsFeatureUsageStore.recordTabVisit(.bench))

        var properties = AnalyticsFeatureUsageStore.userPropertyValues()
        XCTAssertEqual(properties["used_models"], "true")
        XCTAssertEqual(properties["models_tab_visits"], "1")
        XCTAssertEqual(properties["user_segment"], "models_only")

        XCTAssertNil(AnalyticsFeatureUsageStore.recordTabVisit(.bench))
        properties = AnalyticsFeatureUsageStore.userPropertyValues()
        XCTAssertEqual(properties["models_tab_visits"], "2_5")
    }

    func testGuidedMatchOnlySegment() {
        _ = AnalyticsFeatureUsageStore.recordGuidedMatchStarted(gameSystemId: GameSystemId.aosSpearhead.rawValue)

        let properties = AnalyticsFeatureUsageStore.userPropertyValues()
        XCTAssertEqual(properties["used_guided_match"], "true")
        XCTAssertEqual(properties["user_segment"], "guided_match_only")
        XCTAssertEqual(properties["last_match_section"], "aos")
        XCTAssertEqual(properties["match_system_sections"], "aos")
    }

    func testMultipleGameSystemSections() {
        _ = AnalyticsFeatureUsageStore.recordGuidedMatchStarted(gameSystemId: GameSystemId.aosSpearhead.rawValue)
        _ = AnalyticsFeatureUsageStore.recordGuidedMatchStarted(gameSystemId: GameSystemId.wh40k11e.rawValue)

        let properties = AnalyticsFeatureUsageStore.userPropertyValues()
        XCTAssertEqual(properties["match_system_sections"], "aos,wh40k_11e")
        XCTAssertEqual(properties["guided_match_starts"], "2_5")
    }

    func testFullHobbySegment() {
        _ = AnalyticsFeatureUsageStore.recordTabVisit(.bench)
        _ = AnalyticsFeatureUsageStore.recordTabVisit(.muster)
        _ = AnalyticsFeatureUsageStore.recordGuidedMatchStarted(gameSystemId: GameSystemId.wh40k11e.rawValue)

        XCTAssertEqual(
            AnalyticsFeatureUsageStore.userPropertyValues()["user_segment"],
            "full_hobby"
        )
    }
}

final class FirebaseFeatureAdoptionEventMappingTests: XCTestCase {
    func testMapsFeatureFirstUsed() {
        let entry = LogEntry(
            timestamp: Date(),
            level: .info,
            category: .ui,
            eventName: "feature_first_used",
            message: "First use.",
            metadata: [
                "feature": "models_tab",
                "activeTab": "bench",
                "isFirstUse": "true"
            ],
            correlationId: nil
        )

        let event = FirebaseAnalyticsEventMapping.map(entry, appVersion: "1.0.0")
        XCTAssertEqual(event?.name, "feature_first_used")
        XCTAssertEqual(event?.parameters["feature"], "models_tab")
    }
}
