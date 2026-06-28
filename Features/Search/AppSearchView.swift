import SwiftUI
import TabletomeDomain

struct AppSearchView: View {
    @StateObject private var viewModel: AppSearchViewModel
    @EnvironmentObject private var dependencies: AppDependencies
    @Environment(AppRouter.self) private var router

    init(viewModel: AppSearchViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.index.isEmpty {
                ProgressView(String(localized: "Loading search…"))
                    .asyncContentShell()
                    .accessibilityIdentifier("search.loading")
            } else if let error = viewModel.errorMessage {
                EmptyStateView(
                    title: String(localized: "Unable to Load"),
                    message: error,
                    systemImage: "wifi.exclamationmark",
                    actionTitle: String(localized: "Retry"),
                    action: { Task { await viewModel.load() } }
                )
                .asyncContentShell()
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
                .tabBarScrollInset()
                .searchable(
                    text: $viewModel.searchText,
                    prompt: GameSystemRulesLabels.searchPrompt(gameSystemId: viewModel.scopedGameSystemId)
                )
                .accessibilityIdentifier("search.screen")
            }
        }
        .navigationTitle(String(localized: "Rules Search"))
        .task { await viewModel.load() }
        .onAppear {
            syncActiveGameSystem()
            applyPendingRulesSearchQuery()
        }
        .onChange(of: router.pendingRulesSearchQuery) { _, _ in
            applyPendingRulesSearchQuery()
        }
        .refreshable { await viewModel.load() }
    }

    private func syncActiveGameSystem() {
        let activeId = router.activeGameSystemId
        if viewModel.selectedGameSystemId != activeId {
            viewModel.selectGameSystem(activeId)
        }
    }

    private func applyPendingRulesSearchQuery() {
        guard let query = router.consumePendingRulesSearchQuery() else { return }
        syncActiveGameSystem()
        viewModel.searchText = query
    }

    private var gameSystemPickerSection: some View {
        Section {
            Picker(String(localized: "Which game are you playing?"), selection: $viewModel.selectedGameSystemId) {
                ForEach(viewModel.gameSystems) { system in
                    Text(GameSystemRulesLabels.searchGameSystemPickerLabel(system)).tag(system.id)
                }
            }
            .onChange(of: viewModel.selectedGameSystemId) { _, newValue in
                router.setActiveGameSystem(newValue)
                viewModel.selectGameSystem(newValue)
            }
            .accessibilityIdentifier("search.gameSystemPicker")
        } footer: {
            Text(
                String(
                    localized: """
                    Matches the game you picked on the Play tab. Change it here to search a different rules set.
                    """
                )
            )
        }
    }

    @ViewBuilder
    private var searchResultsContent: some View {
        if viewModel.searchResults.isEmpty {
            Section {
                ContentUnavailableView {
                    Label(String(localized: "No results"), systemImage: "magnifyingglass")
                } description: {
                    Text(GameSystemRulesLabels.searchEmptyStateHint(gameSystemId: viewModel.scopedGameSystemId))
                }
                .listRowInsets(EdgeInsets(top: 24, leading: 0, bottom: 24, trailing: 0))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
        } else {
            ForEach(viewModel.groupedSearchResults, id: \.kind) { group in
                Section(group.kind.sectionLabel(gameSystemId: viewModel.scopedGameSystemId)) {
                    ForEach(group.results) { result in
                        NavigationLink(value: AppSearchResultLink(
                            gameSystemId: viewModel.scopedGameSystemId,
                            resultId: result.id
                        )) {
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

        Section {
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
        } header: {
            Text(String(localized: "Try asking"))
        } footer: {
            if !FirstSessionStore.hasOpenedGameGuide {
                Text(String(localized: "Most beginners start on Play — use Rules Search when a term comes up in setup."))
            }
        }

        Section(String(localized: "Browse")) {
            NavigationLink(value: RulesReferenceBrowseLink(gameSystemId: viewModel.scopedGameSystemId)) {
                Label(
                    GameSystemRulesLabels.rulesReferenceLinkTitle(gameSystemId: viewModel.scopedGameSystemId),
                    systemImage: "doc.text"
                )
                    .frame(minHeight: DesignTokens.minTouchTarget)
            }
            .accessibilityIdentifier("search.browse.rules")

            if showsGlossaryBrowseLink {
                NavigationLink(value: RulesGlossaryBrowseLink(gameSystemId: viewModel.scopedGameSystemId)) {
                    Label(
                        GameSystemRulesLabels.glossaryTitle(gameSystemId: viewModel.scopedGameSystemId),
                        systemImage: "book.fill"
                    )
                        .frame(minHeight: DesignTokens.minTouchTarget)
                }
                .accessibilityIdentifier("search.browse.glossary")
            }

            if GameSystemPlayContext.context(for: viewModel.scopedGameSystemId).capabilities.showsBattleTacticDecks {
                NavigationLink(value: BattleTacticsReferenceLink(gameSystemId: viewModel.scopedGameSystemId)) {
                    Label(String(localized: "Card Decks Guide"), systemImage: "rectangle.stack")
                        .frame(minHeight: DesignTokens.minTouchTarget)
                }
                .accessibilityIdentifier("search.browse.cardDecks")
            }

            if GameSystemPlayContext.context(for: viewModel.scopedGameSystemId).capabilities.usesPatrolFormatRules {
                NavigationLink(value: CombatPatrolMissionsLink(gameSystemId: viewModel.scopedGameSystemId)) {
                    Label(String(localized: "Missions Reference"), systemImage: "map")
                        .frame(minHeight: DesignTokens.minTouchTarget)
                }
                .accessibilityIdentifier("search.browse.missions")
            }

            NavigationLink(value: GameGuideBrowseLink(gameSystemId: viewModel.scopedGameSystemId)) {
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
            HStack(alignment: .firstTextBaseline, spacing: DesignTokens.Spacing.sm) {
                Image(systemName: resultKindSymbol)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.accentOnSurface)
                    .symbolRenderingMode(.hierarchical)
                    .frame(width: 20)
                    .accessibilityHidden(true)
                Text(result.title)
                    .font(.headline)
            }
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
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(result.title), \(result.subtitle)")
        .accessibilityHint(result.snippet)
    }

    private var resultKindSymbol: String {
        switch result.kind {
        case .ruleSection: "doc.text"
        case .glossary: "character.book.closed"
        case .gettingStarted: "map"
        case .editionMigration: "arrow.triangle.2.circlepath"
        case .matchSetup: "flag.checkered"
        case .deployment: "square.grid.3x3"
        case .battleTactics, .cardDeck: "rectangle.stack"
        case .warscroll: "person.3.fill"
        case .armyRule: "shield.lefthalf.filled"
        case .phaseTip: "clock.arrow.circlepath"
        case .appFeature: "sparkles"
        }
    }
}
