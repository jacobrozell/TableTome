import SwiftUI
import TabletomeDomain

/// Offline rules browser scoped to a single game system (from the game guide).
struct GameSystemRulesReferenceView: View {
    let gameSystem: GameSystem
    @State private var searchText = ""
    @State private var selectedCategory: RuleSectionCategory?

    private var filteredSections: [RuleSection] {
        gameSystem.ruleSections
            .filter { section in
                guard let selectedCategory else { return true }
                return section.category == selectedCategory
            }
            .filter { section in
                guard !searchText.isEmpty else { return true }
                let query = searchText.lowercased()
                return section.title.lowercased().contains(query)
                    || section.content.lowercased().contains(query)
            }
            .sorted { $0.order < $1.order }
    }

    var body: some View {
        List {
            Section {
                Picker(String(localized: "Category"), selection: $selectedCategory) {
                    Text(String(localized: "All")).tag(RuleSectionCategory?.none)
                    ForEach(RuleSectionCategory.allCases, id: \.self) { category in
                        Text(categoryLabel(category)).tag(Optional(category))
                    }
                }
                .accessibilityIdentifier("guide.rules.categoryPicker.\(gameSystem.id)")
            }

            Section(String(localized: "Sections")) {
                if filteredSections.isEmpty {
                    Text(String(localized: "No matching sections"))
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(filteredSections) { section in
                        NavigationLink {
                            RuleSectionDetailView(section: section, allSections: gameSystem.ruleSections)
                        } label: {
                            RuleSectionRow(
                                title: section.title,
                                category: section.category,
                                accessibilityId: "guide.rules.section.\(section.id)"
                            )
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .searchable(text: $searchText, prompt: String(localized: "Search rules"))
        .navigationTitle(String(localized: "Rules Reference"))
        .accessibilityIdentifier("guide.rulesList.\(gameSystem.id)")
    }

    private func categoryLabel(_ category: RuleSectionCategory) -> String {
        switch category {
        case .core: String(localized: "Core")
        case .spearhead: String(localized: "Spearhead")
        case .glossary: String(localized: "Glossary")
        }
    }
}
