import XCTest
@testable import Tabletome

final class FirebaseLogSinkTests: XCTestCase {
    func testAnalyticsSinkSkipsWhenCollectionDisabled() {
        let sink = FirebaseAnalyticsLogSink(appVersion: "1.0.0", isCollectionEnabled: false)
        sink.write(makeEntry(level: .info, eventName: "guided_match_started"))
    }

    func testCrashlyticsSinkSkipsWhenCollectionDisabled() {
        let sink = FirebaseCrashlyticsLogSink(appVersion: "1.0.0", isCollectionEnabled: false)
        sink.write(makeEntry(level: .info, eventName: "main_tab_presented"))
        sink.write(makeEntry(level: .error, eventName: "match_sync_failed"))
    }

    func testCrashlyticsSinkAcceptsInfoAndErrorWhenCollectionMatchesBootstrap() {
        let sink = FirebaseCrashlyticsLogSink(
            appVersion: "1.0.0",
            isCollectionEnabled: FirebaseBootstrap.isCrashlyticsCollectionEnabled
        )
        sink.write(makeEntry(level: .info, eventName: "main_tab_presented"))
        sink.write(
            makeEntry(
                level: .error,
                eventName: "match_sync_failed",
                metadata: ["errorCode": "timeout", "gameSystemId": "aos-spearhead"]
            )
        )
    }

    private func makeEntry(
        level: LogLevel,
        eventName: String,
        metadata: [String: String] = [:]
    ) -> LogEntry {
        LogEntry(
            timestamp: Date(),
            level: level,
            category: .ui,
            eventName: eventName,
            message: "Test.",
            metadata: metadata,
            correlationId: nil
        )
    }
}
