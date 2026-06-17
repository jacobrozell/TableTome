import SwiftUI
import TabletomeDomain

struct RulesReferenceView: View {
    @StateObject private var viewModel: RulesReferenceViewModel

    init(viewModel: RulesReferenceViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Group {
            if let error = viewModel.errorMessage {
                EmptyStateView(
                    title: String(localized: "Unable to Load"),
                    message: error,
                    actionTitle: String(localized: "Retry"),
                    action: { Task { await viewModel.load() } }
                )
            } else {
                List {
                    Section {
                        Picker(String(localized: "Category"), selection: $viewModel.selectedCategory) {
                            Text(String(localized: "All")).tag(RuleSectionCategory?.none)
                            ForEach(RuleSectionCategory.allCases, id: \.self) { category in
                                Text(categoryLabel(category)).tag(Optional(category))
                            }
                        }
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

                if !section.relatedSectionIds.isEmpty {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                        Text(String(localized: "Related"))
                            .font(.headline)
                        ForEach(relatedSections) { related in
                            Text("• \(related.title)")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .padding(DesignTokens.Spacing.md)
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
