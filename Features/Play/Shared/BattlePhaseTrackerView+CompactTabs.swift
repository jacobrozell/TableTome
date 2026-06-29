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
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: showsBattleTrackerCoach)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: selectedSectionTab)
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
            if viewModel.playContext.capabilities.showsBattleTacticDecks,
               viewModel.trackerState.battleRound > 1,
               viewModel.roundOpenerIsIncomplete {
                NewMainTurnReminderBanner(round: viewModel.trackerState.battleRound)
            }
            startOfRoundHelper
            deploymentSection
            roundOpenerChecklistSection
        }
    }

    var turnTabContent: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            phasePlaybookSection
            coachSection
            guideSection
            startOfRoundHelper
            if !showsDedicatedCombatTab {
                shootingPhaseHelper
                combatActivationSection
            }
            phaseActionNudgeSection
            turnHandoffSection
            scoringReminderSection
            heroRoundOneSection
            victoryPointsSection
            roundOpenerSection
            if !showsSlimTurnTab {
                quickActionsSection
                BattleTrackerControlPanel(
                    viewModel: viewModel,
                    showsPhaseGuidanceInPicker: !showsPhasePlaybook,
                    showsAdvancePhaseButton: !showsPhasePlaybook
                )
            }
            movementPhaseHelper
        }
    }

    var combatTabContent: some View {
        Group {
            if viewModel.playContext.capabilities.showsActivationBar {
                scCombatTabContent
            } else if usesPhoneLandscapeCombatSplit {
                phoneLandscapeCombatSplitLayout
            } else {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                    if showsDedicatedCombatTab {
                        shootingPhaseHelper
                    }
                    combatActivationSection
                    damageUndoSection
                    combatPhaseHelper
                    shootInCombatPhaseHelper
                    combatResolverSection()
                    armyTrackerSection(wideLayout: false)
                }
            }
        }
    }

    var scCombatTabContent: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            scTrackerPlaceholder
        }
    }

    var armyTabContent: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            armyTrackerSection(wideLayout: false)
            if viewModel.trackerState.showAllAbilities {
                trackerContent
            } else {
                passiveAbilitiesSection
            }
            secondarySections
        }
    }

    @ViewBuilder
    var movementPhaseHelper: some View {
        if showsSpearheadBattleChrome, viewModel.trackerState.currentPhase == .movement {
            MovementActionPicker(action: $movementAction)
        }
    }

    @ViewBuilder
    var combatPhaseHelper: some View {
        if showsSpearheadBattleChrome,
           viewModel.trackerState.currentPhase == .combat
            || viewModel.trackerState.currentPhase == .anyCombat {
            PileInGuideCard()
        }
    }
}
