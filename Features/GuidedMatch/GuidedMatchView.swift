import SwiftUI
import TabletomeDomain

struct GuidedMatchView: View {
    @StateObject private var viewModel: GuidedMatchViewModel
    let ruleSections: [RuleSection]

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var selectedDestination: GuidedMatchDestination?

    init(viewModel: GuidedMatchViewModel, ruleSections: [RuleSection] = []) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.ruleSections = ruleSections
    }

    var body: some View {
        Group {
            if let catalog = viewModel.catalog {
                if horizontalSizeClass == .regular {
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
        .navigationBarTitleDisplayMode(horizontalSizeClass == .regular ? .inline : .large)
        .task { await viewModel.load() }
        .accessibilityIdentifier("guidedMatch.screen")
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
        } detail: {
            guidedMatchDetail(catalog: catalog)
                .readableContentWidth()
        }
    }

    @ViewBuilder
    private func guidedMatchDetail(catalog: SpearheadCatalog) -> some View {
        switch selectedDestination {
        case .playerOne:
            ArmySelectionView(
                title: String(localized: "Player 1 Army"),
                selection: viewModel.matchState.playerOne,
                factions: viewModel.sortedFactions,
                ruleSections: ruleSections,
                dismissesOnSave: false,
                onSave: viewModel.updatePlayerOne
            )
        case .playerTwo:
            ArmySelectionView(
                title: String(localized: "Player 2 Army"),
                selection: viewModel.matchState.playerTwo,
                factions: viewModel.sortedFactions,
                ruleSections: ruleSections,
                dismissesOnSave: false,
                onSave: viewModel.updatePlayerTwo
            )
        case .battleTracker:
            if viewModel.matchState.hasBothArmies {
                BattlePhaseTrackerView(
                    matchState: viewModel.matchState,
                    catalog: catalog,
                    ruleSections: ruleSections
                )
            } else {
                guidedMatchPlaceholder(
                    title: String(localized: "Battle Phase Tracker"),
                    message: String(localized: "Choose both player armies to open the battle tracker.")
                )
            }
        case .rollEvaluator:
            CombatRollEvaluatorView(ruleSections: ruleSections)
        case .unitMatchup:
            UnitMatchupEvaluatorView(ruleSections: ruleSections)
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
        case nil:
            guidedMatchPlaceholder(
                title: String(localized: "Guided Match"),
                message: String(localized: "Select a player, step, or the battle tracker from the sidebar.")
            )
        }
    }

    // MARK: - iPhone

    @ViewBuilder
    private func compactLayout(catalog: SpearheadCatalog) -> some View {
        List {
            guidedMatchSections(catalog: catalog, useSplitSelection: false)
        }
        .listStyle(.insetGrouped)
        .readableContentWidth()
    }

    // MARK: - Shared list content

    @ViewBuilder
    private func guidedMatchSections(catalog: SpearheadCatalog, useSplitSelection: Bool) -> some View {
        matchupSection
        setupProgressSection
        playersSection(catalog: catalog, useSplitSelection: useSplitSelection)
        battleTrackerSection(catalog: catalog, useSplitSelection: useSplitSelection)
        matchSetupSection(catalog: catalog, useSplitSelection: useSplitSelection)
        resetSection
    }

    @ViewBuilder
    private var matchupSection: some View {
        Section(String(localized: "Starter Set")) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                Text(SpearheadFeaturedArmies.starterMatchupTitle)
                    .font(.headline)
                Text(String(localized: "Quick-start the Skaventide / Ultimate Starter Set matchup with full warscrolls, setup, and battle tools."))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                Button(String(localized: "Use Starter Matchup")) {
                    viewModel.applyStarterMatchup()
                }
                .buttonStyle(.borderedProminent)
                .frame(minHeight: DesignTokens.minTouchTarget)
                .accessibilityIdentifier("guidedMatch.starterMatchup")
            }
        }

        if let summary = viewModel.matchupSummary {
            Section(String(localized: "Today's Match")) {
                Text(summary)
                    .font(.headline)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("guidedMatch.matchupSummary")
            }
        }
    }

    @ViewBuilder
    private var setupProgressSection: some View {
        if viewModel.matchState.hasBothArmies, viewModel.setupProgress.total > 0 {
            Section(String(localized: "Setup Progress")) {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    Text(
                        String(
                            localized: "\(viewModel.setupProgress.completed) of \(viewModel.setupProgress.total) steps complete"
                        )
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    ProgressView(value: viewModel.setupProgressFraction)
                        .accessibilityLabel(String(localized: "Match setup progress"))
                }
                .accessibilityIdentifier("guidedMatch.setupProgress")
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
                NavigationLink {
                    ArmySelectionView(
                        title: String(localized: "Player 1 Army"),
                        selection: viewModel.matchState.playerOne,
                        factions: viewModel.sortedFactions,
                        ruleSections: ruleSections,
                        onSave: viewModel.updatePlayerOne
                    )
                } label: {
                    PlayerArmyRow(
                        label: String(localized: "Player 1"),
                        selection: viewModel.matchState.playerOne,
                        catalog: catalog
                    )
                }
                .accessibilityIdentifier("guidedMatch.playerOne")

                NavigationLink {
                    ArmySelectionView(
                        title: String(localized: "Player 2 Army"),
                        selection: viewModel.matchState.playerTwo,
                        factions: viewModel.sortedFactions,
                        ruleSections: ruleSections,
                        onSave: viewModel.updatePlayerTwo
                    )
                } label: {
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
        Section {
            if ReleaseSurface.showsRollEvaluator {
                if useSplitSelection {
                    Label(String(localized: "Roll Evaluator"), systemImage: "dice.fill")
                        .frame(minHeight: DesignTokens.minTouchTarget)
                        .tag(GuidedMatchDestination.rollEvaluator)
                        .accessibilityIdentifier("guidedMatch.rollEvaluator")
                    Label(String(localized: "Unit Matchup"), systemImage: "arrow.left.arrow.right")
                        .frame(minHeight: DesignTokens.minTouchTarget)
                        .tag(GuidedMatchDestination.unitMatchup)
                        .accessibilityIdentifier("guidedMatch.unitMatchup")
                } else {
                    NavigationLink {
                        CombatRollEvaluatorView(ruleSections: ruleSections)
                    } label: {
                        Label(String(localized: "Roll Evaluator"), systemImage: "dice.fill")
                            .frame(minHeight: DesignTokens.minTouchTarget)
                    }
                    .accessibilityIdentifier("guidedMatch.rollEvaluator")
                    NavigationLink {
                        UnitMatchupEvaluatorView(ruleSections: ruleSections)
                    } label: {
                        Label(String(localized: "Unit Matchup"), systemImage: "arrow.left.arrow.right")
                            .frame(minHeight: DesignTokens.minTouchTarget)
                    }
                    .accessibilityIdentifier("guidedMatch.unitMatchup")
                }
            }

            if useSplitSelection {
                Label(String(localized: "Battle Phase Tracker"), systemImage: "list.bullet.rectangle")
                    .frame(minHeight: DesignTokens.minTouchTarget)
                    .tag(GuidedMatchDestination.battleTracker)
                    .disabled(!viewModel.matchState.hasBothArmies)
                    .accessibilityIdentifier("guidedMatch.battleTracker")
            } else {
                NavigationLink {
                    BattlePhaseTrackerView(
                        matchState: viewModel.matchState,
                        catalog: catalog,
                        ruleSections: ruleSections
                    )
                } label: {
                    Label(String(localized: "Battle Phase Tracker"), systemImage: "list.bullet.rectangle")
                        .frame(minHeight: DesignTokens.minTouchTarget)
                }
                .disabled(!viewModel.matchState.hasBothArmies)
                .accessibilityIdentifier("guidedMatch.battleTracker")
            }
        } header: {
            Text(String(localized: "During the Battle"))
        } footer: {
            if !viewModel.matchState.hasBothArmies {
                Text(String(localized: "Choose both player armies to open the battle tracker."))
            }
        }
    }

    @ViewBuilder
    private func matchSetupSection(catalog: SpearheadCatalog, useSplitSelection: Bool) -> some View {
        Section(String(localized: "Match Setup")) {
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
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .disabled(!viewModel.matchState.hasBothArmies && step.id != "choose-armies")
                } else {
                    NavigationLink {
                        MatchStepDetailView(
                            step: step,
                            stepNumber: index + 1,
                            viewModel: viewModel,
                            ruleSections: ruleSections
                        )
                    } label: {
                        GuideStepCard(
                            stepNumber: index + 1,
                            title: step.title,
                            summary: step.summary,
                            isComplete: viewModel.matchState.completedStepIds.contains(step.id),
                            accessibilityId: "guidedMatch.step.\(step.id)"
                        )
                    }
                    .disabled(!viewModel.matchState.hasBothArmies && step.id != "choose-armies")
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
            }
        }
    }

    private var resetSection: some View {
        Section {
            Button(role: .destructive) {
                viewModel.resetMatch()
                selectedDestination = nil
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

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Text(selection.playerName.isEmpty ? label : selection.playerName)
                .font(.headline)
            Text(armySubtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
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
