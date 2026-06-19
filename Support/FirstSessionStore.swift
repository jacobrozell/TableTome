import Foundation

/// Tracks first-session milestones so Play can show a continuation card and hobby tabs defer intros.
enum FirstSessionStore: Sendable {
    private static let choiceKey = "first_session_onboarding_choice"
    private static let hasOpenedGuideKey = "first_session_has_opened_game_guide"
    private static let collectionVisitsKey = "first_session_collection_visits"
    private static let listsVisitsKey = "first_session_lists_visits"

    static var onboardingChoice: String? {
        get { UserDefaults.standard.string(forKey: choiceKey) }
        set {
            if let newValue {
                UserDefaults.standard.set(newValue, forKey: choiceKey)
            } else {
                UserDefaults.standard.removeObject(forKey: choiceKey)
            }
        }
    }

    static var hasOpenedGameGuide: Bool {
        get { UserDefaults.standard.bool(forKey: hasOpenedGuideKey) }
        set { UserDefaults.standard.set(newValue, forKey: hasOpenedGuideKey) }
    }

    static func recordOnboardingChoice(gameSystemId: String) {
        onboardingChoice = gameSystemId
    }

    static func recordGameGuideOpened() {
        hasOpenedGameGuide = true
    }

    @discardableResult
    static func incrementCollectionVisits() -> Int {
        let count = UserDefaults.standard.integer(forKey: collectionVisitsKey) + 1
        UserDefaults.standard.set(count, forKey: collectionVisitsKey)
        return count
    }

    @discardableResult
    static func incrementListsVisits() -> Int {
        let count = UserDefaults.standard.integer(forKey: listsVisitsKey) + 1
        UserDefaults.standard.set(count, forKey: listsVisitsKey)
        return count
    }

    static func shouldShowContinueCard() -> Bool {
        onboardingChoice != nil && !hasOpenedGameGuide
    }

    static func shouldPromoteSampleData() -> Bool {
        hasOpenedGameGuide || UserDefaults.standard.integer(forKey: collectionVisitsKey) >= 2
    }

    static func shouldOfferMusterIntro(hasSeenMusterIntro: Bool, onboardingComplete: Bool) -> Bool {
        guard !hasSeenMusterIntro, onboardingComplete else { return false }
        return hasOpenedGameGuide || UserDefaults.standard.integer(forKey: listsVisitsKey) >= 2
    }

    static func clearPersistedState() {
        UserDefaults.standard.removeObject(forKey: choiceKey)
        UserDefaults.standard.removeObject(forKey: hasOpenedGuideKey)
        UserDefaults.standard.removeObject(forKey: collectionVisitsKey)
        UserDefaults.standard.removeObject(forKey: listsVisitsKey)
    }
}
