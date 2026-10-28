import SwiftUI
import TabletomeDomain
import TabletomeData

extension GuidedMatchView {
    // MARK: - iPad

    @ViewBuilder
    func regularLayout(catalog: SpearheadCatalog) -> some View {
        NavigationSplitView(columnVisibility: $splitColumnVisibility) {
            NavigationStack {
                List(selection: $selectedDestination) {
                    padSidebar(catalog: catalog)
                }
                .listStyle(.sidebar)
                .scrollContentBackground(.hidden)
                .background(TTColor.surface)
                .navigationTitle(guidedMatchNavigationTitle)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { padSidebarToolbar }
            }
            .navigationSplitViewColumnWidth(
                min: isPadLandscape ? 220 : 240,
                ideal: isPadLandscape ? 280 : 320,
                max: isPadLandscape ? 320 : 360
            )
        } detail: {
            NavigationStack(path: $padDetailNavigationPath) {
                guidedMatchDetail(catalog: catalog)
                    .modifier(GuidedMatchDetailWidth(destination: selectedDestination))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .guidedMatchNestedNavigationDestinations()
            }
        }
        .onChange(of: selectedDestination) { _, _ in
            padDetailNavigationPath = NavigationPath()
        }
        .onAppear {
            applySpearheadPadInitialDestinationIfNeeded()
        }
        .onChange(of: viewModel.matchState.hasBothArmies) { _, hasBoth in
            guard hasBoth, usesPadSplitNavigation, selectedDestination == nil else { return }
            guard !AppLaunchArguments.shouldSnapshotGuidedMatchArmies else { return }
            applySpearheadPadInitialDestinationIfNeeded()
        }
        .onChange(of: viewModel.catalog != nil) { _, catalogLoaded in
            guard catalogLoaded else { return }
            applySpearheadPadInitialDestinationIfNeeded()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .toolbar(.hidden, for: .navigationBar)
    }

    func applySpearheadPadInitialDestinationIfNeeded() {
        guard gameSystemId == .aosSpearhead,
              viewModel.matchState.hasBothArmies,
              viewModel.catalog != nil,
              selectedDestination == nil,
              !AppLaunchArguments.shouldSnapshotGuidedMatchArmies else { return }
        selectedDestination = spearheadPadDetailDestination
    }

    /// iPad sidebar while battle tracker fills the detail pane — drop finished setup chrome.
    @ViewBuilder
    func padBattleActiveSidebar(catalog: SpearheadCatalog) -> some View {
        Section {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Text(
                    playerSummary(
                        selection: viewModel.matchState.playerOne,
                        catalog: catalog,
                        fallback: String(localized: "Player 1")
                    )
                )
                .font(.caption.weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)
                Text(
                    playerSummary(
                        selection: viewModel.matchState.playerTwo,
                        catalog: catalog,
                        fallback: String(localized: "Player 2")
                    )
                )
                .font(.caption.weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)
                if let battleSummary = battleTrackerSummaryLine() {
                    Text(battleSummary)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.vertical, DesignTokens.Spacing.xs)
        } header: {
            Text(String(localized: "At the table"))
        }

        battleTrackerSection(useSplitSelection: true)
        resetSectionView
    }

    @ViewBuilder
    func padSidebar(catalog: SpearheadCatalog) -> some View {
        Section(String(localized: "Match")) {
            padPlayerRow(
                isPlayerOne: true,
                selection: viewModel.matchState.playerOne,
                catalog: catalog,
                destination: .playerOne
            )
            padPlayerRow(
                isPlayerOne: false,
                selection: viewModel.matchState.playerTwo,
                catalog: catalog,
                destination: .playerTwo
            )
        }
        Section(String(localized: "Setup")) {
            ForEach(viewModel.sortedMatchSteps) { step in
                let done = viewModel.matchState.completedStepIds.contains(step.id)
                Label {
                    Text(step.title)
                        .font(TTFont.callout)
                        .foregroundStyle(done ? TTColor.inkSecondary : TTColor.inkPrimary)
                } icon: {
                    Image(systemName: done ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(done ? TTColor.success : TTColor.stroke)
                }
                .tag(GuidedMatchDestination.step(step.id))
                .accessibilityIdentifier("guidedMatch.setupStep.\(step.id)")
            }
        }
        Section(String(localized: "Battle")) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
                Text(String(localized: "Battle"))
                    .font(TTFont.headline)
                if let summary = battleTrackerSummaryLine() {
                    Text(summary)
                        .font(TTFont.caption)
                        .foregroundStyle(TTColor.inkSecondary)
                }
            }
            .tag(GuidedMatchDestination.battleTracker)
            .accessibilityIdentifier("guidedMatch.battleTracker")
        }
    }

