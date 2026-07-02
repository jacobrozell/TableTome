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

    var padSidebarColumnMaxWidth: CGFloat {
        if isEmbeddedInGuidedMatch {
            return layoutContext == .padLandscape ? 320 : 300
        }
        return layoutContext == .padLandscape ? 340 : 380
    }

    /// Embedded GM detail pane is narrow — keep army/combat tools in a sidebar, resolver primary.
    var padEmbeddedCombatSidebarMaxWidth: CGFloat {
        layoutContext == .padLandscape ? 320 : 300
    }

    var padLayoutSpacing: CGFloat {
        layoutContext == .padLandscape
            ? DesignTokens.battleTrackerLandscapeSectionSpacing
            : DesignTokens.Spacing.lg
    }

    var padTabbedTwoColumnLayout: some View {
        let content = VStack(alignment: .leading, spacing: padLayoutSpacing) {
            tabHintSection
            padTwoColumnTabContent
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: showsBattleTrackerCoach)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: selectedSectionTab)
        .accessibilityIdentifier("battleTracker.padTwoColumnLayout")

        return Group {
            if let maxWidth = padContentMaxWidth {
                content
                    .frame(maxWidth: maxWidth, alignment: padContentAlignment)
                    .frame(maxWidth: .infinity, alignment: padContentAlignment)
            } else {
                content
                    .frame(maxWidth: .infinity, alignment: padContentAlignment)
            }
        }
    }

    /// Embedded iPad battle fills the split detail pane; standalone play centers up to a comfortable max.
    private var padContentMaxWidth: CGFloat? {
        isEmbeddedInGuidedMatch ? nil : DesignTokens.battleTrackerRegularMaxWidth
    }

    private var padContentAlignment: Alignment {
        isEmbeddedInGuidedMatch ? .leading : .center
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
        VStack(alignment: .leading, spacing: padLayoutSpacing) {
            if viewModel.playContext.capabilities.showsBattleTacticDecks,
               viewModel.trackerState.battleRound > 1,
               viewModel.roundOpenerIsIncomplete {
                NewMainTurnReminderBanner(round: viewModel.trackerState.battleRound)
            }
            deploymentSection
            roundOpenerChecklistSection
            startOfRoundHelper
        }
    }

    @ViewBuilder
    var padTurnColumns: some View {
        if showsSlimTurnTab {
            padTurnPlaybookLayout
        } else {
            BattleTrackerPadTwoColumnRow(
                controlColumnMaxWidth: padControlColumnMaxWidth,
                balance: .controlSidebar
            ) {
                quickActionsSection
                BattleTrackerControlPanel(
                    viewModel: viewModel,
                    showsPhaseGuidanceInPicker: !showsPhasePlaybook,
                    showsAdvancePhaseButton: !showsPhasePlaybook
                )
            } secondary: {
                if showsScoringContext {
                    victoryPointsSection
                }
                coachSection
                guideSection
                battleTacticCommandGuideSection
                phasePlaybookSection
                if !showsScoringContext {
                    victoryPointsSection
                }
                phaseActionNudgeSection
                reinforcementCallBannerSection
                turnHandoffSection
                scoringReminderSection
                heroRoundOneSection
                roundOpenerSection
                startOfRoundHelper
                if !showsDedicatedCombatTab {
                    shootingPhaseHelper
                }
                movementPhaseHelper
            }
        }
    }

    /// Phase playbook and combat helpers need horizontal space — avoid squeezing into the control column.
    private var padTurnPlaybookLayout: some View {
        VStack(alignment: .leading, spacing: padLayoutSpacing) {
            if viewModel.playContext.capabilities.showsBattleTacticDecks,
               viewModel.trackerState.battleRound > 1,
               viewModel.roundOpenerIsIncomplete {
                NewMainTurnReminderBanner(round: viewModel.trackerState.battleRound)
            }

            BattleTrackerRoundBar(viewModel: viewModel)
            if showsScoringContext {
                victoryPointsSection
            }
            phasePlaybookSection
            battleTacticCommandGuideSection
            if !showsScoringContext {
                victoryPointsSection
            }
            phaseActionNudgeSection
            reinforcementCallBannerSection
            turnHandoffSection
            scoringReminderSection
            heroRoundOneSection
            roundOpenerSection

            BattleTrackerPadTwoColumnRow(
                controlColumnMaxWidth: padSidebarColumnMaxWidth,
                balance: .contentPrimary
            ) {
                coachSection
                guideSection
                startOfRoundHelper
                if !showsDedicatedCombatTab {
                    shootingPhaseHelper
                }
                movementPhaseHelper
            } secondary: {
                quickActionsSection
            }
        }
    }

    @ViewBuilder
    var padCombatColumns: some View {
        if viewModel.playContext.capabilities.showsActivationBar {
            scCombatTabContent
        } else if isEmbeddedInGuidedMatch {
            embeddedPadCombatLayout
        } else {
            BattleTrackerPadTwoColumnRow(
                controlColumnMaxWidth: padSidebarColumnMaxWidth,
                balance: .contentPrimary
            ) {
                combatResolverSection(usesLandscapeSplit: true)
                damageUndoSection
            } secondary: {
                if showsDedicatedCombatTab {
                    shootingPhaseHelper
                }
                combatActivationSection
                combatPhaseHelper
                shootInCombatPhaseHelper
                armyTrackerSection(wideLayout: true, compactSidebar: true)
            }
        }
    }

    /// Resolver fills the detail pane; attack checklist and army health stay in a trailing sidebar.
    private var embeddedPadCombatLayout: some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.md) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                combatResolverSection(usesLandscapeSplit: true)
                damageUndoSection
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .layoutPriority(1)

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                if showsDedicatedCombatTab {
                    shootingPhaseHelper
                }
                combatActivationSection
                combatPhaseHelper
                shootInCombatPhaseHelper
                armyTrackerSection(wideLayout: true, compactSidebar: true)
            }
            .frame(minWidth: 0, maxWidth: padEmbeddedCombatSidebarMaxWidth, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityIdentifier("battleTracker.embeddedPadCombatLayout")
    }

    var padArmyColumns: some View {
        BattleTrackerPadTwoColumnRow(
            controlColumnMaxWidth: padControlColumnMaxWidth,
            balance: .contentPrimary
        ) {
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

enum BattleTrackerPadColumnBalance {
    /// Narrow control column on the left (setup, legacy turn layout).
    case controlSidebar
    /// Primary content column expands; secondary is a narrow sidebar on the right.
    case contentPrimary
}

/// iPad battle tracker body: two-column row with configurable column balance.
struct BattleTrackerPadTwoColumnRow<Primary: View, Secondary: View>: View {
    let controlColumnMaxWidth: CGFloat
    let balance: BattleTrackerPadColumnBalance
    let primary: Primary
    let secondary: Secondary

    init(
        controlColumnMaxWidth: CGFloat,
        balance: BattleTrackerPadColumnBalance = .controlSidebar,
        @ViewBuilder primary: () -> Primary,
        @ViewBuilder secondary: () -> Secondary
    ) {
        self.controlColumnMaxWidth = controlColumnMaxWidth
        self.balance = balance
        self.primary = primary()
        self.secondary = secondary()
    }

    var body: some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.lg) {
            primaryColumn
            secondaryColumn
        }
        .accessibilityElement(children: .contain)
    }

    @ViewBuilder
    private var primaryColumn: some View {
        let column = VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            primary
        }
        switch balance {
        case .controlSidebar:
            column
                .frame(minWidth: 0, maxWidth: controlColumnMaxWidth, alignment: .leading)
        case .contentPrimary:
            column
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .layoutPriority(1)
        }
    }

    @ViewBuilder
    private var secondaryColumn: some View {
        let column = VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            secondary
        }
        switch balance {
        case .controlSidebar:
            column
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .layoutPriority(1)
        case .contentPrimary:
            column
                .frame(minWidth: 0, maxWidth: controlColumnMaxWidth, alignment: .leading)
        }
    }
}
