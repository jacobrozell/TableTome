import SwiftUI
import TabletomeDomain

extension BattlePhaseTrackerView {
    var usesPadTabbedTwoColumnLayout: Bool {
        layoutContext.usesPadSplitNavigation && !dynamicTypeSize.needsLayoutAdaptation
    }

    var showsBattleTrackerSectionTabs: Bool {
        usesCompactBattleTrackerChrome || usesPadTabbedTwoColumnLayout
    }

    var padControlColumnMaxWidth: CGFloat {
        layoutContext == .padLandscape
            ? DesignTokens.battleTrackerLandscapeControlColumnMaxWidth
            : DesignTokens.battleTrackerControlColumnMaxWidth
    }

    var padLayoutSpacing: CGFloat {
        layoutContext == .padLandscape
            ? DesignTokens.battleTrackerLandscapeSectionSpacing
            : DesignTokens.Spacing.lg
    }

    var padTabbedTwoColumnLayout: some View {
        VStack(alignment: .leading, spacing: padLayoutSpacing) {
            tabHintSection
            padTwoColumnTabContent
        }
        .animation(.easeInOut(duration: 0.25), value: showsBattleTrackerCoach)
        .animation(.easeInOut(duration: 0.25), value: selectedSectionTab)
        .frame(maxWidth: DesignTokens.battleTrackerRegularMaxWidth)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityIdentifier("battleTracker.padTwoColumnLayout")
    }

    @ViewBuilder
    var padTwoColumnTabContent: some View {
        switch selectedSectionTab {
        case .setup:
            padSetupColumns
        case .turn:
            padTurnColumns
        case .combat:
            padCombatColumns
        case .army:
            padArmyColumns
        }
    }

    var padSetupColumns: some View {
        BattleTrackerPadTwoColumnRow(controlColumnMaxWidth: padControlColumnMaxWidth) {
            deploymentSection
            roundOpenerChecklistSection
        } secondary: {
            if viewModel.playContext.capabilities.showsBattleTacticDecks,
               viewModel.trackerState.battleRound > 1,
               viewModel.roundOpenerIsIncomplete {
                NewMainTurnReminderBanner(round: viewModel.trackerState.battleRound)
            }
            startOfRoundHelper
        }
    }

    var padTurnColumns: some View {
        BattleTrackerPadTwoColumnRow(controlColumnMaxWidth: padControlColumnMaxWidth) {
            phasePlaybookSection
            victoryPointsSection
            turnHandoffSection
            scoringReminderSection
            roundOpenerSection
            if !showsSlimTurnTab {
                quickActionsSection
                BattleTrackerControlPanel(
                    viewModel: viewModel,
                    showsPhaseGuidanceInPicker: !showsPhasePlaybook,
                    showsAdvancePhaseButton: !showsPhasePlaybook
                )
            }
        } secondary: {
            coachSection
            guideSection
            startOfRoundHelper
            if !showsDedicatedCombatTab {
                shootingPhaseHelper
            }
            movementPhaseHelper
        }
    }

    @ViewBuilder
    var padCombatColumns: some View {
        if viewModel.isStarCraft {
            scCombatTabContent
        } else {
            BattleTrackerPadTwoColumnRow(controlColumnMaxWidth: padControlColumnMaxWidth) {
                if showsDedicatedCombatTab {
                    shootingPhaseHelper
                }
                damageUndoSection
                combatPhaseHelper
                shootInCombatPhaseHelper
            } secondary: {
                combatResolverSection(usesLandscapeSplit: true)
            }
        }
    }

    var padArmyColumns: some View {
        BattleTrackerPadTwoColumnRow(controlColumnMaxWidth: padControlColumnMaxWidth) {
            armyTrackerSection(wideLayout: true, compactSidebar: true)
        } secondary: {
            if viewModel.trackerState.showAllAbilities {
                trackerContent
            } else {
                passiveAbilitiesSection
            }
            secondarySections
        }
    }
}

/// iPad battle tracker body: fixed control column + scrolling content column.
struct BattleTrackerPadTwoColumnRow<Primary: View, Secondary: View>: View {
    let controlColumnMaxWidth: CGFloat
    let primary: Primary
    let secondary: Secondary

    init(
        controlColumnMaxWidth: CGFloat,
        @ViewBuilder primary: () -> Primary,
        @ViewBuilder secondary: () -> Secondary
    ) {
        self.controlColumnMaxWidth = controlColumnMaxWidth
        self.primary = primary()
        self.secondary = secondary()
    }

    var body: some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.lg) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                primary
            }
            .frame(minWidth: 0, maxWidth: controlColumnMaxWidth, alignment: .leading)

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                secondary
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .layoutPriority(1)
        }
        .accessibilityElement(children: .contain)
    }
}
