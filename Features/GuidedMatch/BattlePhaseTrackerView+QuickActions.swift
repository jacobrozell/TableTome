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
    var modelsMilestoneSection: some View {
        if FirstSessionStore.shouldShowModelsNudge() {
            NewPlayerMilestoneBanner {
                FirstSessionStore.markModelsNudgeSeen()
            }
        }
    }

    @ViewBuilder
    var tabHintSection: some View {
        modelsMilestoneSection
        if showsTabHint {
            BattleTrackerTabHintBanner(suggestedTab: suggestedSectionTab, gameSystemId: viewModel.gameSystemId) {
                withAnimation(.easeInOut(duration: 0.25)) {
                    selectedSectionTab = suggestedSectionTab
                }
                if suggestedSectionTab == .combat || (
                    viewModel.playContext.usesGuidedBattleTracker && suggestedSectionTab == .turn
                    && viewModel.trackerState.currentPhase.isCombatRelated
                ) {
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
            } else if tab == .turn,
                      viewModel.playContext.usesGuidedBattleTracker,
                      ReleaseSurface.showsCombatResolver(for: viewModel.gameSystemId),
                      viewModel.trackerState.currentPhase.isCombatRelated {
                scrollToCombatResolver = true
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
