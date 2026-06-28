import Foundation
import SwiftData
import TabletomeDomain
import TabletomeHobbyData

/// Applies launch-argument fixtures for UI tests and screenshot automation.
enum UITestLaunchConfiguration {
    static let resetUserDefaults = "-reset_user_defaults"
    static let modelsFlow = "-ui_testing_models_flow"
    static let onboardingChoice = "-onboarding_choice"

    @MainActor
    static func applyIfNeeded(modelContext: ModelContext) {
        let args = ProcessInfo.processInfo.arguments

        if args.contains(resetUserDefaults) {
            FirstSessionStore.clearPersistedState()
            OnboardingStore.clearPersistedState()
            ActiveGameContextPersistence.resetForTests()
            CollectionStore.clearAll(in: modelContext)
            for gameSystemId in GameSystemId.allCases {
                MatchSetupStore.reset(gameSystemId: gameSystemId)
                BattleTrackerStore.reset(gameSystemId: gameSystemId)
            }
        }

        if args.contains(MarketingSnapshotBootstrap.snapshotPlayHome) {
            MarketingSnapshotBootstrap.preparePlayHomeSnapshot()
        }

        if args.contains(MarketingSnapshotBootstrap.snapshotModelsCollection)
            || args.contains(MarketingSnapshotBootstrap.loadSampleCollection) {
            OnboardingStore.markCompleted()
            FirstSessionStore.recordGameGuideOpened()
            if let choice = value(following: onboardingChoice, in: args) {
                FirstSessionStore.recordOnboardingChoice(gameSystemId: choice)
            } else {
                FirstSessionStore.recordOnboardingChoice(
                    gameSystemId: OnboardingCompletion.spearheadGameSystemId
                )
            }
            let cfg = HobbyConfig.current(modelContext)
            cfg.hasSeenOnboarding = true
            cfg.hasSeenCollectionIntro = true
            cfg.hasDismissedCollectionFirstStepsCoach = true
            try? modelContext.save()
        }

        if let choice = value(following: onboardingChoice, in: args) {
            FirstSessionStore.recordOnboardingChoice(gameSystemId: choice)
            ActiveGameContextPersistence.gameSystemId = choice
        }

        if args.contains(modelsFlow) {
            OnboardingStore.markCompleted()
            FirstSessionStore.recordGameGuideOpened()
            let cfg = HobbyConfig.current(modelContext)
            cfg.hasSeenOnboarding = true
            cfg.hasSeenCollectionIntro = true
            cfg.hasDismissedCollectionFirstStepsCoach = true
            try? modelContext.save()
        }
    }

    private static func value(following flag: String, in args: [String]) -> String? {
        guard let index = args.firstIndex(of: flag), index + 1 < args.count else { return nil }
        return args[index + 1]
    }
}
