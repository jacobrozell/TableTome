import SwiftUI
import TabletomeDomain

extension BattlePhaseTrackerView {
    var suggestedSectionTab: BattleTrackerSectionTab {
        BattleTrackerSectionTab.suggested(
            phase: viewModel.trackerState.currentPhase,
            deploymentComplete: deploymentIsComplete,
            roundOpenerIncomplete: viewModel.roundOpenerIsIncomplete,
            gameSystemId: viewModel.gameSystemId
        )
    }

    var showsTabHint: Bool {
        supportsBattleTracker && selectedSectionTab != suggestedSectionTab
    }

    var quickActions: [BattleTrackerQuickAction] {
        guard supportsBattleTracker else { return [] }
        let activeName = viewModel.trackerState.activePlayerIsOne
            ? viewModel.playerOneName
            : viewModel.playerTwoName
        return BattleTrackerQuickActions.actions(
            phase: viewModel.trackerState.currentPhase,
            gameSystemId: viewModel.gameSystemId,
            deploymentComplete: deploymentIsComplete,
            roundOpenerIncomplete: viewModel.roundOpenerIsIncomplete,
            shootingEligibleCount: viewModel.shootingEligibleUnits.count,
            shootInCombatEligibleCount: viewModel.shootInCombatEligibleUnits.count,
            activePlayerName: activeName
        )
    }

    @ViewBuilder
    var tabHintSection: some View {
        BattleTrackerTabHintSection(
            isEmbeddedInGuidedMatch: isEmbeddedInGuidedMatch,
            showsTabHint: showsTabHint,
            suggestedTab: suggestedSectionTab,
            gameSystemId: viewModel.gameSystemId,
            reduceMotion: reduceMotion,
            onSelectSuggestedTab: {
                if suggestedSectionTab == .combat {
                    focusCombatResolverSection()
                } else {
                    selectedSectionTab = suggestedSectionTab
                }
            }
        )
    }

    @ViewBuilder
    var quickActionsSection: some View {
        BattleTrackerQuickActionsSection(
            supportsBattleTracker: supportsBattleTracker,
            actions: quickActions,
            onSelect: handleQuickAction
        )
    }

    func handleQuickAction(_ action: BattleTrackerQuickAction) {
        switch action.target {
        case .sectionTab(let tab):
            if tab == .combat {
                focusCombatResolverSection()
            } else {
                selectedSectionTab = tab
            }
        case .combatResolver:
            focusCombatResolverSection()
        case .victoryPoints:
            selectedSectionTab = .turn
            scrollToVictoryPoints = true
        case .roundChecklist:
            selectedSectionTab = .setup
            scrollToRoundChecklist = true
        }
    }
}
