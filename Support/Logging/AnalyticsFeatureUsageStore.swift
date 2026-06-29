import Foundation
import TabletomeDomain

/// Lifetime feature-adoption flags for Firebase user-property segmentation.
///
/// Answers product questions like "Models tab vs guided-match-only" and "AoS vs 40k usage"
/// without storing PII. Visit counts are coarse buckets only.
enum AnalyticsFeatureUsageStore: Sendable {
    enum Feature: String, Sendable {
        case modelsTab = "models_tab"
        case listsTab = "lists_tab"
        case playTab = "play_tab"
        case rulesTab = "rules_tab"
        case settingsTab = "settings_tab"
        case guidedMatch = "guided_match"
        case gameGuide = "game_guide"
    }

    private static let usedPrefix = "analytics_used_"
    private static let visitPrefix = "analytics_visits_"
    private static let activeGameSystemKey = "analytics_active_game_system"
    private static let lastMatchSystemKey = "analytics_last_match_system"
    private static let matchSystemsKey = "analytics_match_system_sections"
    private static let guidedMatchStartsKey = "analytics_guided_match_starts"

    @discardableResult
    static func recordTabVisit(_ tab: AppTab) -> Feature? {
        guard let feature = feature(for: tab) else { return nil }
        return recordFeature(feature) ? feature : nil
    }

    private static func feature(for tab: AppTab) -> Feature? {
        switch tab {
        case .bench: .modelsTab
        case .muster: .listsTab
        case .learn: .playTab
        case .search: .rulesTab
        case .settings: .settingsTab
        }
    }

    @discardableResult
    static func recordFeature(_ feature: Feature) -> Bool {
        let key = usedKey(for: feature)
        let isFirst = !UserDefaults.standard.bool(forKey: key)
        UserDefaults.standard.set(true, forKey: key)
        incrementVisits(for: feature)
        return isFirst
    }

    static func recordGuidedMatchStarted(gameSystemId: String) -> Bool {
        let isFirstMatch = !UserDefaults.standard.bool(forKey: usedKey(for: .guidedMatch))
        _ = recordFeature(.guidedMatch)
        let starts = UserDefaults.standard.integer(forKey: guidedMatchStartsKey) + 1
        UserDefaults.standard.set(starts, forKey: guidedMatchStartsKey)
        UserDefaults.standard.set(gameSystemId, forKey: lastMatchSystemKey)
        appendMatchSystemSection(for: gameSystemId)
        return isFirstMatch
    }

    static func recordGameGuideOpened(gameSystemId: String) {
        _ = recordFeature(.gameGuide)
        UserDefaults.standard.set(gameSystemId, forKey: activeGameSystemKey)
    }

    static func setActiveGameSystem(_ gameSystemId: String) {
        UserDefaults.standard.set(gameSystemId, forKey: activeGameSystemKey)
    }

    static func userPropertyValues(activeGameSystemId: String? = nil) -> [String: String] {
        if let activeGameSystemId {
            UserDefaults.standard.set(activeGameSystemId, forKey: activeGameSystemKey)
        }

        var values: [String: String] = [
            "used_models": boolString(hasUsed(.modelsTab)),
            "used_lists": boolString(hasUsed(.listsTab)),
            "used_guided_match": boolString(hasUsed(.guidedMatch)),
            "used_rules": boolString(hasUsed(.rulesTab)),
            "used_game_guide": boolString(hasUsed(.gameGuide) || FirstSessionStore.hasOpenedGameGuide),
            "user_segment": userSegment(),
            "guided_match_starts": guidedMatchStartsBucket()
        ]

        if let active = UserDefaults.standard.string(forKey: activeGameSystemKey), !active.isEmpty {
            values["active_game_system"] = active
            values["active_game_section"] = TabletomeAnalytics.gameSystemSection(for: active)
        }

        if let lastMatch = UserDefaults.standard.string(forKey: lastMatchSystemKey), !lastMatch.isEmpty {
            values["last_match_system"] = lastMatch
            values["last_match_section"] = TabletomeAnalytics.gameSystemSection(for: lastMatch)
        }

        if let sections = UserDefaults.standard.string(forKey: matchSystemsKey), !sections.isEmpty {
            values["match_system_sections"] = sections
        }

        values["models_tab_visits"] = visitBucket(for: .modelsTab)
        values["lists_tab_visits"] = visitBucket(for: .listsTab)

        return values
    }

    static func clearPersistedState() {
        for feature in Feature.allCases {
            UserDefaults.standard.removeObject(forKey: usedKey(for: feature))
            UserDefaults.standard.removeObject(forKey: visitKey(for: feature))
        }
        UserDefaults.standard.removeObject(forKey: activeGameSystemKey)
        UserDefaults.standard.removeObject(forKey: lastMatchSystemKey)
        UserDefaults.standard.removeObject(forKey: matchSystemsKey)
        UserDefaults.standard.removeObject(forKey: guidedMatchStartsKey)
    }

    private static func hasUsed(_ feature: Feature) -> Bool {
        UserDefaults.standard.bool(forKey: usedKey(for: feature))
    }

    private static func incrementVisits(for feature: Feature) {
        let key = visitKey(for: feature)
        UserDefaults.standard.set(UserDefaults.standard.integer(forKey: key) + 1, forKey: key)
    }

    private static func visitBucket(for feature: Feature) -> String {
        bucket(UserDefaults.standard.integer(forKey: visitKey(for: feature)))
    }

    private static func guidedMatchStartsBucket() -> String {
        bucket(UserDefaults.standard.integer(forKey: guidedMatchStartsKey))
    }

    private static func bucket(_ count: Int) -> String {
        switch count {
        case 0: "0"
        case 1: "1"
        case 2...5: "2_5"
        default: "6_plus"
        }
    }

    private static func userSegment() -> String {
        let models = hasUsed(.modelsTab)
        let lists = hasUsed(.listsTab)
        let guided = hasUsed(.guidedMatch)

        if !models, !lists, guided { return "guided_match_only" }
        if models, !lists, !guided { return "models_only" }
        if !models, lists, !guided { return "lists_only" }
        if models, lists { return "full_hobby" }
        if models, !lists, guided { return "play_and_models" }
        if !models, lists, guided { return "play_and_lists" }
        return "exploring"
    }

    private static func appendMatchSystemSection(for gameSystemId: String) {
        let section = TabletomeAnalytics.gameSystemSection(for: gameSystemId)
        var sections = Set(
            (UserDefaults.standard.string(forKey: matchSystemsKey) ?? "")
                .split(separator: ",")
                .map(String.init)
        )
        sections.insert(section)
        let joined = sections.sorted().joined(separator: ",")
        UserDefaults.standard.set(String(joined.prefix(36)), forKey: matchSystemsKey)
    }

    private static func usedKey(for feature: Feature) -> String {
        usedPrefix + feature.rawValue
    }

    private static func visitKey(for feature: Feature) -> String {
        visitPrefix + feature.rawValue
    }

    private static func boolString(_ value: Bool) -> String {
        value ? "true" : "false"
    }
}

private extension AnalyticsFeatureUsageStore.Feature {
    static var allCases: [Self] {
        [.modelsTab, .listsTab, .playTab, .rulesTab, .settingsTab, .guidedMatch, .gameGuide]
    }
}
