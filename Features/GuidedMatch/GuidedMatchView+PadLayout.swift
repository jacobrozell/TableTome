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
                    guidedMatchSections(catalog: catalog, useSplitSelection: true)
                }
                .listStyle(.sidebar)
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
            guidedMatchDetail(catalog: catalog)
                .modifier(GuidedMatchDetailWidth(destination: selectedDestination))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .onAppear {
            applySpearheadPadInitialDestinationIfNeeded()
        }
        .onChange(of: viewModel.matchState.hasBothArmies) { _, hasBoth in
            guard hasBoth, usesPadSplitNavigation, selectedDestination == nil else { return }
            guard !AppLaunchArguments.shouldSnapshotGuidedMatchArmies else { return }
            selectedDestination = spearheadPadDetailDestination
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .toolbar(.hidden, for: .navigationBar)
    }

    func applySpearheadPadInitialDestinationIfNeeded() {
        guard gameSystemId == .aosSpearhead,
              viewModel.matchState.hasBothArmies,
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

        battleTrackerSection(catalog: catalog, useSplitSelection: true)
        resetSection
    }

    @ViewBuilder
    func guidedMatchDetail(catalog: SpearheadCatalog) -> some View {
        if let selectedDestination {
            guidedMatchScreen(
                destination: selectedDestination,
                catalog: catalog,
                dismissesArmySelectionOnSave: false
            )
        } else {
            guidedMatchPadWelcome(catalog: catalog)
        }
    }

    @ViewBuilder
    func guidedMatchPadWelcome(catalog: SpearheadCatalog) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                guidedMatchPlaceholder(
                    title: String(localized: "Start here"),
                    message: padWelcomeMessage
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
            Button(String(localized: "Use Starter Matchup")) {
                useStarterMatchup(navigateToSetup: false)
                selectedDestination = spearheadPadDetailDestination ?? .battleTracker
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget)
            .accessibilityIdentifier("guidedMatch.starterMatchup.detail")

            DisclosureGroup(String(localized: "We brought our own lists")) {
                VStack(spacing: DesignTokens.Spacing.sm) {
                    Button {
                        selectedDestination = .playerOne
                    } label: {
                        PlayerArmyRow(
                            label: String(localized: "Player 1"),
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