    private func padPlayerRow(
        isPlayerOne: Bool,
        selection: PlayerArmySelection,
        catalog: SpearheadCatalog,
        destination: GuidedMatchDestination
    ) -> some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            TTPlayerToken(isPlayerOne: isPlayerOne, size: 28)
            Text(
                playerSummary(
                    selection: selection,
                    catalog: catalog,
                    fallback: isPlayerOne ? String(localized: "Player 1") : String(localized: "Player 2")
                )
            )
            .font(TTFont.callout)
            .foregroundStyle(TTColor.inkPrimary)
            .lineLimit(2)
        }
        .tag(destination)
        .accessibilityIdentifier(isPlayerOne ? "guidedMatch.playerOne" : "guidedMatch.playerTwo")
    }

    @ViewBuilder
    func guidedMatchDetail(catalog: SpearheadCatalog) -> some View {
        if let selectedDestination {
            guidedMatchScreen(
                destination: selectedDestination,
                catalog: catalog,
                dismissesArmySelectionOnSave: false,
                household: householdPlayers
            )
        } else {
            guidedMatchPadWelcome(catalog: catalog)
        }
    }

    @ViewBuilder
    func guidedMatchPadWelcome(catalog: SpearheadCatalog) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                TTEmptyState(
                    title: String(localized: "Start here"),
                    message: padWelcomeMessage,
                    systemImage: "flag.checkered",
                    primary: viewModel.matchState.hasBothArmies
                        ? nil
                        : (String(localized: "Use Starter Matchup"), {
                            useStarterMatchup(navigateToSetup: false)
                            selectedDestination = spearheadPadDetailDestination ?? .battleTracker
                        }),
                    primaryAccessibilityIdentifier: "guidedMatch.starterMatchup.detail"
                )

                if !viewModel.matchState.hasBothArmies {
                    starterMatchupPadActions(catalog: catalog)
                } else if !setupIsComplete {
                    setupProgressPadCard(catalog: catalog)
                } else {
                    openBattlePadCard
                }
            }
            .padding(DesignTokens.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private func starterMatchupPadActions(catalog: SpearheadCatalog) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            DisclosureGroup(String(localized: "We brought our own lists")) {
                VStack(spacing: DesignTokens.Spacing.sm) {
                    Button {
                        selectedDestination = .playerOne
                    } label: {
                        PlayerArmyRow(
                            label: String(localized: "Player 1"),
                            isPlayerOne: true,
                            selection: viewModel.matchState.playerOne,
                            catalog: catalog
                        )
                    }
                    .buttonStyle(.bordered)
                    .accessibilityIdentifier("guidedMatch.playerOne.detail")

                    Button {
                        selectedDestination = .playerTwo
                    } label: {
                        PlayerArmyRow(
                            label: String(localized: "Player 2"),
                            isPlayerOne: false,
                            selection: viewModel.matchState.playerTwo,
                            catalog: catalog
                        )
                    }
                    .buttonStyle(.bordered)
                    .accessibilityIdentifier("guidedMatch.playerTwo.detail")
                }
                .padding(.top, DesignTokens.Spacing.sm)
            }
            .font(.subheadline.weight(.semibold))
        }
    }

    @ViewBuilder
    private func setupProgressPadCard(catalog: SpearheadCatalog) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Label(String(localized: "Finish setup"), systemImage: "checklist")
                .font(.headline)

            if viewModel.setupProgress.total > 0 {
                ProgressView(
                    value: Double(viewModel.setupProgress.completed),
                    total: Double(viewModel.setupProgress.total)
                )
                Text(
                    String(
                        localized: "\(viewModel.setupProgress.completed) of \(viewModel.setupProgress.total) steps complete"
                    )
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }

            GuidedMatchSetupProgressList(
                steps: viewModel.sortedMatchSteps,
                completedStepIds: viewModel.matchState.completedStepIds
            )

            if let nextStep = viewModel.nextIncompleteStep {
                Button(String(localized: "Continue: \(nextStep.title)")) {
                    selectedDestination = .step(nextStep.id)
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget)
            }
        }
        .padding(DesignTokens.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .surfaceCard()
    }

    private var openBattlePadCard: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Label(String(localized: "Ready to play"), systemImage: "flag.checkered")
                .font(.headline)

            Text(
                String(
                    localized: """
                    Setup is done. Open Battle Phase Tracker for turn phases, combat resolver, and army health.
                    """
                )
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)

            Button(String(localized: "Open Battle Phase Tracker")) {
                selectedDestination = .battleTracker
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget)
            .accessibilityIdentifier("guidedMatch.padOpenBattle")
        }
        .padding(DesignTokens.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .surfaceCard()
    }

    var padWelcomeMessage: String {
        switch gameSystemId {
        case .wh40k10eCp:
            return String(
                localized: """
                Tap Use Starter Matchup for Space Marines vs Tyranids, or pick the Combat Patrol boxes you own below.
                """
            )
        case .wh40k11e:
            return String(
                localized: """
                Tap Use Starter Matchup for the Armageddon starter armies, or pick each player's force below.
                """
            )
        case .scTmg:
            return String(
                localized: """
                Tap Use Starter Matchup for Raynor vs Kerrigan, or pick each player's faction below.
                """
            )
        default:
            if gameSystemId == .aosSpearhead, viewModel.matchState.hasBothArmies {
                return String(
                    localized: """
                    Starter matchup loads both armies. Pick your next setup step in the sidebar — \
                    realm board and deployment are step 5.
                    """
                )
            }
            return String(
                localized: """
                New to tabletop battles? Tap Use Starter Matchup to load both armies, or pick each player below.
                """
            )
        }
    }
}
