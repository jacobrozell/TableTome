import SwiftUI
import TabletomeDomain
import TabletomeData

extension GuidedMatchView {
    @ViewBuilder
    func compactLayout(catalog: SpearheadCatalog?) -> some View {
        compactLayoutBody(catalog: catalog)
            .navigationDestination(for: GuidedMatchDestination.self) { destination in
                if let catalog {
                    guidedMatchScreen(
                        destination: destination,
                        catalog: catalog,
                        dismissesArmySelectionOnSave: true,
                        household: householdPlayers
                    )
                } else {
                    ProgressView()
                }
            }
            .guidedMatchNestedNavigationDestinations()
        .onChange(of: hidesTabBarInLandscapeBattle) { _, hidden in
            tabBarChrome.isHidden = hidden
        }
        .onChange(of: layoutContext) { oldContext, newContext in
            tabBarChrome.isHidden = hidesTabBarInLandscapeBattle
            if newContext == .phoneLandscape,
               oldContext != .phoneLandscape,
               !showsEmbeddedBattleTracker {
                isHubChromeCollapsed = true
            }
        }
        .onDisappear {
            tabBarChrome.isHidden = false
        }
        .onAppear {
            tabBarChrome.isHidden = hidesTabBarInLandscapeBattle
        }
        .onChange(of: viewModel.matchState.hasBothArmies) { _, _ in
            guard hasAppliedInitialHubTab else { return }
            syncHubTabWithVisibleTabs()
            guard !hasResumableBattleSession else { return }
            guard !AppLaunchArguments.shouldOpenBattleTracker else { return }
            hubTab = suggestedHubTab
        }
        .onChange(of: hubTab) { _, newTab in
            if newTab == .setup, !setupIsComplete {
                isHubChromeCollapsed = true
            }
            if newTab == .battle, setupIsComplete {
                logBattleTrackerOpened(source: "hub_tab")
            }
        }
    }

