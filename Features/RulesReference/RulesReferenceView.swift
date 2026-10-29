import SwiftUI
import TabletomeDomain

private struct RulesCategoryFilter: Identifiable, Hashable {
    let category: RuleSectionCategory?
    var id: String { category?.rawValue ?? "all" }
}

struct RulesReferenceView: View {
    @StateObject private var viewModel: RulesReferenceViewModel
    @Environment(AppRouter.self) private var router
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var firstSessionRevision = 0
    @State private var showsEditionComparison = false

    private var showsPlayTabHint: Bool {
        _ = firstSessionRevision
        return FirstSessionStore.shouldEmphasizePlayTab()
    }

    private var playCapabilities: PlayCapabilities {
        GameSystemPlayContext.context(for: viewModel.selectedGameSystemId).capabilities
    }

    private var comparisonTitle: String? {
        if playCapabilities.showsBattleTacticDecks {
            return String(localized: "How Spearhead Differs")
        }
        if playCapabilities.resolvesWh40kRules {
            return String(localized: "Which 40k rules?")
        }
        return nil
    }

    init(viewModel: RulesReferenceViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.sections.isEmpty {
                ProgressView(String(localized: "Loading rules…"))
                    .asyncContentShell()
                    .accessibilityIdentifier("rules.loading")
                    .accessibilityLabel(String(localized: "Loading rules"))
                    .accessibilityHint(String(localized: "Rules content is being loaded."))
            } else if let error = viewModel.errorMessage {
                EmptyStateView(
                    title: String(localized: "Unable to Load"),
                    message: error,
                    systemImage: "exclamationmark.triangle",
                    actionTitle: String(localized: "Retry"),
                    action: { Task { await viewModel.load() } }
                )
                .asyncContentShell()
            } else {
                rulesList
            }
        }
        .ttScreenBackground()
        .navigationTitle(GameSystemRulesLabels.rulesReferenceTitle(gameSystemId: viewModel.selectedGameSystemId))
        .onAppear {
            syncActiveGameSystem()
            applyPendingRulesSearchQuery()
        }
        .onChange(of: router.pendingRulesSearchQuery) { _, newValue in
            guard newValue != nil else { return }
            applyPendingRulesSearchQuery()
        }
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
        .onReceive(NotificationCenter.default.publisher(for: .firstSessionStoreDidChange)) { _ in
            firstSessionRevision += 1
        }
        .sheet(isPresented: $showsEditionComparison) {
            comparisonSheet
        }
    }

    private var rulesList: some View {
        List {
            if viewModel.showsGameSystemPicker {
                gameSystemPicker
            }
            if showsPlayTabHint {
                playHint
            }
            categorySection
            if viewModel.showsQuickReference {
                quickReferenceSection
            }
            if viewModel.browseGroups.isEmpty {
                RulesBrowseEmptyState(
                    searchText: viewModel.searchText,
                    gameSystemId: viewModel.selectedGameSystemId
                )
            } else {
                groupedSections
            }
            if let comparisonTitle {
                comparisonRow(title: comparisonTitle)
            }
        }
        .ttGroupedList()
        .textCase(nil)
        .searchable(
            text: $viewModel.searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: GameSystemRulesLabels.rulesSearchPrompt(gameSystemId: viewModel.selectedGameSystemId)
        )
        .tabBarScrollInset(additionalBottom: DesignTokens.Spacing.xxl) // first rows otherwise sit under the tab bar
        .accessibilityIdentifier("rules.sectionList")
    }

    private var gameSystemPicker: some View {
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
            .accessibilityIdentifier("rules.gameSystemPicker")
            .accessibilityLabel(String(localized: "Which game are you playing?"))
        } footer: {
            Text(
                String(
                    localized: """
                    Matches the game you picked on the Play tab. Change it here to browse a different rules set.
                    """
                )
            )
            .font(TTFont.footnote)
            .foregroundStyle(TTColor.inkSecondary)
        }
    }

    private var playHint: some View {
        Section {
            TTNotice(
                title: String(localized: "New here? Start on the Play tab."),
                systemImage: "flag.checkered",
                action: (title: String(localized: "Go to Play"), run: { router.selectedTab = .learn })
            )
            .listHeroCardRow()
            .accessibilityIdentifier("rules.playHint")
        }
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
}

extension RulesReferenceView {
    private var categoryOptions: [RulesCategoryFilter] {
        [RulesCategoryFilter(category: nil)] + GameSystemRulesLabels.availableCategories(
            gameSystemId: viewModel.selectedGameSystemId
        ).map { RulesCategoryFilter(category: $0) }
    }

    private var categorySelection: Binding<RulesCategoryFilter> {
        Binding(
            get: { RulesCategoryFilter(category: viewModel.selectedCategory) },
            set: { viewModel.selectedCategory = $0.category }
        )
    }

