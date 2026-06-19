import SwiftUI
import TabletomeDomain
import TabletomeData

// swiftlint:disable type_body_length
struct GuidedMatchView: View {
    @StateObject var viewModel: GuidedMatchViewModel
    @StateObject var matchSyncService = NearbyMatchSyncService()
    @EnvironmentObject var dependencies: AppDependencies
    let ruleSections: [RuleSection]

    var gameSystemId: GameSystemId { viewModel.gameSystemId }
    private var featuredArmies: GuidedMatchFeaturedArmies { viewModel.featuredArmies }

    private var setupStepsCaption: String {
        let stepCount = viewModel.sortedMatchSteps.count
        switch gameSystemId {
        case .scTmg:
            return String(
                localized: "\(stepCount) steps — armies, mission setup, battlefield, attacker, and battle"
            )
        case .wh40k11e:
            return String(
                localized: "\(stepCount) steps — army pick, attacker roll, dispositions, deployment, and battle"
            )
        case .wh40k10eCp:
            return String(
                localized: "\(stepCount) steps — patrol, mission, formations, deployment, and battle"
            )
        default:
            return String(
                localized: "\(stepCount) steps — army pick, attacker roll, abilities, deployment, and battle"
            )
        }
    }

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State var selectedDestination: GuidedMatchDestination?
    @State private var showsAllSetupSteps = NewPlayerTipsStore.hasExpandedGuidedMatchSetup
    @State var showsMatchSync = false
    @State private var showsResetConfirmation = false

