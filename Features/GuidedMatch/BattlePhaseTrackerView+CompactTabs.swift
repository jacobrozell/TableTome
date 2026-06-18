import SwiftUI
import TabletomeDomain

extension BattlePhaseTrackerView {
    var compactLayoutSpacing: CGFloat {
        layoutContext == .phoneLandscape
            ? DesignTokens.phoneLandscapeSectionSpacing
            : DesignTokens.Spacing.lg
    }

    var compactLayout: some View {
        VStack(alignment: .leading, spacing: compactLayoutSpacing) {
            tabHintSection
            compactTabContent
        }
        .animation(.easeInOut(duration: 0.25), value: showsBattleTrackerCoach)
        .animation(.easeInOut(duration: 0.25), value: selectedSectionTab)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    var compactTabContent: some View {
        switch selectedSectionTab {
        case .setup:
            setupTabContent
        case .turn:
            turnTabContent
        case .combat:
            combatTabContent
        case .army:
            armyTabContent
        }
    }

    var setupTabContent: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            if viewModel.trackerState.battleRound > 1, viewModel.roundOpenerIsIncomplete {
                NewMainTurnReminderBanner(round: viewModel.trackerState.battleRound)
            }
            startOfRoundHelper
            deploymentSection
            roundAndScoreSection
        }
    }

    var turnTabContent: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            coachSection
            turnHandoffSection
            scoringReminderSection
            roundOpenerSection
            quickActionsSection
            guideSection
            shootingPhaseHelper
            roundAndScoreSection
            BattleTrackerControlPanel(viewModel: viewModel)
            movementPhaseHelper
        }
    }

    var combatTabContent: some View {
        Group {
            if usesPhoneLandscapeCombatSplit {
                phoneLandscapeCombatSplitLayout
            } else {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                    damageUndoSection
                    combatPhaseHelper
                    shootInCombatPhaseHelper
                    combatResolverSection()
                }
            }
        }
    }

    var armyTabContent: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            armyTrackerSection(wideLayout: false)
            trackerContent
            secondarySections
        }
    }

    @ViewBuilder
    var movementPhaseHelper: some View {
        if viewModel.trackerState.currentPhase == .movement {
            MovementActionPicker(action: $movementAction)
        }
    }

    @ViewBuilder
    var combatPhaseHelper: some View {
        if viewModel.trackerState.currentPhase == .combat
            || viewModel.trackerState.currentPhase == .anyCombat {
            PileInGuideCard()
        }
    }
}
