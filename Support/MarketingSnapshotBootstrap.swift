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
            return
        }

        if let gameSystemId = openGameGuideGameSystemId {
            router.openGameGuide(gameSystemId: gameSystemId)
            return
        }

        if AppLaunchArguments.shouldOpenGuidedMatch {
            router.openGuidedMatch(gameSystemId: OnboardingCompletion.defaultGameSystemId)
            return
        }

        if let query = openRulesSearchQuery {
            router.openRulesSearch(
                gameSystemId: OnboardingCompletion.spearheadGameSystemId,
                query: query
            )
            return
        }
    }

    static func preparePlayHomeSnapshot() {
        OnboardingStore.markCompleted()
        FirstSessionStore.recordOnboardingChoice(gameSystemId: OnboardingCompletion.spearheadGameSystemId)
        FirstSessionStore.recordGameGuideOpened()
    }

    private static func value(following flag: String) -> String? {
        let args = ProcessInfo.processInfo.arguments
        guard let index = args.firstIndex(of: flag), index + 1 < args.count else { return nil }
        return args[index + 1]
    }
}
