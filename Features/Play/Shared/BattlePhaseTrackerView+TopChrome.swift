import SwiftUI
import TabletomeDomain

extension BattlePhaseTrackerView {
    @ViewBuilder
    var compactTopChrome: some View {
        if supportsBattleTracker {
            if usesCompactBattleTrackerChrome {
                phoneCompactTopChrome
            } else if usesPadTabbedTwoColumnLayout {
                padTopChrome
            }
        }
    }

    private var phoneCompactTopChrome: some View {
        BattleTrackerPhoneCompactTopChrome(
            gameSystemId: viewModel.gameSystemId,
            battleRound: viewModel.trackerState.battleRound,
            phaseTitle: viewModel.trackerState.currentPhase.title,
            playerOneName: viewModel.playerOneName,
            playerTwoName: viewModel.playerTwoName,
            activePlayerIsOne: viewModel.trackerState.activePlayerIsOne,
            isTopChromeCollapsed: isTopChromeCollapsed,
            isEmbeddedInGuidedMatch: isEmbeddedInGuidedMatch,
            prefersCollapsedBattleChrome: layoutContext.prefersCollapsedBattleChrome,
            selectedSectionTab: $selectedSectionTab,
            onExpand: expandTopChrome,
            onCollapse: collapseTopChrome
        )
    }

    private var padTopChrome: some View {
        BattleTrackerPadTopChrome(
            gameSystemId: viewModel.gameSystemId,
            battleRound: viewModel.trackerState.battleRound,
            phaseTitle: viewModel.trackerState.currentPhase.title,
            playerOneName: viewModel.playerOneName,
            playerTwoName: viewModel.playerTwoName,
            activePlayerIsOne: viewModel.trackerState.activePlayerIsOne,
            isTopChromeCollapsed: isTopChromeCollapsed,
            isEmbeddedInGuidedMatch: isEmbeddedInGuidedMatch,
            selectedSectionTab: $selectedSectionTab,
            onExpand: expandTopChrome,
            onCollapse: collapseTopChrome
        )
    }

    func applyCompactTopChromeDefault() {
        let prefersCollapsedByDefault = layoutContext.prefersCollapsedBattleChrome
            || (isEmbeddedInGuidedMatch && usesCompactBattleTrackerChrome)
        guard prefersCollapsedByDefault, !topChromeExpandedInLandscape else { return }
        guard !isTopChromeCollapsed else { return }
        withAnimation(chromeAnimation) {
            isTopChromeCollapsed = true
        }
    }

    func expandTopChrome() {
        withAnimation(chromeAnimation) {
            isTopChromeCollapsed = false
        }
    }

    func collapseTopChrome() {
        withAnimation(chromeAnimation) {
            isTopChromeCollapsed = true
        }
    }

    /// Battle chrome collapse/expand animation, suppressed under Reduce Motion.
    var chromeAnimation: Animation? {
        reduceMotion ? nil : .easeInOut(duration: 0.2)
    }
}
