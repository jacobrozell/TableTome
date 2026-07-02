import SwiftUI
import TabletomeDomain
import TabletomeData

extension GuidedMatchView {
    // MARK: - Shared list content

    @ViewBuilder
    func guidedMatchSections(catalog: SpearheadCatalog, useSplitSelection: Bool) -> some View {
        if useSplitSelection, selectedDestination == .battleTracker, setupIsComplete {
            padBattleActiveSidebar(catalog: catalog)
        } else if usesCompactSetupLayout {
            compactGuidedMatchSections(catalog: catalog, useSplitSelection: useSplitSelection)
        } else {
            expandedGuidedMatchSections(catalog: catalog, useSplitSelection: useSplitSelection)
        }
    }

    @ViewBuilder
    func compactGuidedMatchSections(catalog: SpearheadCatalog, useSplitSelection: Bool) -> some View {
        if gameSystemId == .aosSpearhead {
            SpearheadGuidedMatchContent.sidebarFlow(
                showsArmyPicker: showsSpearheadArmyPicker,
                usesCompactSetupLayout: true,
                matchup: { matchupSectionView },
                players: { playersSection(catalog: catalog, useSplitSelection: useSplitSelection) },
                starterHandoff: { starterMatchupHandoffSectionView },
                setupProgress: { setupProgressSectionView },
                rollPrompt: { rollPromptSectionView },
                preBattleLoadout: { preBattleLoadoutReviewSectionView },
                continueSetup: { continueSetupSection(catalog: catalog, useSplitSelection: useSplitSelection) },
                setupCompleteHandoff: { setupCompleteHandoffSectionView },
                battleTracker: { battleTrackerSection(useSplitSelection: useSplitSelection) },
                sampleTurn: { SampleTurnSection(gameSystemId: gameSystemId) },
                matchSteps: {
                    CollapsedMatchSetupSection(
                        viewModel: viewModel,
                        gameSystemId: gameSystemId,
                        useSplitSelection: useSplitSelection,
                        showsAllSetupSteps: $showsAllSetupSteps
                    )
                }
            )
        } else {
            if showsSpearheadArmyPicker {
                matchupSectionView
                playersSection(catalog: catalog, useSplitSelection: useSplitSelection)
            }
            starterMatchupHandoffSectionView
            setupProgressSectionView
            rollPromptSectionView
            preBattleLoadoutReviewSectionView
            continueSetupSection(catalog: catalog, useSplitSelection: useSplitSelection)
            setupCompleteHandoffSectionView
            battleTrackerSection(useSplitSelection: useSplitSelection)
            SampleTurnSection(gameSystemId: gameSystemId)
            CollapsedMatchSetupSection(
                viewModel: viewModel,
                gameSystemId: gameSystemId,
                useSplitSelection: useSplitSelection,
                showsAllSetupSteps: $showsAllSetupSteps
            )
        }
        resetSectionView
    }

    @ViewBuilder
    func expandedGuidedMatchSections(catalog: SpearheadCatalog, useSplitSelection: Bool) -> some View {
        if gameSystemId == .aosSpearhead {
            SpearheadGuidedMatchContent.sidebarFlow(
                showsArmyPicker: showsSpearheadArmyPicker,
                usesCompactSetupLayout: false,
                matchup: { matchupSectionView },
                players: { playersSection(catalog: catalog, useSplitSelection: useSplitSelection) },
                starterHandoff: { starterMatchupHandoffSectionView },
                setupProgress: { setupProgressSectionView },
                rollPrompt: { rollPromptSectionView },
                preBattleLoadout: { preBattleLoadoutReviewSectionView },
                continueSetup: { continueSetupSection(catalog: catalog, useSplitSelection: useSplitSelection) },
                setupCompleteHandoff: { setupCompleteHandoffSectionView },
                battleTracker: { battleTrackerSection(useSplitSelection: useSplitSelection) },
                sampleTurn: { EmptyView() },
                matchSteps: { matchSetupSection(useSplitSelection: useSplitSelection) }
            )
        } else {
            if showsSpearheadArmyPicker {
                matchupSectionView
                playersSection(catalog: catalog, useSplitSelection: useSplitSelection)
            }
            starterMatchupHandoffSectionView
            setupProgressSectionView
            rollPromptSectionView
            preBattleLoadoutReviewSectionView
            continueSetupSection(catalog: catalog, useSplitSelection: useSplitSelection)
            setupCompleteHandoffSectionView
            battleTrackerSection(useSplitSelection: useSplitSelection)
            matchSetupSection(useSplitSelection: useSplitSelection)
        }
        resetSectionView
    }

