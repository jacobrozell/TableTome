import SwiftUI
import TabletomeDomain

struct AppSearchView: View {
    @StateObject private var viewModel: AppSearchViewModel
    @EnvironmentObject private var dependencies: AppDependencies

    init(viewModel: AppSearchViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.index.isEmpty {
                ProgressView(String(localized: "Loading search…"))
                    .accessibilityIdentifier("search.loading")
            } else if let error = viewModel.errorMessage {
                EmptyStateView(
                    title: String(localized: "Unable to Load"),
                    message: error,
                    actionTitle: String(localized: "Retry"),
                    action: { Task { await viewModel.load() } }
                )
            } else {
                List {
                    if viewModel.showsGameSystemPicker {
                        gameSystemPickerSection
                    }

                    if viewModel.isShowingSearchResults {
                        searchResultsContent
                    } else {
                        browseContent
                    }
                }
                .listStyle(.insetGrouped)
                .searchable(
                    text: $viewModel.searchText,
                    prompt: GameSystemRulesLabels.searchPrompt(gameSystemId: viewModel.scopedGameSystemId)
                )
                .accessibilityIdentifier("search.screen")
            }
        }
        .navigationTitle(String(localized: "Rules Search"))
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
    }

    private var gameSystemPickerSection: some View {
        Section {
            Picker(String(localized: "Game mode"), selection: $viewModel.selectedGameSystemId) {
                ForEach(viewModel.gameSystems) { system in
                    Text(GameSystemRulesLabels.searchGameSystemPickerLabel(system)).tag(system.id)
                }
            }
            .onChange(of: viewModel.selectedGameSystemId) { _, newValue in
                viewModel.selectGameSystem(newValue)
            }
            .accessibilityIdentifier("search.gameSystemPicker")
        } footer: {
            Text(
                String(
                    localized: "Search only includes rules, units, and guides for the selected game mode."
                )
            )
        }
    }

    @ViewBuilder
    private var searchResultsContent: some View {
        if viewModel.searchResults.isEmpty {
            Section {
                Text(GameSystemRulesLabels.searchEmptyStateHint(gameSystemId: viewModel.scopedGameSystemId))
                    .foregroundStyle(.secondary)
                    .font(.callout)
                    .fixedSize(horizontal: false, vertical: true)
            }
        } else {
            ForEach(viewModel.groupedSearchResults, id: \.kind) { group in
                Section(group.kind.sectionLabel(gameSystemId: viewModel.scopedGameSystemId)) {
                    ForEach(group.results) { result in
                        NavigationLink {
                            AppSearchDestinationView(
                                result: result,
                                ruleSections: viewModel.ruleSections,
                                gettingStartedSteps: viewModel.gettingStartedSteps,
                                armies: viewModel.armies,
                                gameSystemId: viewModel.scopedGameSystemId,
                                dependencies: dependencies
                            )
                        } label: {
                            AppSearchResultRow(result: result)
                        }
                        .accessibilityIdentifier("search.result.\(result.id)")
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var browseContent: some View {
        Section {
            Text(GameSystemRulesLabels.browseIntro(gameSystemId: viewModel.scopedGameSystemId))
            .font(.callout)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
        }

        Section(String(localized: "Try asking")) {
            ForEach(AppSearchEngine.suggestedTopics(for: viewModel.scopedGameSystemId), id: \.self) { topic in
                Button {
                    viewModel.searchText = topic
                } label: {
                    Label(topic, systemImage: "magnifyingglass")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(minHeight: DesignTokens.minTouchTarget)
                }
                .accessibilityHint(String(localized: "Searches for this topic"))
                .accessibilityIdentifier("search.suggested.\(topic)")
            }
        }

        Section(String(localized: "Browse")) {
            NavigationLink {
                RulesReferenceView(
                    viewModel: dependencies.makeRulesReferenceViewModel(
                        gameSystemId: GameSystemId(resolving: viewModel.scopedGameSystemId)
                    )
                )
            } label: {
                Label(
                    GameSystemRulesLabels.rulesReferenceLinkTitle(gameSystemId: viewModel.scopedGameSystemId),
                    systemImage: "doc.text"
                )
                    .frame(minHeight: DesignTokens.minTouchTarget)
            }
            .accessibilityIdentifier("search.browse.rules")

            if showsGlossaryBrowseLink {
                NavigationLink {
                    RulesGlossaryView(
                        gameSystemId: viewModel.scopedGameSystemId,
                        ruleSections: viewModel.ruleSections
                    )
                } label: {
                    Label(
                        GameSystemRulesLabels.glossaryTitle(gameSystemId: viewModel.scopedGameSystemId),
                        systemImage: "book.fill"
                    )
                        .frame(minHeight: DesignTokens.minTouchTarget)
                }
                .accessibilityIdentifier("search.browse.glossary")
            }

            if GameSystemPlayContext.context(for: viewModel.scopedGameSystemId).capabilities.showsBattleTacticDecks {
                NavigationLink {
                    BattleTacticsReferenceView(ruleSections: viewModel.ruleSections)
                } label: {
                    Label(String(localized: "Card Decks Guide"), systemImage: "rectangle.stack")
                        .frame(minHeight: DesignTokens.minTouchTarget)
                }
                .accessibilityIdentifier("search.browse.cardDecks")
            }

            if GameSystemPlayContext.context(for: viewModel.scopedGameSystemId).capabilities.showsCombatPatrolMode {
                NavigationLink {
                    CombatPatrolMissionsReferenceView(ruleSections: viewModel.ruleSections)
                } label: {
                    Label(String(localized: "Missions Reference"), systemImage: "map")
                        .frame(minHeight: DesignTokens.minTouchTarget)
                }
                .accessibilityIdentifier("search.browse.missions")
            }

            NavigationLink {
                GameSystemDetailView(gameSystemId: viewModel.scopedGameSystemId)
            } label: {
                Label(
                    GameSystemRulesLabels.gameGuideBrowseTitle(gameSystemId: viewModel.scopedGameSystemId),
                    systemImage: "play.circle"
                )
                    .frame(minHeight: DesignTokens.minTouchTarget)
            }
            .accessibilityIdentifier("search.browse.gameGuide")
        }
    }

    private var showsGlossaryBrowseLink: Bool {
        !RulesGlossaryCatalog.entries(
            gameSystemId: viewModel.scopedGameSystemId,
            ruleSections: viewModel.ruleSections
        ).isEmpty
    }
}

private struct AppSearchResultRow: View {
    let result: AppSearchResult

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Text(result.title)
                .font(.headline)
            Text(result.subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
            if !result.snippet.isEmpty {
                Text(result.snippet)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(minHeight: DesignTokens.minTouchTarget, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(result.title), \(result.subtitle)")
        .accessibilityHint(result.snippet)
    }
}
