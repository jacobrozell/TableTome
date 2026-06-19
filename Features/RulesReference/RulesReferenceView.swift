import SwiftUI
import TabletomeDomain

struct RulesReferenceView: View {
    @StateObject private var viewModel: RulesReferenceViewModel

    init(viewModel: RulesReferenceViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.sections.isEmpty {
                ProgressView(String(localized: "Loading rules…"))
                    .accessibilityIdentifier("rules.loading")
                    .accessibilityLabel(String(localized: "Loading rules"))
                    .accessibilityHint(String(localized: "Rules content is being loaded."))
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
                        Section {
                            Picker(String(localized: "Which game are you playing?"), selection: $viewModel.selectedGameSystemId) {
                                ForEach(viewModel.gameSystems) { system in
                                    Text(gameSystemPickerLabel(system)).tag(system.id)
                                }
                            }
                            .onChange(of: viewModel.selectedGameSystemId) { _, newValue in
                                viewModel.selectGameSystem(newValue)
                            }
                            .accessibilityIdentifier("rules.gameSystemPicker")
                            .accessibilityLabel(String(localized: "Which game are you playing?"))
                            .accessibilityHint(
                                String(
                                    localized: """
                                    Matches the game you picked on the Play tab. Change it here to browse a different rules set.
                                    """
                                )
                            )
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
                            if viewModel.searchText.isEmpty {
                                Text(String(localized: "No matching sections"))
                                    .foregroundStyle(.secondary)
                            } else {
                                Text(String(localized: "No results for this search. Try a shorter phrase or check another category."))
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
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
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .searchable(
                    text: $viewModel.searchText,
                    prompt: GameSystemRulesLabels.rulesSearchPrompt(gameSystemId: viewModel.selectedGameSystemId)
                )
                .accessibilityIdentifier("rules.sectionList")
            }
        }
        .navigationTitle(GameSystemRulesLabels.rulesReferenceTitle(gameSystemId: viewModel.selectedGameSystemId))
        .onAppear {
            let activeId = ActiveGameContextStore.gameSystemId
            if viewModel.selectedGameSystemId != activeId {
                viewModel.selectGameSystem(activeId)
            }
        }
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
    }

    private func gameSystemPickerLabel(_ system: GameSystem) -> String {
        GameSystemRulesLabels.searchGameSystemPickerLabel(system)
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