    var spearheadBoxSets: [BoxSet] {
        BoxSetCatalogLoader.load(for: .aosSpearhead)?.boxSets ?? []
    }

    /// On phone Setup tab, hub status + Up Next are enough — hide the duplicate checklist.
    private var showsSetupProgressChecklist: Bool {
        usesPadSplitNavigation || hubTab != .setup
    }

    var matchupSectionView: some View {
        MatchupSection(
            gameSystemId: gameSystemId,
            showsSpearheadArmyPicker: showsSpearheadArmyPicker,
            boxSets: spearheadBoxSets,
            selectedBoxId: $selectedSpearheadBoxId,
            onUseStarterMatchup: { useStarterMatchup() },
            featuredArmies: featuredArmies,
            matchupSummary: viewModel.matchupSummary
        )
    }

    var setupProgressSectionView: some View {
        SetupProgressSection(
            viewModel: viewModel,
            showsSetupProgressChecklist: showsSetupProgressChecklist
        )
    }

    var rollPromptSectionView: some View {
        RollPromptSection(
            viewModel: viewModel,
            gameSystemId: gameSystemId,
            inlineRollPickerTitle: inlineRollPickerTitle,
            playerOneRollLabel: playerOneRollLabel,
            playerTwoRollLabel: playerTwoRollLabel,
            inlineRollDecidedCaption: inlineRollDecidedCaption(isPlayerOne:)
        )
    }

    @ViewBuilder
    var preBattleLoadoutReviewSectionView: some View {
        if needsPreBattleLoadoutReview {
            PreBattleLoadoutReviewSection(
                viewModel: viewModel,
                ruleSections: ruleSections,
                usesPadSplitNavigation: usesPadSplitNavigation,
                showsLoadoutSheet: $showsLoadoutSheet,
                onOpenRegimentStep: { openSpearheadSetupStep("regiment-abilities") },
                onOpenEnhancementStep: { openSpearheadSetupStep("enhancements") }
            )
        }
    }

    func continueSetupSection(catalog: SpearheadCatalog, useSplitSelection: Bool) -> some View {
        ContinueSetupSection(
            viewModel: viewModel,
            gameSystemId: gameSystemId,
            ruleSections: ruleSections,
            useSplitSelection: useSplitSelection,
            inlineRollPickerTitle: inlineRollPickerTitle,
            playerOneRollLabel: playerOneRollLabel,
            playerTwoRollLabel: playerTwoRollLabel,
            inlineRollDecidedCaption: inlineRollDecidedCaption(isPlayerOne:),
            selectedDestination: $selectedDestination
        )
    }

    var setupCompleteHandoffSectionView: some View {
        SetupCompleteHandoffSection(
            setupIsComplete: setupIsComplete,
            dismissedSetupCompleteHandoff: $dismissedSetupCompleteHandoff,
            hubTab: $hubTab
        )
    }

    var starterMatchupHandoffSectionView: some View {
        StarterMatchupHandoffSection(
            showsStarterMatchupHandoff: showsStarterMatchupHandoff,
            dismissedStarterMatchupHandoff: $dismissedStarterMatchupHandoff,
            matchupSummary: viewModel.matchupSummary,
            nextStepTitle: viewModel.nextIncompleteStep?.title,
            attackerLabel: spearheadAttackerLabel,
            usesSpearheadCopy: gameSystemId == .aosSpearhead,
            onDismiss: {
                dismissedStarterMatchupHandoff = true
                showsStarterMatchupHandoff = false
            }
        )
    }

    func playersSection(catalog: SpearheadCatalog, useSplitSelection: Bool) -> some View {
        PlayersSection(
            viewModel: viewModel,
            catalog: catalog,
            useSplitSelection: useSplitSelection,
            showsOwnListsSection: $showsOwnListsSection
        )
    }

    func battleTrackerSection(useSplitSelection: Bool) -> some View {
        BattleTrackerSection(viewModel: viewModel, useSplitSelection: useSplitSelection)
    }

    func matchSetupSection(useSplitSelection: Bool) -> some View {
        MatchSetupSection(viewModel: viewModel, useSplitSelection: useSplitSelection)
    }

    var resetSectionView: some View {
        ResetSection(
            viewModel: viewModel,
            showsResetConfirmation: $showsResetConfirmation,
            selectedDestination: $selectedDestination,
            hubTab: $hubTab
        )
    }

    func guidedMatchPlaceholder(title: String, message: String) -> some View {
        ContentUnavailableView {
            Label(title, systemImage: "flag.checkered")
        } description: {
            Text(message)
        }
    }
}
