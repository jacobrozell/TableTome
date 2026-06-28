import Foundation
import TabletomeDomain

extension Notification.Name {
    static let firstSessionStoreDidChange = Notification.Name("firstSessionStoreDidChange")
}

/// Tracks first-session milestones so Play can show a continuation card and hobby tabs defer intros.
enum FirstSessionStore: Sendable {
    private static let choiceKey = "first_session_onboarding_choice"
    private static let wh40kVariantKey = "first_session_wh40k_variant"
    private static let hasOpenedGuideKey = "first_session_has_opened_game_guide"
    private static let collectionVisitsKey = "first_session_collection_visits"
    private static let listsVisitsKey = "first_session_lists_visits"
    private static let setupCompleteKey = "first_session_setup_complete"
    private static let firstBattleRoundKey = "first_session_first_battle_round"
    private static let modelsNudgeSeenKey = "first_session_models_nudge_seen"
    private static let roundOneMilestoneSeenKey = "first_session_round_one_milestone_seen"

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

    static var onboardingWh40kVariant: String? {
        get { UserDefaults.standard.string(forKey: wh40kVariantKey) }
        set {
            if let newValue {
                UserDefaults.standard.set(newValue, forKey: wh40kVariantKey)
            } else {
                UserDefaults.standard.removeObject(forKey: wh40kVariantKey)
            }
        }
    }

    static var hasOpenedGameGuide: Bool {
        get { UserDefaults.standard.bool(forKey: hasOpenedGuideKey) }
        set { UserDefaults.standard.set(newValue, forKey: hasOpenedGuideKey) }
    }

    static func recordOnboardingChoice(gameSystemId: String, wh40kVariant: String? = nil) {
        onboardingChoice = gameSystemId
        if let wh40kVariant {
            onboardingWh40kVariant = wh40kVariant
        } else if gameSystemId != GameSystemId.wh40k11e.rawValue {
            onboardingWh40kVariant = nil
        }
        notifyChange()
    }

    static func recordGameGuideOpened() {
        hasOpenedGameGuide = true
        notifyChange()
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
        PlayContinuationResolver.current() != nil
    }

    static func shouldPromoteSampleData() -> Bool {
        hasOpenedGameGuide || UserDefaults.standard.integer(forKey: collectionVisitsKey) >= 2
    }

    static func shouldOfferMusterIntro(hasSeenMusterIntro: Bool, onboardingComplete: Bool) -> Bool {
        guard !hasSeenMusterIntro, onboardingComplete else { return false }
        return hasOpenedGameGuide || UserDefaults.standard.integer(forKey: listsVisitsKey) >= 2
    }

    static func shouldOfferCollectionIntro(hasSeenCollectionIntro: Bool, onboardingComplete: Bool) -> Bool {
        guard !hasSeenCollectionIntro, onboardingComplete else { return false }
        return hasOpenedGameGuide || UserDefaults.standard.integer(forKey: collectionVisitsKey) >= 2
    }

    /// True when the user has no tracked units yet — coach card stays relevant.
    static func shouldShowCollectionFirstStepsCoach(
        hasSeenCollectionIntro: Bool,
        hasDismissedCoach: Bool,
        totalUnitCount: Int
    ) -> Bool {
        guard hasSeenCollectionIntro, !hasDismissedCoach, totalUnitCount == 0 else { return false }
        return true
    }

    static var hasCompletedSetup: Bool {
        UserDefaults.standard.bool(forKey: setupCompleteKey)
    }

    static var hasCompletedFirstBattleRound: Bool {
        UserDefaults.standard.bool(forKey: firstBattleRoundKey)
    }

    static func recordSetupComplete() {
        UserDefaults.standard.set(true, forKey: setupCompleteKey)
        notifyChange()
    }

    static func recordFirstBattleRound() {
        UserDefaults.standard.set(true, forKey: firstBattleRoundKey)
        notifyChange()
    }

    static var hasSeenModelsNudge: Bool {
        UserDefaults.standard.bool(forKey: modelsNudgeSeenKey)
    }

    static func markModelsNudgeSeen() {
        UserDefaults.standard.set(true, forKey: modelsNudgeSeenKey)
    }

    static func shouldShowModelsNudge() -> Bool {
        guard ReleaseSurface.showsBenchTab else { return false }
        guard !hasSeenModelsNudge else { return false }
        return hasCompletedSetup || hasCompletedFirstBattleRound
    }

    static var hasSeenRoundOneMilestone: Bool {
        UserDefaults.standard.bool(forKey: roundOneMilestoneSeenKey)
    }

    static func markRoundOneMilestoneSeen() {
        UserDefaults.standard.set(true, forKey: roundOneMilestoneSeenKey)
    }

    static func shouldShowRoundOneMilestone(isEmbeddedInGuidedMatch: Bool) -> Bool {
        guard isEmbeddedInGuidedMatch else { return false }
        guard hasCompletedFirstBattleRound else { return false }
        return !hasSeenRoundOneMilestone
    }

    static func shouldEmphasizePlayTab() -> Bool {
        guard PlayContinuationResolver.current() == nil else { return false }
        return !hasOpenedGameGuide && !hasCompletedSetup
    }

    /// Hides the full game list on Play home until the user picks from the chooser or opens a guide.
    static func shouldHideAllGamesList() -> Bool {
        onboardingChoice == nil && !hasOpenedGameGuide
    }

    /// Shows a "Later" badge on hobby tabs until the player has engaged with Play.
    static func shouldDeferHobbyTabs() -> Bool {
        !hasOpenedGameGuide && !hasCompletedSetup && !hasCompletedFirstBattleRound
    }

    /// Hides hobby tabs until the player has engaged with Play.
    static func shouldHideHobbyTabs() -> Bool {
        shouldDeferHobbyTabs()
    }

    static func clearPersistedState() {
        UserDefaults.standard.removeObject(forKey: choiceKey)
        UserDefaults.standard.removeObject(forKey: wh40kVariantKey)
        UserDefaults.standard.removeObject(forKey: hasOpenedGuideKey)
        UserDefaults.standard.removeObject(forKey: collectionVisitsKey)
        UserDefaults.standard.removeObject(forKey: listsVisitsKey)
        UserDefaults.standard.removeObject(forKey: setupCompleteKey)
        UserDefaults.standard.removeObject(forKey: firstBattleRoundKey)
        UserDefaults.standard.removeObject(forKey: modelsNudgeSeenKey)
        UserDefaults.standard.removeObject(forKey: roundOneMilestoneSeenKey)
        notifyChange()
    }

    private static func notifyChange() {
        NotificationCenter.default.post(name: .firstSessionStoreDidChange, object: nil)
    }
}
