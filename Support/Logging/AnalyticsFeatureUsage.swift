import Foundation
import TabletomeDomain

/// Records feature adoption and refreshes Firebase user properties for segmentation.
@MainActor
enum AnalyticsFeatureUsage {
    static func recordTabVisit(_ tab: AppTab) {
        guard let logger = TabletomeAnalytics.logger else {
            _ = AnalyticsFeatureUsageStore.recordTabVisit(tab)
            syncUserProperties()
            return
        }
        if let feature = AnalyticsFeatureUsageStore.recordTabVisit(tab) {
            logFirstUseIfNeeded(
                feature: feature,
                logger: logger,
                metadata: ["activeTab": tab.analyticsLabel]
            )
        }
        syncUserProperties()
    }

    static func recordGuidedMatchStarted(gameSystemId: String) {
        let isFirst = AnalyticsFeatureUsageStore.recordGuidedMatchStarted(gameSystemId: gameSystemId)
        if isFirst, let logger = TabletomeAnalytics.logger {
            logFirstUseIfNeeded(
                feature: .guidedMatch,
                logger: logger,
                metadata: TabletomeAnalytics.gameSystemMetadata(gameSystemId)
            )
        }
        syncUserProperties(activeGameSystemId: gameSystemId)
    }

    static func recordGameGuideOpened(gameSystemId: String) {
        let isFirst = AnalyticsFeatureUsageStore.recordFeature(.gameGuide)
        AnalyticsFeatureUsageStore.recordGameGuideOpened(gameSystemId: gameSystemId)
        if isFirst, let logger = TabletomeAnalytics.logger {
            logFirstUseIfNeeded(
                feature: .gameGuide,
                logger: logger,
                metadata: TabletomeAnalytics.gameSystemMetadata(gameSystemId)
            )
        }
        syncUserProperties(activeGameSystemId: gameSystemId)
    }

    static func recordActiveGameSystem(_ gameSystemId: String) {
        AnalyticsFeatureUsageStore.setActiveGameSystem(gameSystemId)
        syncUserProperties(activeGameSystemId: gameSystemId)
    }

    static func syncUserProperties(activeGameSystemId: String? = nil) {
        AnalyticsUserContext.sync(activeGameSystemId: activeGameSystemId)
    }

    private static func logFirstUseIfNeeded(
        feature: AnalyticsFeatureUsageStore.Feature,
        logger: any AppLogger,
        metadata: [String: String]
    ) {
        var eventMetadata = metadata
        eventMetadata["feature"] = feature.rawValue
        eventMetadata["isFirstUse"] = "true"
        logger.info(
            .ui,
            eventName: "feature_first_used",
            message: "Feature used for the first time.",
            metadata: eventMetadata
        )
    }
}
