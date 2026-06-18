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
                            Picker(String(localized: "Game"), selection: $viewModel.selectedGameSystemId) {
                                ForEach(viewModel.gameSystems) { system in
                                    Text(gameSystemPickerLabel(system)).tag(system.id)
                                }
                            }
                            .onChange(of: viewModel.selectedGameSystemId) { _, newValue in
                                viewModel.selectGameSystem(newValue)
                            }
                            .accessibilityIdentifier("rules.gameSystemPicker")
                        }
                    }

                    Section {
                        Picker(String(localized: "Category"), selection: $viewModel.selectedCategory) {
                            Text(String(localized: "All")).tag(RuleSectionCategory?.none)
                            ForEach(RuleSectionCategory.allCases, id: \.self) { category in
                                Text(categoryLabel(category)).tag(Optional(category))
                            }
                        }
                        .accessibilityHint(String(localized: "Filters rule sections by category"))
                        .accessibilityIdentifier("rules.categoryPicker")
                    }

                    Section(String(localized: "Sections")) {
                        if viewModel.filteredSections.isEmpty {
                            Text(String(localized: "No matching sections"))
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(viewModel.filteredSections) { section in
                                NavigationLink {
                                    RuleSectionDetailView(section: section, allSections: viewModel.sections)
                                } label: {
                                    RuleSectionRow(
                                        title: section.title,
                                        category: section.category,
                                        accessibilityId: "rules.section.\(section.id)"
                                    )
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .searchable(text: $viewModel.searchText, prompt: String(localized: "Search rules"))
                .accessibilityIdentifier("rules.sectionList")
            }
        }
        .navigationTitle(String(localized: "Rules"))
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
    }

    private func categoryLabel(_ category: RuleSectionCategory) -> String {
        switch category {
        case .core: String(localized: "Core")
        case .spearhead: String(localized: "Spearhead")
        case .glossary: String(localized: "Glossary")
        }
    }

    private func gameSystemPickerLabel(_ system: GameSystem) -> String {
        if system.id == "wh40k-11e" {
            return String(localized: "Warhammer 40,000 — 11th Edition")
        }
        return system.name
    }
}

struct RuleSectionDetailView: View {
    let section: RuleSection
    let allSections: [RuleSection]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                Text(section.content)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("rules.sectionContent.\(section.id)")

                if !relatedSections.isEmpty {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                        Text(String(localized: "Related"))
                            .font(.headline)
                        ForEach(relatedSections) { related in
                            NavigationLink {
                                RuleSectionDetailView(section: related, allSections: allSections)
                            } label: {
                                Label(related.title, systemImage: "doc.text")
                                    .font(.callout)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .frame(minHeight: DesignTokens.minTouchTarget)
                            }
                            .accessibilityLabel(related.title)
                            .accessibilityHint(String(localized: "Opens related rule section"))
                            .accessibilityIdentifier("rules.related.\(related.id)")
                        }
                    }
                }
            }
            .padding(DesignTokens.Spacing.md)
            .readableContentWidth()
        }
        .navigationTitle(section.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var relatedSections: [RuleSection] {
        section.relatedSectionIds.compactMap { id in
            allSections.first { $0.id == id }
        }
    }
}
