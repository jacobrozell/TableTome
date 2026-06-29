import XCTest
@testable import Tabletome

final class FirebaseBootstrapTests: XCTestCase {
    func testAnalyticsCollectionRequiresFeatureFlag() {
        let enabled = StubFeatureFlags(flags: [.enableFirebaseAnalytics: true])
        let disabled = StubFeatureFlags(flags: [.enableFirebaseAnalytics: false])

        XCTAssertEqual(
            FirebaseBootstrap.analyticsCollectionEnabled(featureFlags: enabled),
            FirebaseBootstrap.shouldConfigure
        )
        XCTAssertFalse(FirebaseBootstrap.analyticsCollectionEnabled(featureFlags: disabled))
    }

    func testCrashlyticsCollectionRequiresFeatureFlag() {
        let enabled = StubFeatureFlags(flags: [.enableFirebaseCrashlytics: true])
        let disabled = StubFeatureFlags(flags: [.enableFirebaseCrashlytics: false])

        XCTAssertEqual(
            FirebaseBootstrap.crashlyticsCollectionEnabled(featureFlags: enabled),
            FirebaseBootstrap.shouldConfigure
        )
        XCTAssertFalse(FirebaseBootstrap.crashlyticsCollectionEnabled(featureFlags: disabled))
    }
}

private struct StubFeatureFlags: FeatureFlagsProvider {
    let flags: [FeatureFlag: Bool]

    func isEnabled(_ flag: FeatureFlag) -> Bool {
        flags[flag] ?? false
    }
}
