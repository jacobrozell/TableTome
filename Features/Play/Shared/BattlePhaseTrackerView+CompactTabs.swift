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

    var showsScoringContext: Bool {
        let phase = viewModel.trackerState.currentPhase
        if phase == .endOfTurn { return true }
        return viewModel.playContext.capabilities.showsActivationBar && phase == .scoring
    }

    var turnTabContent: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            if showsSpearheadBattleChrome {
                BattleTrackerRoundBar(viewModel: viewModel)
            }
            if showsScoringContext {
                victoryPointsSection
            }
            if viewModel.roundOpenerIsIncomplete {
                roundOpenerChecklistSection
            }
            if viewModel.playContext.capabilities.showsBattleTacticDecks,
               viewModel.trackerState.battleRound > 1,
               viewModel.roundOpenerIsIncomplete {
                NewMainTurnReminderBanner(round: viewModel.trackerState.battleRound)
            }
            phasePlaybookSection
            battleTacticCommandGuideSection
            coachSection
            guideSection
            startOfRoundHelper
            if !showsDedicatedCombatTab {
                shootingPhaseHelper
                combatActivationSection
            }
            phaseActionNudgeSection
            reinforcementCallBannerSection
            turnHandoffSection
            scoringReminderSection
            heroRoundOneSection
            if !showsScoringContext {
                victoryPointsSection
            }
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
                    combatResolverSection()
                    damageUndoSection
                    combatPhaseHelper
                    shootInCombatPhaseHelper
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
        if viewModel.trackerState.currentPhase == .movement {
            if showsSpearheadBattleChrome {
                callForReinforcementsCard
            }
            MovementRangeCard(
                playerName: viewModel.trackerState.activePlayerIsOne
                    ? viewModel.playerOneName
                    : viewModel.playerTwoName,
                army: viewModel.activeArmy,
                woundsRemaining: viewModel.trackerState.unitWoundsRemaining,
                armyId: viewModel.activeArmy?.id
            )
            if showsSpearheadBattleChrome {
                MovementActionPicker(
                    action: $movementAction,
                    gameSystemId: viewModel.gameSystemId.rawValue
                )
            }
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
