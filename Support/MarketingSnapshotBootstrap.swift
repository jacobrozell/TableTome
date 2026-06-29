import Foundation
import TabletomeDomain

/// Routes cold-launch screenshot automation to the correct tab and deep link.
enum MarketingSnapshotBootstrap {
    static let snapshotPlayHome = "-snapshot_play_home"
    static let openGameGuide = "-open_game_guide"
    static let openRulesSearch = "-open_rules_search"
    static let snapshotGuidedMatchArmies = "-snapshot_guided_match_armies"
    static let snapshotBattleCombat = "-snapshot_battle_combat"
    static let openUnitFocus = "-open_unit_focus"
    static let loadSampleCollection = "-load_sample_collection"
    static let snapshotModelsCollection = "-snapshot_models_collection"
    static let snapshotTab = "-snapshot_tab"

    static var forcedSnapshotTab: AppTab? {
        guard let value = value(following: snapshotTab) else { return nil }
        switch value {
        case "play": return .learn
        case "rules": return .search
        case "models": return .bench
        case "settings": return .settings
        default: return nil
        }
    }

    static var shouldSnapshotPlayHome: Bool {
        ProcessInfo.processInfo.arguments.contains(snapshotPlayHome)
    }

    static var shouldSnapshotGuidedMatchArmies: Bool {
        ProcessInfo.processInfo.arguments.contains(snapshotGuidedMatchArmies)
    }

    static var shouldSnapshotBattleCombat: Bool {
        ProcessInfo.processInfo.arguments.contains(snapshotBattleCombat)
    }

    static var shouldOpenUnitFocus: Bool {
        ProcessInfo.processInfo.arguments.contains(openUnitFocus)
    }

    static var shouldLoadSampleCollection: Bool {
        ProcessInfo.processInfo.arguments.contains(loadSampleCollection)
            || ProcessInfo.processInfo.arguments.contains(snapshotModelsCollection)
    }

    static var shouldSnapshotModelsCollection: Bool {
        ProcessInfo.processInfo.arguments.contains(snapshotModelsCollection)
    }

    /// Any `-snapshot_*` flag or screenshot deep-link argument is active.
    static var isMarketingCapture: Bool {
        let args = ProcessInfo.processInfo.arguments
        if args.contains(where: { $0.hasPrefix("-snapshot_") }) { return true }
        if args.contains(openUnitFocus) { return true }
        if args.contains(openGameGuide) { return true }
        if args.contains(openRulesSearch) { return true }
        return forcedSnapshotTab != nil
    }

    /// Hide Guided Match sidebar so battle / unit-focus frames fill the detail column.
    static var hidesGuidedMatchSidebar: Bool {
        shouldSnapshotBattleCombat || shouldOpenUnitFocus
    }

    /// Suppress first-session coaching banners and coach cards during automation capture.
    static var suppressesCoachingUI: Bool {
        isMarketingCapture
    }

    static var openGameGuideGameSystemId: String? {
        value(following: openGameGuide)
    }

    static var openRulesSearchQuery: String? {
        value(following: openRulesSearch)
    }

    @MainActor
    static func applyNavigationIfNeeded(router: AppRouter) {
        let args = ProcessInfo.processInfo.arguments

        if shouldSnapshotPlayHome {
            preparePlayHomeSnapshot()
        }

        if shouldSnapshotModelsCollection {
            router.selectedTab = .bench
            router.hobbyTab = .armies
        }

        if let gameSystemId = openGameGuideGameSystemId {
            router.openGameGuide(gameSystemId: gameSystemId)
        } else if AppLaunchArguments.shouldOpenGuidedMatch {
            router.openGuidedMatch(gameSystemId: OnboardingCompletion.defaultGameSystemId)
        } else if let query = openRulesSearchQuery {
            router.openRulesSearch(
                gameSystemId: OnboardingCompletion.spearheadGameSystemId,
                query: query
            )
        }

        if let tab = forcedSnapshotTab {
            router.selectedTab = tab
        }
    }

    /// Re-applies tab selection after navigation settles (iPad tab bar highlight desync).
    @MainActor
    static func reinforceTabSelectionIfNeeded(router: AppRouter) {
        guard let tab = forcedSnapshotTab else { return }
        Task {
            for delayMs in [100, 400, 900] {
                try? await Task.sleep(for: .milliseconds(delayMs))
                router.selectedTab = tab
            }
        }
    }

    static func preparePlayHomeSnapshot() {
        OnboardingStore.markCompleted()
        FirstSessionStore.recordOnboardingChoice(gameSystemId: OnboardingCompletion.spearheadGameSystemId)
        FirstSessionStore.recordGameGuideOpened()
    }

    /// Marks coaching milestones seen so battle and setup frames stay clean after `-reset_user_defaults`.
    static func prepareCaptureStateIfNeeded() {
        guard suppressesCoachingUI else { return }
        FirstSessionStore.markModelsNudgeSeen()
        FirstSessionStore.markRoundOneMilestoneSeen()
        FirstSessionStore.recordFirstBattleRound()
        NewPlayerTipsStore.markBattleTrackerCoachSeen()
        NewPlayerTipsStore.dismissCombatSequencePrimer()
        NewPlayerTipsStore.markPhysicalDiceResolverHintSeen()
        NewPlayerTipsStore.dismissHeroRoundOneNudge()
    }

    private static func value(following flag: String) -> String? {
        let args = ProcessInfo.processInfo.arguments
        guard let index = args.firstIndex(of: flag), index + 1 < args.count else { return nil }
        return args[index + 1]
    }
}