    private var categorySection: some View {
        Section {
            TTSegmentedControl(
                selection: categorySelection,
                options: categoryOptions,
                title: { option in
                    guard let category = option.category else {
                        return String(localized: "All")
                    }
                    return GameSystemRulesLabels.categoryLabel(
                        category,
                        gameSystemId: viewModel.selectedGameSystemId
                    )
                }
            )
            .accessibilityLabel(String(localized: "Category"))
            .accessibilityHint(String(localized: "Filters rule sections by category"))
            .accessibilityIdentifier("rules.categoryPicker")
            .listRowInsets(
                EdgeInsets(
                    top: DesignTokens.Spacing.sm,
                    leading: DesignTokens.Spacing.md,
                    bottom: DesignTokens.Spacing.sm,
                    trailing: DesignTokens.Spacing.md
                )
            )
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        }
    }

    private var quickReferenceColumns: [GridItem] {
        let count = dynamicTypeSize.needsLayoutAdaptation ? 1 : 2
        return Array(repeating: GridItem(.flexible(), spacing: DesignTokens.Spacing.sm), count: count)
    }

    private var quickReferenceSection: some View {
        Section {
            LazyVGrid(columns: quickReferenceColumns, spacing: DesignTokens.Spacing.sm) {
                ForEach(viewModel.quickReferenceSections) { section in
                    NavigationLink(
                        value: RuleSectionLink(
                            gameSystemId: viewModel.selectedGameSystemId,
                            sectionId: section.id
                        )
                    ) {
                        quickReferenceTile(section)
                    }
                    .buttonStyle(.borderless)
                    .accessibilityLabel(section.title)
                    .accessibilityHint(String(localized: "Opens this rule section."))
                    .accessibilityIdentifier("rules.quick.\(section.id)")
                }
            }
            .listRowInsets(
                EdgeInsets(
                    top: DesignTokens.Spacing.sm,
                    leading: DesignTokens.Spacing.md,
                    bottom: DesignTokens.Spacing.sm,
                    trailing: DesignTokens.Spacing.md
                )
            )
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        } header: {
            TTSectionHeader(String(localized: "Quick Reference"))
        }
    }

    private func quickReferenceTile(_ section: RuleSection) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            TTIconTile(systemImage: quickReferenceSymbol(for: section.id))
            Text(section.title)
                .font(TTFont.subheadline.weight(.semibold))
                .foregroundStyle(TTColor.inkPrimary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .adaptiveLineLimit(2)
        }
        .padding(DesignTokens.Spacing.sm)
        .frame(maxWidth: .infinity, minHeight: 88, alignment: .topLeading)
        .background(
            TTColor.raised,
            in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md, style: .continuous)
        )
        .ttElevation(.raised)
        .contentShape(Rectangle())
    }

    private func quickReferenceSymbol(for sectionId: String) -> String {
        switch sectionId {
        case "combat-sequence":
            "figure.fencing"
        case "turn-structure":
            "timer"
        case "spearhead-scoring":
            "star.fill"
        case "glossary-objective-control":
            "target"
        default:
            "book.closed"
        }
    }

    private var groupedSections: some View {
        ForEach(viewModel.browseGroups) { group in
            Section {
                ForEach(group.sections) { section in
                    sectionLink(section)
                }
            } header: {
                TTSectionHeader(
                    GameSystemRulesLabels.categoryRowLabel(
                        group.category,
                        gameSystemId: viewModel.selectedGameSystemId
                    )
                )
            }
        }
    }

    private func sectionLink(_ section: RuleSection) -> some View {
        NavigationLink(
            value: RuleSectionLink(
                gameSystemId: viewModel.selectedGameSystemId,
                sectionId: section.id
            )
        ) {
            RuleSectionRow(
                title: section.title,
                category: section.category,
                gameSystemId: viewModel.selectedGameSystemId,
                content: section.content,
                searchText: viewModel.searchText,
                accessibilityId: "rules.section.\(section.id)"
            )
        }
        .navigationLinkIndicatorVisibility(.hidden)
        .ttListRow()
    }

    private func comparisonRow(title: String) -> some View {
        Section {
            Button {
                showsEditionComparison = true
            } label: {
                TTRow(title: title, systemImage: "info.circle")
            }
            .buttonStyle(.plain)
            .accessibilityHint(String(localized: "Shows how this rules format differs."))
            .accessibilityIdentifier("rules.comparison.open")
            .ttListRow()
        }
    }

    private var comparisonSheet: some View {
        NavigationStack {
            ScrollView {
                editionComparison
                    .readableContentWidth()
                    .padding(DesignTokens.Spacing.md)
            }
            .ttScreenBackground()
            .navigationTitle(comparisonTitle ?? String(localized: "Rules"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Done")) {
                        showsEditionComparison = false
                    }
                    .accessibilityIdentifier("rules.comparison.done")
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(TTColor.canvas)
    }

    @ViewBuilder
    private var editionComparison: some View {
        if playCapabilities.showsBattleTacticDecks {
            SpearheadRulesComparisonCard()
        } else if playCapabilities.resolvesWh40kRules {
            CombatPatrolRulesComparisonCard()
        }
    }
}
