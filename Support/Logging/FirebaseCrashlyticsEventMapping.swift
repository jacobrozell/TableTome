import Foundation

enum FirebaseCrashlyticsEventMapping {
    private static let errorDomain = "com.jacobrozell.tabletome.logger"

    private static let allowlistedLogEvents: Set<String> = [
        "catalog_load_failed",
        "match_history_save_failed",
        "match_history_load_failed",
        "match_sync_failed",
        "guided_match_start_failed",
        "hobby_container_open_failed",
        "rules_load_failed"
    ]

    static let eventCodes: [String: Int] = [
        "catalog_load_failed": 1001,
        "match_history_save_failed": 1002,
        "match_sync_failed": 1003,
        "guided_match_start_failed": 1004,
        "hobby_container_open_failed": 1005,
        "rules_load_failed": 1006,
        "match_history_load_failed": 1007
    ]

    private static let allowlistedParameterKeys: Set<String> = AnalyticsMetadataKeys.crashlyticsParameters

    static func nonFatalError(for entry: LogEntry, appVersion: String?) -> NSError? {
        guard entry.level >= .error,
              allowlistedLogEvents.contains(entry.eventName),
              let code = eventCodes[entry.eventName]
        else {
            return nil
        }

        var userInfo = sanitizedParameters(from: entry.metadata)
        userInfo["log_category"] = entry.category.rawValue
        userInfo["event_name"] = entry.eventName
        if let appVersion, !appVersion.isEmpty {
            userInfo["app_version"] = appVersion
        }

        return NSError(domain: errorDomain, code: code, userInfo: userInfo)
    }

    private static func sanitizedParameters(from metadata: [String: String]) -> [String: String] {
        FirebaseMetadataSanitizer.sanitize(metadata, allowedKeys: allowlistedParameterKeys)
    }
}
