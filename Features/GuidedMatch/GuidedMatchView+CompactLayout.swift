import SwiftUI
import TabletomeDomain
import TabletomeData

extension GuidedMatchView {
    @ViewBuilder
    func compactLayout(catalog: SpearheadCatalog) -> some View {
        VStack(spacing: 0) {
            guidedMatchHubChrome(catalog: catalog)

            if showsEmbeddedBattleTracker {
                embeddedBattleTracker(catalog: catalog)
            } else {
                guidedMatchHubList(catalog: catalog)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .layoutPriority(1)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onChange(of: hidesTabBarInLandscapeBattle) { _, hidden in
            tabBarChrome.isHidden = hidden
        }
        .onChange(of: layoutContext) { _, _ in
            tabBarChrome.isHidden = hidesTabBarInLandscapeBattle
        }
        .onDisappear {
            tabBarChrome.isHidden = false
        }
        .navigationDestination(for: GuidedMatchDestination.self) { destination in
            guidedMatchScreen(
                destination: destination,
                catalog: catalog,
                dismissesArmySelectionOnSave: true
            )
        }
        .onAppear {
            applyInitialHubTabIfNeeded()
            tabBarChrome.isHidden = hidesTabBarInLandscapeBattle
            if hasResumableBattleSession, hubTab == .armies {
                hubTab = .battle
                logBattleTrackerOpened(source: "resume")
            }
        }
        .onChange(of: viewModel.matchState.hasBothArmies) { _, _ in
            guard hasAppliedInitialHubTab, !hasResumableBattleSession else { return }
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
        .onChange(of: viewModel.matchState.completedStepIds) { _, _ in
            guard !AppLaunchArguments.shouldSnapshotGuidedMatchArmies else { return }
            if setupIsComplete, hubTab == .setup {
                hubTab = .battle
                logBattleTrackerOpened(source: "setup_complete")
            }
        }
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

    func applyInitialHubTabIfNeeded() {
        guard !hasAppliedInitialHubTab else { return }
        hasAppliedInitialHubTab = true
        hubTab = initialHubTab ?? suggestedHubTab
    }

    @ViewBuilder
    func guidedMatchHubChrome(catalog: SpearheadCatalog) -> some View {
        if !hidesGuidedMatchHubChromeWhenEmbedded {
            if isHubChromeCollapsed {
                GuidedMatchCollapsedHubChrome(summary: hubChromeSummaryLine(catalog: catalog)) {
                    withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) {
                        isHubChromeCollapsed = false
                    }
                }
            } else {
                VStack(spacing: DesignTokens.Spacing.sm) {
                    HStack(alignment: .center, spacing: DesignTokens.Spacing.xs) {
                        GuidedMatchStatusBar(
                            playerOneSummary: playerSummary(
                                selection: viewModel.matchState.playerOne,
                                catalog: catalog,
                                fallback: String(localized: "Player 1")
                            ),
                            playerTwoSummary: playerSummary(
                                selection: viewModel.matchState.playerTwo,
                                catalog: catalog,
                                fallback: String(localized: "Player 2")
                            ),
                            hasBothArmies: viewModel.matchState.hasBothArmies,
                            setupCompleted: viewModel.setupProgress.completed,
                            setupTotal: viewModel.setupProgress.total,
                            nextStepTitle: viewModel.nextIncompleteStep?.title,
                            setupComplete: setupIsComplete,
                            activeHubTab: hubTab,
                            battleTrackerSummary: battleTrackerSummaryLine(),
                            compactMode: usesCompactHubStatusBar
                        )
                        .id(hubTrackerTick)

                        ChromeCollapseInlineButton(
                            accessibilityLabel: String(localized: "Hide match summary"),
                            accessibilityIdentifier: "guidedMatch.hubChromeCollapseInline",
                            onCollapse: {
                                withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) {
                                    isHubChromeCollapsed = true
                                }
                            }
                        )
                    }

                    if !showsEmbeddedBattleTracker {
                        GuidedMatchHubTabBar(
                            selection: $hubTab,
                            visibleTabs: visibleHubTabs,
                            hasBothArmies: viewModel.matchState.hasBothArmies,
                            setupComplete: setupIsComplete,
                            locksArmiesTab: hasResumableBattleSession
                        )
                    }
                }
                .barChromeBackground()
                .overlay(alignment: .bottom) {
                    if showsEmbeddedBattleTracker {
                        Divider()
                    }
                }
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
                        matchup: { matchupSection },
                        players: { playersSection(catalog: catalog, useSplitSelection: false) }
                    )
                } else if showsSpearheadArmyPicker {
                    matchupSection
                    playersSection(catalog: catalog, useSplitSelection: false)
                }
            case .setup:
                if gameSystemId == .aosSpearhead {
                    SpearheadGuidedMatchContent.setupTab(
                        sampleTurn: { sampleTurnSection },
                        setupProgress: { setupProgressSection },
                        rollPrompt: { rollPromptSection },
                        preBattleLoadout: { preBattleLoadoutReviewSection },
                        continueSetup: { continueSetupSection(catalog: catalog, useSplitSelection: false) },
                        setupCompleteHandoff: { setupCompleteHandoffSection },
                        matchSteps: {
                            if usesCompactSetupLayout {
                                collapsedMatchSetupSection(catalog: catalog, useSplitSelection: false)
                            } else {
                                matchSetupSection(catalog: catalog, useSplitSelection: false)
                            }
                        },
                        usesCompactSetupLayout: usesCompactSetupLayout
                    )
                } else {
                    if !usesCompactSetupLayout {
                        sampleTurnSection
                    }
                    setupProgressSection
                    rollPromptSection
                    preBattleLoadoutReviewSection
                    continueSetupSection(catalog: catalog, useSplitSelection: false)
                    setupCompleteHandoffSection
                    if usesCompactSetupLayout {
                        collapsedMatchSetupSection(catalog: catalog, useSplitSelection: false)
                    } else {
                        matchSetupSection(catalog: catalog, useSplitSelection: false)
                    }
                }
            case .battle:
                SpearheadGuidedMatchContent.battleTab(
                    setupComplete: setupIsComplete,
                    whenReady: {
                        battleTrackerSection(catalog: catalog, useSplitSelection: false)
                        if usesCompactSetupLayout {
                            sampleTurnSection
                        }
                    },
                    whenIncomplete: {
                        setupIncompleteBattleSection(catalog: catalog)
                    }
                )
            }
            resetSection
        }
        .listStyle(.insetGrouped)
        .tabBarScrollInset(
            additionalBottom: hubTab == .setup ? DesignTokens.guidedMatchSetupScrollExtraInset : 0
        )
        .readableContentWidth()
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
