import SwiftUI
import TabletomeDomain

struct GuidedMatchView: View {
    @StateObject private var viewModel: GuidedMatchViewModel
    let ruleSections: [RuleSection]

    init(viewModel: GuidedMatchViewModel, ruleSections: [RuleSection] = []) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.ruleSections = ruleSections
    }

    var body: some View {
        Group {
            if let catalog = viewModel.catalog {
                List {
                    if let summary = viewModel.matchupSummary {
                        Section(String(localized: "Today's Match")) {
                            Text(summary)
                                .font(.headline)
                                .fixedSize(horizontal: false, vertical: true)
                                .accessibilityIdentifier("guidedMatch.matchupSummary")
                        }
                    }

                    Section(String(localized: "Players")) {
                        NavigationLink {
                            ArmySelectionView(
                                title: String(localized: "Player 1 Army"),
                                selection: viewModel.matchState.playerOne,
                                factions: viewModel.sortedFactions,
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

                    Section(String(localized: "During the Battle")) {
                        NavigationLink {
                            BattlePhaseTrackerView(
                                matchState: viewModel.matchState,
                                catalog: catalog
                            )
                        } label: {
                            Label(String(localized: "Battle Phase Tracker"), systemImage: "list.bullet.rectangle")
                                .frame(minHeight: DesignTokens.minTouchTarget)
                        }
                        .disabled(!viewModel.matchState.hasBothArmies)
                        .accessibilityIdentifier("guidedMatch.battleTracker")
                    }

                    Section(String(localized: "Match Setup")) {
                        ForEach(Array(viewModel.sortedMatchSteps.enumerated()), id: \.element.id) { index, step in
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

                    Section {
                        Button(role: .destructive) {
                            viewModel.resetMatch()
                        } label: {
                            Label(String(localized: "Reset Match"), systemImage: "arrow.counterclockwise")
                                .frame(minHeight: DesignTokens.minTouchTarget)
                        }
                        .accessibilityIdentifier("guidedMatch.reset")
                    }
                }
                .listStyle(.insetGrouped)
            } else if let errorMessage = viewModel.errorMessage {
                EmptyStateView(title: String(localized: "Unavailable"), message: errorMessage)
            } else {
                ProgressView()
            }
        }
        .navigationTitle(String(localized: "Guided Match"))
        .navigationBarTitleDisplayMode(.large)
        .task { await viewModel.load() }
        .accessibilityIdentifier("guidedMatch.screen")
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
