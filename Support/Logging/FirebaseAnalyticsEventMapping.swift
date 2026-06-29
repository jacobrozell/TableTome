import Foundation

struct FirebaseAnalyticsEvent: Equatable, Sendable {
    let name: String
    let parameters: [String: String]
}

enum FirebaseAnalyticsEventMapping {
    private static let allowlistedLogEvents: Set<String> = [
        "app_bootstrap_ready",
        "main_tab_presented",
        "main_tab_selected",
        "play_home_ready",
        "game_system_changed",
        "game_guide_opened",
        "guided_match_opened",
        "guided_match_started",
        "guided_match_step_completed",
        "guided_match_mission_selected",
        "guided_match_completed",
        "guided_match_abandoned",
        "guided_match_rematch_started",
        "guided_match_reset_discarded",
        "battle_tracker_opened",
        "battle_tracker_phase_changed",
        "battle_tracker_round_advanced",
        "battle_tracker_vp_adjusted",
        "battle_tracker_combat_resolved",
        "battle_tracker_victory_presented",
        "battle_tracker_reset",
        "match_sync_started",
        "match_sync_connected",
        "match_sync_failed",
        "match_sync_stopped",
        "match_sync_paste_applied",
        "match_history_saved",
        "match_history_loaded",
        "match_history_deleted",
        "onboarding_completed",
        "settings_theme_changed",
        "settings_app_tour_replayed",
        "feature_first_used",
        "deep_link_received",
        "deep_link_applied",
        "deep_link_deferred",
        "deep_link_failed",
        "client_environment_changed",
        "catalog_load_failed",
        "rules_load_failed"
    ]

    private static let allowlistedParameterKeys: Set<String> = AnalyticsMetadataKeys.firebaseParameters

    private static let firebaseNameOverrides: [String: String] = [
        "app_bootstrap_ready": "app_open"
    ]

    static func map(_ entry: LogEntry, appVersion: String?) -> FirebaseAnalyticsEvent? {
        guard allowlistedLogEvents.contains(entry.eventName) else {
            return nil
        }

        var parameters = sanitizedParameters(from: entry.metadata)
        if let appVersion, !appVersion.isEmpty {
            parameters["app_version"] = appVersion
        }
        parameters["log_category"] = entry.category.rawValue

        let firebaseName = firebaseNameOverrides[entry.eventName] ?? entry.eventName
        return FirebaseAnalyticsEvent(name: firebaseName, parameters: parameters)
    }

    private static func sanitizedParameters(from metadata: [String: String]) -> [String: String] {
        FirebaseMetadataSanitizer.sanitize(metadata, allowedKeys: allowlistedParameterKeys)
    }
}