    private var usesCompactSetupLayout: Bool {
        !NewPlayerTipsStore.hasExpandedGuidedMatchSetup
    }
    init(viewModel: GuidedMatchViewModel, ruleSections: [RuleSection] = []) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.ruleSections = ruleSections
    }

    var body: some View {
        Group {
            if let catalog = viewModel.catalog {
                if usesPadSplitNavigation {
                    regularLayout(catalog: catalog)
                } else {
                    compactLayout(catalog: catalog)
                }
            } else if let errorMessage = viewModel.errorMessage {
                EmptyStateView(title: String(localized: "Unavailable"), message: errorMessage)
            } else {
                ProgressView()
            }
        }
        .navigationTitle(String(localized: "Guided Match"))
        .navigationBarTitleDisplayMode(layoutContext.isCompactHeight ? .inline : .large)
        .toolbar { matchSyncToolbar }
        .sheet(isPresented: $showsMatchSync) { matchSyncSheet }
        .navigationDestination(for: MatchHistoryLink.self) { _ in
            MatchHistoryListView(viewModel: dependencies.makeMatchHistoryViewModel())
        }
        .playNavigationDestinations()
        .confirmationDialog(
            String(localized: "Reset Match"),
            isPresented: $showsResetConfirmation,
            titleVisibility: .visible
        ) {
            Button(String(localized: "Save and Reset"), role: .destructive) {
                Task { await resetMatch(saveToHistory: true) }
            }
            Button(String(localized: "Discard"), role: .destructive) {
                Task { await resetMatch(saveToHistory: false) }
            }
            Button(String(localized: "Cancel"), role: .cancel) {}
        } message: {
            Text(String(localized: "Save this match to history before clearing, or discard it permanently."))
        }
        .task {
            await viewModel.load()
            guard AppLaunchArguments.shouldApplyStarterMatchup else { return }
            viewModel.applyStarterMatchup()
            if usesPadSplitNavigation {
                selectedDestination = .battleTracker
            }
        }
        .accessibilityIdentifier("guidedMatch.screen")
    }

    private var layoutContext: TabletomeLayoutContext {
        TabletomeLayout.context(
            horizontalSizeClass: horizontalSizeClass,
            verticalSizeClass: verticalSizeClass
        )
    }

    private var usesPadSplitNavigation: Bool {
        layoutContext.usesPadSplitNavigation && !dynamicTypeSize.needsLayoutAdaptation
    }

    private var isPadLandscape: Bool {
        layoutContext == .padLandscape
    }

    // MARK: - iPad

    @ViewBuilder
    private func regularLayout(catalog: SpearheadCatalog) -> some View {
        NavigationSplitView {
            List(selection: $selectedDestination) {
                guidedMatchSections(catalog: catalog, useSplitSelection: true)
            }
            .listStyle(.sidebar)
            .navigationTitle(String(localized: "Guided Match"))
            .navigationSplitViewColumnWidth(
                min: isPadLandscape ? 220 : 260,
                ideal: isPadLandscape ? 260 : 300,
                max: isPadLandscape ? 300 : 340
            )
        } detail: {
            guidedMatchDetail(catalog: catalog)
                .modifier(GuidedMatchDetailWidth(destination: selectedDestination))
        }
        .onChange(of: viewModel.matchState.hasBothArmies) { _, hasBoth in
            guard hasBoth, usesPadSplitNavigation, selectedDestination == nil else { return }
            selectedDestination = .battleTracker
        }
    }

    @ViewBuilder
    private func guidedMatchDetail(catalog: SpearheadCatalog) -> some View {
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
    private func guidedMatchPadWelcome(catalog: SpearheadCatalog) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                guidedMatchPlaceholder(
                    title: String(localized: "Start here"),
                    message: String(
                        localized: """
                        New to tabletop battles? Tap Use Starter Matchup to load both armies, or pick each player below.
                        """
                    )
                )

                if !viewModel.matchState.hasBothArmies {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                        Button(String(localized: "Use Starter Matchup")) {
                            viewModel.applyStarterMatchup()
                            selectedDestination = .battleTracker
                        }
                        .buttonStyle(.borderedProminent)
                        .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget)
                        .accessibilityIdentifier("guidedMatch.starterMatchup.detail")
                        .accessibilityLabel(String(localized: "Use Starter Matchup"))
                        .accessibilityHint(
                            String(
                                localized: "Fills both armies and recommended enhancement and objective picks."
                            )
                        )

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
                }
            }
            .padding(DesignTokens.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(String(localized: "Guided Match"))
    }

    @ViewBuilder
    private func guidedMatchScreen(
        destination: GuidedMatchDestination,
        catalog: SpearheadCatalog,
        dismissesArmySelectionOnSave: Bool
    ) -> some View {
        switch destination {
        case .playerOne:
                    ArmySelectionView(
                        title: String(localized: "Player 1 Army"),
                        selection: viewModel.matchState.playerOne,
                        factions: viewModel.sortedFactions,
                        featuredArmies: featuredArmies,
                        ruleSections: ruleSections,
                        gameSystemId: viewModel.gameSystemId,
                        dismissesOnSave: dismissesArmySelectionOnSave,
                        onSave: viewModel.updatePlayerOne
                    )
        case .playerTwo:
                    ArmySelectionView(
                        title: String(localized: "Player 2 Army"),
                        selection: viewModel.matchState.playerTwo,
                        factions: viewModel.sortedFactions,
                        featuredArmies: featuredArmies,
                        ruleSections: ruleSections,
                        gameSystemId: viewModel.gameSystemId,
                        dismissesOnSave: dismissesArmySelectionOnSave,
                        onSave: viewModel.updatePlayerTwo
                    )
        case .battleTracker:
            if viewModel.matchState.hasBothArmies {
                BattlePhaseTrackerShell(
                    gameSystemId: gameSystemId,
                    matchState: viewModel.matchState,
                    catalog: catalog,
                    ruleSections: ruleSections,
                    onMatchStateChange: { viewModel.reloadFromStore() },
                    onVictoryComplete: handleVictoryComplete
                )
            } else {
                guidedMatchPlaceholder(
                    title: String(localized: "Battle Phase Tracker"),
                    message: String(localized: "Choose both player armies to open the battle tracker.")
                )
            }
        case .step(let stepId):
            if let step = viewModel.sortedMatchSteps.first(where: { $0.id == stepId }),
               let index = viewModel.sortedMatchSteps.firstIndex(where: { $0.id == stepId }) {
                MatchStepDetailView(
                    step: step,
                    stepNumber: index + 1,
                    viewModel: viewModel,
                    ruleSections: ruleSections
                )
            } else {
                guidedMatchPlaceholder(
                    title: String(localized: "Match Setup"),
                    message: String(localized: "This step could not be loaded.")
                )
            }
        }
    }

    // MARK: - iPhone

    @ViewBuilder
    private func compactLayout(catalog: SpearheadCatalog) -> some View {
        List {
            guidedMatchSections(catalog: catalog, useSplitSelection: false)
        }
        .listStyle(.insetGrouped)
        .tabBarScrollInset()
        .readableContentWidth()
        .navigationDestination(for: GuidedMatchDestination.self) { destination in
            guidedMatchScreen(
                destination: destination,
                catalog: catalog,
                dismissesArmySelectionOnSave: true
            )
        }
    }

    // MARK: - Shared list content

    @ViewBuilder
    private func guidedMatchSections(catalog: SpearheadCatalog, useSplitSelection: Bool) -> some View {
        if usesCompactSetupLayout {
            compactGuidedMatchSections(catalog: catalog, useSplitSelection: useSplitSelection)
        } else {
            expandedGuidedMatchSections(catalog: catalog, useSplitSelection: useSplitSelection)
        }
    }

    @ViewBuilder
    private func compactGuidedMatchSections(catalog: SpearheadCatalog, useSplitSelection: Bool) -> some View {
        matchupSection
        sampleTurnSection
        playersSection(catalog: catalog, useSplitSelection: useSplitSelection)
        setupProgressSection
        continueSetupSection(catalog: catalog, useSplitSelection: useSplitSelection)
        battleTrackerSection(catalog: catalog, useSplitSelection: useSplitSelection)
        collapsedMatchSetupSection(catalog: catalog, useSplitSelection: useSplitSelection)
        resetSection
    }

    @ViewBuilder
    private func expandedGuidedMatchSections(catalog: SpearheadCatalog, useSplitSelection: Bool) -> some View {
        matchupSection
        setupProgressSection
        continueSetupSection(catalog: catalog, useSplitSelection: useSplitSelection)
        playersSection(catalog: catalog, useSplitSelection: useSplitSelection)
        battleTrackerSection(catalog: catalog, useSplitSelection: useSplitSelection)
        matchSetupSection(catalog: catalog, useSplitSelection: useSplitSelection)
        resetSection
    }

    @ViewBuilder
    private var sampleTurnSection: some View {
        if gameSystemId == .aosSpearhead {
            Section {
                NavigationLink(value: SampleTurnLink()) {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                        Label(String(localized: "Preview a Spearhead Turn"), systemImage: "play.circle")
                            .font(.headline)
                        Text(String(localized: "Two-minute tour — movement, shooting, dice, and scoring"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(minHeight: DesignTokens.minTouchTarget, alignment: .leading)
                }
                .accessibilityIdentifier("guidedMatch.sampleTurn")
            }
        } else if gameSystemId == .wh40k10eCp {
            Section {
                NavigationLink(value: CombatPatrolSampleTurnLink()) {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                        Label(String(localized: "Preview a Turn"), systemImage: "play.circle")
                            .font(.headline)
                        Text(String(localized: "Command-first tour — secure objectives, stratagems, and scoring"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(minHeight: DesignTokens.minTouchTarget, alignment: .leading)
                }
                .accessibilityIdentifier("guidedMatch.combatPatrolSampleTurn")
            }
        }
    }

    @ViewBuilder
    private func collapsedMatchSetupSection(catalog: SpearheadCatalog, useSplitSelection: Bool) -> some View {
        Section {
            DisclosureGroup(isExpanded: $showsAllSetupSteps) {
                matchSetupRows(catalog: catalog, useSplitSelection: useSplitSelection)
            } label: {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text(String(localized: "All Setup Steps"))
                        .font(.headline)
                    Text(setupStepsCaption)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .onChange(of: showsAllSetupSteps) { _, expanded in
                guard expanded else { return }
                NewPlayerTipsStore.markGuidedMatchSetupExpanded()
            }
            .accessibilityIdentifier("guidedMatch.allSetupSteps")
        } footer: {
            Text(String(localized: "Up Next above shows your next step. Expand to browse every setup step."))
        }
    }

    @ViewBuilder
    private func matchSetupRows(catalog: SpearheadCatalog, useSplitSelection: Bool) -> some View {
        ForEach(Array(viewModel.sortedMatchSteps.enumerated()), id: \.element.id) { index, step in
            if useSplitSelection {
                GuideStepCard(
                    stepNumber: index + 1,
                    title: step.title,
                    summary: step.summary,
                    isComplete: viewModel.matchState.completedStepIds.contains(step.id),
                    accessibilityId: "guidedMatch.step.\(step.id)"
                )
                .tag(GuidedMatchDestination.step(step.id))
                .listRowInsets(GuideStepCard.listRowInsets)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .disabled(!viewModel.matchState.hasBothArmies && step.id != "choose-armies")
            } else {
                NavigationLink(value: GuidedMatchDestination.step(step.id)) {
                    GuideStepCard(
                        stepNumber: index + 1,
                        title: step.title,
                        summary: step.summary,
                        isComplete: viewModel.matchState.completedStepIds.contains(step.id),
                        showsDisclosureIndicator: false,
                        accessibilityId: "guidedMatch.step.\(step.id)"
                    )
                }
                .disabled(!viewModel.matchState.hasBothArmies && step.id != "choose-armies")
                .listRowInsets(GuideStepCard.listRowInsets)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
        }
    }

    @ViewBuilder
    private var matchupSection: some View {
        Section {
            Button {
                viewModel.applyStarterMatchup()
                if usesPadSplitNavigation {
                    selectedDestination = .battleTracker
                }
            } label: {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    Label {
                        Text(featuredArmies.starterMatchupTitle)
                            .font(.headline)
                            .multilineTextAlignment(.leading)
                    } icon: {
                        Image(systemName: "flag.2.crossed.fill")
                            .foregroundStyle(Color.accentColor)
                    }
                    Text(featuredArmies.starterSetDescription)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(String(localized: "Use Starter Matchup"))
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget)
                        .foregroundStyle(Color.white)
                        .background(Color.accentColor, in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("guidedMatch.starterMatchup")
            .accessibilityLabel(
                String(
                    localized: "Use Starter Matchup, \(featuredArmies.starterMatchupTitle)"
                )
            )
            .accessibilityHint(
                String(
                    localized: "Fills both armies and recommended enhancement and objective picks."
                )
            )
        } header: {
            Text(String(localized: "Starter Set"))
        }

        if let summary = viewModel.matchupSummary {
            Section(String(localized: "Today's Match")) {
                Label {
                    Text(summary)
                        .font(.subheadline.weight(.medium))
                        .fixedSize(horizontal: false, vertical: true)
                } icon: {
                    Image(systemName: "person.2.fill")
                        .foregroundStyle(.secondary)
                }
                .accessibilityIdentifier("guidedMatch.matchupSummary")
            }
        }
    }

    @ViewBuilder
    private var setupProgressSection: some View {
        if viewModel.matchState.hasBothArmies, viewModel.setupProgress.total > 0 {
            Section(String(localized: "Setup Progress")) {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    HStack {
                        Text(
                            String(
                                localized: "\(viewModel.setupProgress.completed) of \(viewModel.setupProgress.total) steps complete"
                            )
                        )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        Spacer()
                        ProgressBadge(
                            done: viewModel.setupProgress.completed,
                            total: viewModel.setupProgress.total
                        )
                    }
                    ProgressView(value: viewModel.setupProgressFraction)
                        .tint(.accentColor)
                        .accessibilityLabel(String(localized: "Match setup progress"))
                    GuidedMatchSetupProgressList(
                        steps: viewModel.sortedMatchSteps,
                        completedStepIds: viewModel.matchState.completedStepIds
                    )
                }
                .accessibilityIdentifier("guidedMatch.setupProgress")
            }
        }
    }

    @ViewBuilder
    private func continueSetupSection(catalog: SpearheadCatalog, useSplitSelection: Bool) -> some View {
        if viewModel.matchState.hasBothArmies,
           let next = viewModel.nextIncompleteStep,
           let index = viewModel.sortedMatchSteps.firstIndex(where: { $0.id == next.id }) {
            Section {
                if useSplitSelection {
                    GuideStepCard(
                        stepNumber: index + 1,
                        title: next.title,
                        summary: next.summary,
                        isComplete: false,
                        accessibilityId: "guidedMatch.continue.\(next.id)"
                    )
                    .tag(GuidedMatchDestination.step(next.id))
                    .listRowInsets(GuideStepCard.listRowInsets)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                } else {
                    NavigationLink(value: GuidedMatchDestination.step(next.id)) {
                        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                            Text(String(localized: "Continue Setup"))
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.accentColor)
                            GuideStepCard(
                                stepNumber: index + 1,
                                title: next.title,
                                summary: next.summary,
                                isComplete: false,
                                showsDisclosureIndicator: false,
                                accessibilityId: "guidedMatch.continue.\(next.id)"
                            )
                        }
                    }
                    .listRowInsets(GuideStepCard.listRowInsets)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
            } header: {
                Text(String(localized: "Up Next"))
            }
        }
    }

    @ViewBuilder
    private func playersSection(catalog: SpearheadCatalog, useSplitSelection: Bool) -> some View {
        Section(String(localized: "Players")) {
            if useSplitSelection {
                playerSidebarRow(
                    label: String(localized: "Player 1"),
                    selection: viewModel.matchState.playerOne,
                    catalog: catalog,
                    destination: .playerOne
                )
                playerSidebarRow(
                    label: String(localized: "Player 2"),
                    selection: viewModel.matchState.playerTwo,
                    catalog: catalog,
                    destination: .playerTwo
                )
            } else {
                NavigationLink(value: GuidedMatchDestination.playerOne) {
                    PlayerArmyRow(
                        label: String(localized: "Player 1"),
                        selection: viewModel.matchState.playerOne,
                        catalog: catalog
                    )
                }
                .accessibilityIdentifier("guidedMatch.playerOne")

                NavigationLink(value: GuidedMatchDestination.playerTwo) {
                    PlayerArmyRow(
                        label: String(localized: "Player 2"),
                        selection: viewModel.matchState.playerTwo,
                        catalog: catalog
                    )
                }
                .accessibilityIdentifier("guidedMatch.playerTwo")
            }
        }
    }

    @ViewBuilder
    private func battleTrackerSection(catalog: SpearheadCatalog, useSplitSelection: Bool) -> some View {
        let setupComplete = viewModel.setupProgress.completed == viewModel.setupProgress.total
            && viewModel.setupProgress.total > 0

        Section {
            if useSplitSelection {
                Label(String(localized: "Battle Phase Tracker"), systemImage: "list.bullet.rectangle")
                    .frame(minHeight: DesignTokens.minTouchTarget)
                    .tag(GuidedMatchDestination.battleTracker)
                    .disabled(!viewModel.matchState.hasBothArmies)
                    .accessibilityIdentifier("guidedMatch.battleTracker")
                    .accessibilityLabel(String(localized: "Battle Phase Tracker"))
                    .accessibilityHint(
                        viewModel.matchState.hasBothArmies
                            ? String(localized: "Opens the guided battle tracker.")
                            : String(localized: "Choose both player armies first.")
                    )
                    .accessibilityAddTraits(.isButton)
            } else {
                NavigationLink(value: GuidedMatchDestination.battleTracker) {
                    if setupComplete {
                        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                            Label(String(localized: "Start the Battle"), systemImage: "flag.checkered")
                                .font(.headline)
                            Text(String(localized: "Setup is complete. Open the guided battle tracker."))
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                        .frame(minHeight: DesignTokens.minTouchTarget, alignment: .leading)
                    } else {
                        Label(String(localized: "Battle Phase Tracker"), systemImage: "list.bullet.rectangle")
                            .frame(minHeight: DesignTokens.minTouchTarget)
                    }
                }
                .disabled(!viewModel.matchState.hasBothArmies)
                .accessibilityIdentifier("guidedMatch.battleTracker")
            }
        } header: {
            Text(String(localized: "During the Battle"))
        } footer: {
            if !viewModel.matchState.hasBothArmies {
                Text(String(localized: "Choose both player armies to open the battle tracker."))
            } else if setupComplete {
                Text(String(localized: "The battle tracker walks you through deployment, each round, and every phase."))
            }
        }
    }

    @ViewBuilder
    private func matchSetupSection(catalog: SpearheadCatalog, useSplitSelection: Bool) -> some View {
        Section(String(localized: "Match Setup")) {
            matchSetupRows(catalog: catalog, useSplitSelection: useSplitSelection)
        }
    }

    private var resetSection: some View {
        Section {
            Button(role: .destructive) {
                if ReleaseSurface.showsMatchHistory, viewModel.matchState.hasBothArmies {
                    showsResetConfirmation = true
                } else {
                    viewModel.resetMatch()
                    selectedDestination = nil
                }
            } label: {
                Label(String(localized: "Reset Match"), systemImage: "arrow.counterclockwise")
                    .frame(minHeight: DesignTokens.minTouchTarget)
            }
            .accessibilityIdentifier("guidedMatch.reset")
        }
    }

    private func playerSidebarRow(
        label: String,
        selection: PlayerArmySelection,
        catalog: SpearheadCatalog,
        destination: GuidedMatchDestination
    ) -> some View {
        PlayerArmyRow(label: label, selection: selection, catalog: catalog)
            .tag(destination)
            .accessibilityIdentifier(destination == .playerOne ? "guidedMatch.playerOne" : "guidedMatch.playerTwo")
            .accessibilityLabel(playerSidebarAccessibilityLabel(label: label, selection: selection, catalog: catalog))
            .accessibilityHint(String(localized: "Opens army selection for this player."))
            .accessibilityAddTraits(.isButton)
    }

    private func playerSidebarAccessibilityLabel(
        label: String,
        selection: PlayerArmySelection,
        catalog: SpearheadCatalog
    ) -> String {
        let name = selection.playerName.isEmpty ? label : selection.playerName
        return "\(name), \(playerArmySubtitle(selection: selection, catalog: catalog))"
    }

    private func playerArmySubtitle(selection: PlayerArmySelection, catalog: SpearheadCatalog) -> String {
        guard let faction = catalog.factions.first(where: { $0.id == selection.factionId }),
              let army = faction.armies.first(where: { $0.id == selection.armyId }) else {
            return String(localized: "Tap to choose faction and army")
        }
        return "\(faction.name) — \(army.name)"
    }

    private func guidedMatchPlaceholder(title: String, message: String) -> some View {
        ContentUnavailableView {
            Label(title, systemImage: "flag.checkered")
        } description: {
            Text(message)
        }
    }
}

private struct PlayerArmyRow: View {
    let label: String
    let selection: PlayerArmySelection
    let catalog: SpearheadCatalog

    private var hasArmySelected: Bool {
        !selection.factionId.isEmpty && !selection.armyId.isEmpty
    }

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            Image(systemName: hasArmySelected ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(hasArmySelected ? Color.accentColor : Color(.tertiaryLabel))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Text(selection.playerName.isEmpty ? label : selection.playerName)
                    .font(.headline)
                Text(armySubtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(minHeight: DesignTokens.minTouchTarget, alignment: .leading)
    }

    private var armySubtitle: String {
        guard let faction = catalog.factions.first(where: { $0.id == selection.factionId }),
              let army = faction.armies.first(where: { $0.id == selection.armyId }) else {
            return String(localized: "Tap to choose faction and army")
        }
        return "\(faction.name) — \(army.name)"
    }
}

// swiftlint:enable type_body_length

private struct GuidedMatchDetailWidth: ViewModifier {
    let destination: GuidedMatchDestination?

    func body(content: Content) -> some View {
        if destination == .battleTracker {
            content.frame(maxWidth: .infinity, alignment: .leading)
        } else {
            content.readableContentWidth()
        }
    }
}