    @ViewBuilder
    private func compactLayoutBody(catalog: SpearheadCatalog?) -> some View {
        VStack(spacing: 0) {
            if let catalog {
                guidedMatchHubChrome(catalog: catalog)
                    .fixedSize(horizontal: false, vertical: true)
                    .layoutPriority(2)

                if showsEmbeddedBattleTracker {
                    embeddedBattleTracker(catalog: catalog)
                        .layoutPriority(1)
                } else {
                    guidedMatchHubList(catalog: catalog)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .layoutPriority(1)
                }
            } else {
                ProgressView(String(localized: "Loading guided match…"))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .layoutPriority(1)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    func logBattleTrackerOpened(source: String) {
        dependencies.logger.info(
            .guidedMatch,
            eventName: "battle_tracker_opened",
            message: "Battle tracker presented.",
            metadata: [
                "gameSystemId": gameSystemId.rawValue,
                "source": source,
                "embedded": "true",
                "battleRound": String(BattleTrackerStore.load(gameSystemId: gameSystemId).battleRound)
            ]
        )
    }

    @ViewBuilder
    func guidedMatchHubChrome(catalog _: SpearheadCatalog) -> some View {
        if !hidesGuidedMatchHubChromeWhenEmbedded {
            if dynamicTypeSize.needsLayoutAdaptation {
                GuidedMatchHubTabBar(
                    selection: $hubTab,
                    visibleTabs: visibleHubTabs,
                    hasBothArmies: viewModel.matchState.hasBothArmies,
                    setupComplete: setupIsComplete,
                    locksArmiesTab: hasResumableBattleSession
                )
                .padding(.horizontal, DesignTokens.Spacing.md)
                .padding(.vertical, DesignTokens.Spacing.sm)
                .barChromeBackground()
            } else {
                GuidedMatchStageHeader(
                    selection: $hubTab,
                    visibleTabs: visibleHubTabs,
                    hasBothArmies: viewModel.matchState.hasBothArmies,
                    setupComplete: setupIsComplete,
                    locksArmiesTab: hasResumableBattleSession,
                    setupCompleted: viewModel.setupProgress.completed,
                    setupTotal: viewModel.setupProgress.total
                )
            }
        }
    }

    @ViewBuilder
    func guidedMatchHubList(catalog: SpearheadCatalog) -> some View {
        List {
            switch hubTab {
            case .armies:
                if gameSystemId == .aosSpearhead {
                    SpearheadGuidedMatchContent.armiesTab(
                        showsArmyPicker: showsSpearheadArmyPicker,
                        matchup: { matchupSectionView },
                        players: { playersSection(catalog: catalog, useSplitSelection: false) }
                    )
                } else if showsSpearheadArmyPicker {
                    matchupSectionView
                    playersSection(catalog: catalog, useSplitSelection: false)
                } else {
                    Section {
                        Label(
                            String(localized: "Armies are set — open Setup to continue pre-battle steps."),
                            systemImage: "checkmark.circle.fill"
                        )
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    }
                }
            case .setup:
                if gameSystemId == .aosSpearhead {
                    SpearheadGuidedMatchContent.setupTab(
                        sampleTurn: { SampleTurnSection(gameSystemId: gameSystemId) },
                        setupProgress: { setupProgressSectionView },
                        rollPrompt: { rollPromptSectionView },
                        preBattleLoadout: { preBattleLoadoutReviewSectionView },
                        continueSetup: { continueSetupSection(catalog: catalog, useSplitSelection: false) },
                        setupCompleteHandoff: { setupCompleteHandoffSectionView },
                        matchSteps: {
                            if usesCompactSetupLayout {
                                CollapsedMatchSetupSection(
                                    viewModel: viewModel,
                                    gameSystemId: gameSystemId,
                                    useSplitSelection: false,
                                    showsAllSetupSteps: $showsAllSetupSteps
                                )
                            } else {
                                matchSetupSection(useSplitSelection: false)
                            }
                        },
                        usesCompactSetupLayout: usesCompactSetupLayout
                    )
                } else {
                    if !usesCompactSetupLayout {
                        SampleTurnSection(gameSystemId: gameSystemId)
                    }
                    setupProgressSectionView
                    rollPromptSectionView
                    preBattleLoadoutReviewSectionView
                    continueSetupSection(catalog: catalog, useSplitSelection: false)
                    setupCompleteHandoffSectionView
                    if usesCompactSetupLayout {
                        CollapsedMatchSetupSection(
                            viewModel: viewModel,
                            gameSystemId: gameSystemId,
                            useSplitSelection: false,
                            showsAllSetupSteps: $showsAllSetupSteps
                        )
                    } else {
                        matchSetupSection(useSplitSelection: false)
                    }
                }
            case .battle:
                SpearheadGuidedMatchContent.battleTab(
                    setupComplete: setupIsComplete,
                    whenReady: {
                        battleTrackerSection(useSplitSelection: false)
                        if usesCompactSetupLayout {
                            SampleTurnSection(gameSystemId: gameSystemId)
                        }
                    },
                    whenIncomplete: {
                        setupIncompleteBattleSection(catalog: catalog)
                    }
                )
            }
        }
        .ttGroupedList()
        .tabBarScrollInset(
            additionalBottom: hubTab == .setup ? DesignTokens.guidedMatchSetupScrollExtraInset : 0
        )
    }

    @ViewBuilder
    func setupIncompleteBattleSection(catalog _: SpearheadCatalog) -> some View {
        Section {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                Label(String(localized: "Finish setup first"), systemImage: "checklist")
                    .font(.headline)
                Text(
                    String(
                        localized: """
                        Complete the remaining setup steps before the battle tracker unlocks. \
                        The Battle tab opens automatically when you're ready.
                        """
                    )
                )
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

                if let next = viewModel.nextIncompleteStep,
                   let index = viewModel.sortedMatchSteps.firstIndex(where: { $0.id == next.id }) {
                    Button {
                        hubTab = .setup
                    } label: {
                        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                            Text(String(localized: "Continue on Setup"))
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.accentOnSurface)
                            GuideStepCard(
                                stepNumber: index + 1,
                                title: next.title,
                                summary: next.summary,
                                isComplete: false,
                                showsDisclosureIndicator: false,
                                accessibilityId: "guidedMatch.battleGate.\(next.id)"
                            )
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("guidedMatch.battleGate.continue")
                }
            }
            .padding(.vertical, DesignTokens.Spacing.xs)
        } footer: {
            if viewModel.setupProgress.total > 0 {
                Text(
                    String(
                        localized: "Setup \(viewModel.setupProgress.completed) of \(viewModel.setupProgress.total) complete."
                    )
                )
            }
        }
    }
}
