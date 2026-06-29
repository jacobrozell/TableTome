import SwiftUI
import TabletomeDomain

struct RulesReferenceView: View {
    @StateObject private var viewModel: RulesReferenceViewModel
    @Environment(AppRouter.self) private var router
    @State private var firstSessionRevision = 0

    private var showsPlayTabHint: Bool {
        _ = firstSessionRevision
        return FirstSessionStore.shouldEmphasizePlayTab()
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
                List {
                    if viewModel.showsGameSystemPicker {
                        Section {
                            Picker(String(localized: "Which game are you playing?"), selection: $viewModel.selectedGameSystemId) {
                                ForEach(viewModel.gameSystems) { system in
                                    Text(gameSystemPickerLabel(system)).tag(system.id)
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
                        }
                    }

                    Section {
                        Text(
                            GameSystemRulesLabels.browseIntro(
                                gameSystemId: viewModel.selectedGameSystemId
                            )
                        )
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                        if showsEditionComparison(for: viewModel.selectedGameSystemId) {
                            rulesEditionComparisonCard(
                                gameSystemId: viewModel.selectedGameSystemId
                            )
                            .padding(.top, DesignTokens.Spacing.sm)
                        }
                    } footer: {
                        if showsPlayTabHint {
                            Text(
                                String(
                                    localized: """
                                    New here? Most players start on the Play tab — pick your box, then open Getting Started.
                                    """
                                )
                            )
                        }
                    }

                    Section {
                        Picker(String(localized: "Category"), selection: $viewModel.selectedCategory) {
                            Text(String(localized: "All")).tag(RuleSectionCategory?.none)
                            ForEach(
                                GameSystemRulesLabels.availableCategories(
                                    gameSystemId: viewModel.selectedGameSystemId
                                ),
                                id: \.self
                            ) { category in
                                Text(
                                    GameSystemRulesLabels.categoryLabel(
                                        category,
                                        gameSystemId: viewModel.selectedGameSystemId
                                    )
                                )
                                .tag(Optional(category))
                            }
                        }
                        .accessibilityLabel(String(localized: "Category"))
                        .accessibilityHint(String(localized: "Filters rule sections by category"))
                        .accessibilityIdentifier("rules.categoryPicker")
                    }

                    Section(String(localized: "Sections")) {
                        if viewModel.filteredSections.isEmpty {
                            RulesBrowseEmptyState(
                                searchText: viewModel.searchText,
                                gameSystemId: viewModel.selectedGameSystemId
                            )
                        } else {
                            ForEach(viewModel.filteredSections) { section in
                                NavigationLink(value: RuleSectionLink(
                                    gameSystemId: viewModel.selectedGameSystemId,
                                    sectionId: section.id
                                )) {
                                    RuleSectionRow(
                                        title: section.title,
                                        category: section.category,
                                        gameSystemId: viewModel.selectedGameSystemId,
                                        accessibilityId: "rules.section.\(section.id)"
                                    )
                                }
                                .navigationLinkIndicatorVisibility(.hidden)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .searchable(
                    text: $viewModel.searchText,
                    prompt: GameSystemRulesLabels.rulesSearchPrompt(gameSystemId: viewModel.selectedGameSystemId)
                )
                .tabBarScrollInset()
                .accessibilityIdentifier("rules.sectionList")
            }
        }
        .navigationTitle(GameSystemRulesLabels.rulesReferenceTitle(gameSystemId: viewModel.selectedGameSystemId))
        .onAppear {
            let activeId = router.activeGameSystemId
            if viewModel.selectedGameSystemId != activeId {
                viewModel.selectGameSystem(activeId)
            }
        }
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
        .onReceive(NotificationCenter.default.publisher(for: .firstSessionStoreDidChange)) { _ in
            firstSessionRevision += 1
        }
    }

    private func gameSystemPickerLabel(_ system: GameSystem) -> String {
        GameSystemRulesLabels.searchGameSystemPickerLabel(system)
    }

    private func showsEditionComparison(for gameSystemId: String) -> Bool {
        gameSystemId == GameSystemId.wh40k10eCp.rawValue
            || gameSystemId == GameSystemId.wh40k11e.rawValue
            || gameSystemId == GameSystemId.aosSpearhead.rawValue
    }

    @ViewBuilder
    private func rulesEditionComparisonCard(gameSystemId: String) -> some View {
        switch gameSystemId {
        case GameSystemId.wh40k10eCp.rawValue, GameSystemId.wh40k11e.rawValue:
            CombatPatrolRulesComparisonCard()
        case GameSystemId.aosSpearhead.rawValue:
            SpearheadRulesComparisonCard()
        default:
            EmptyView()
        }
    }
}

struct RuleSectionDetailView: View {
    let section: RuleSection
    let allSections: [RuleSection]
    var gameSystemId: String = GameSystemRulesLabels.defaultGameSystemId

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                Text(
                    GameSystemRulesLabels.categoryRowLabel(
                        section.category,
                        gameSystemId: gameSystemId
                    )
                )
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .accessibilityAddTraits(.isHeader)

                Text(section.content)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("rules.sectionContent.\(section.id)")

                GlossaryChipsRow(
                    text: section.content,
                    gameSystemId: gameSystemId,
                    ruleSections: allSections
                )

                if !relatedSections.isEmpty {
                    ReferenceLinksGroup {
                        ForEach(relatedSections) { related in
                            if related.id != relatedSections.first?.id {
                                Divider().padding(.leading, DesignTokens.Spacing.md)
                            }
                            NavigationLink(value: RuleSectionLink(gameSystemId: gameSystemId, sectionId: related.id)) {
                                ReferenceLinkRow(title: related.title, systemImage: "doc.text")
                            }
                            .accessibilityLabel(related.title)
                            .accessibilityHint(String(localized: "Opens related rule section"))
                            .accessibilityIdentifier("rules.related.\(related.id)")
                        }
                    }
                }
            }
            .readableContentWidth()
            .padding(DesignTokens.Spacing.md)
        }
        .tabBarScrollInset()
        .navigationTitle(section.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var relatedSections: [RuleSection] {
        section.relatedSectionIds.compactMap { id in
            allSections.first { $0.id == id }
        }
    }
}
