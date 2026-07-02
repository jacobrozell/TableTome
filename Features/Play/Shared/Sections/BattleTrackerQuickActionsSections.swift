import SwiftUI
import TabletomeDomain

struct BattleTrackerTabHintSection: View {
    let isEmbeddedInGuidedMatch: Bool
    let showsTabHint: Bool
    let suggestedTab: BattleTrackerSectionTab
    let gameSystemId: GameSystemId
    let reduceMotion: Bool
    let onSelectSuggestedTab: () -> Void

    var body: some View {
        if !MarketingSnapshotBootstrap.suppressesCoachingUI,
           FirstSessionStore.shouldShowRoundOneMilestone(isEmbeddedInGuidedMatch: isEmbeddedInGuidedMatch) {
            RoundOneMilestoneBanner {
                FirstSessionStore.markRoundOneMilestoneSeen()
            }
        }
        if !MarketingSnapshotBootstrap.suppressesCoachingUI,
           !isEmbeddedInGuidedMatch,
           FirstSessionStore.shouldShowModelsNudge() {
            NewPlayerMilestoneBanner {
                FirstSessionStore.markModelsNudgeSeen()
            }
        }
        if !MarketingSnapshotBootstrap.suppressesCoachingUI, showsTabHint {
            BattleTrackerTabHintBanner(suggestedTab: suggestedTab, gameSystemId: gameSystemId) {
                withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) {
                    onSelectSuggestedTab()
                }
            }
        }
    }
}

struct BattleTrackerQuickActionsSection: View {
    let supportsBattleTracker: Bool
    let actions: [BattleTrackerQuickAction]
    let onSelect: (BattleTrackerQuickAction) -> Void

    var body: some View {
        if supportsBattleTracker, !actions.isEmpty {
            BattleTrackerQuickActionsList(actions: actions, onSelect: onSelect)
        }
    }
}
