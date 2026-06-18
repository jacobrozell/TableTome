import SwiftUI
import TabletomeDomain

extension BattlePhaseTrackerView {
    var suggestedSectionTab: BattleTrackerSectionTab {
        BattleTrackerSectionTab.suggested(
            phase: viewModel.trackerState.currentPhase,
            deploymentComplete: deploymentIsComplete,
            roundOpenerIncomplete: viewModel.roundOpenerIsIncomplete
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
            deploymentComplete: deploymentIsComplete,
            roundOpenerIncomplete: viewModel.roundOpenerIsIncomplete,
            shootingEligibleCount: viewModel.shootingEligibleUnits.count,
            shootInCombatEligibleCount: viewModel.shootInCombatEligibleUnits.count,
            activePlayerName: activeName
        )
    }

    @ViewBuilder
    var tabHintSection: some View {
        if showsTabHint {
            BattleTrackerTabHintBanner(suggestedTab: suggestedSectionTab) {
                withAnimation(.easeInOut(duration: 0.25)) {
                    selectedSectionTab = suggestedSectionTab
                }
                if suggestedSectionTab == .combat {
                    scrollToCombatResolver = true
                }
            }
        }
    }

    @ViewBuilder
    var quickActionsSection: some View {
        if supportsBattleTracker, !quickActions.isEmpty {
            BattleTrackerQuickActionsList(actions: quickActions, onSelect: handleQuickAction)
        }
    }

    func handleQuickAction(_ action: BattleTrackerQuickAction) {
        switch action.target {
        case .sectionTab(let tab):
            selectedSectionTab = tab
            if tab == .combat {
                scrollToCombatResolver = true
            }
        case .combatResolver:
            selectedSectionTab = .combat
            scrollToCombatResolver = true
        case .victoryPoints:
            selectedSectionTab = .turn
            scrollToVictoryPoints = true
        case .roundChecklist:
            selectedSectionTab = .setup
            scrollToRoundChecklist = true
        }
    }
}
