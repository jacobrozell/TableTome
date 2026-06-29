import Foundation

@MainActor
enum AppBootstrapper {
    private static var didBootstrap = false

    static func bootstrap(using logger: any AppLogger) {
        guard !didBootstrap else { return }
        didBootstrap = true

        logger.info(.appLifecycle, eventName: "app_bootstrap_start", message: "Bootstrapping app dependencies.")
        AnalyticsFeatureUsage.syncUserProperties(activeGameSystemId: ActiveGameContextPersistence.gameSystemId)
        AnalyticsAccessibilityContext.sync()
        logger.info(
            .appLifecycle,
            eventName: "app_bootstrap_ready",
            message: "App bootstrap completed.",
            metadata: ClientEnvironment.snapshot.analyticsMetadata
        )
    }
}
