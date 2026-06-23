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
                Text(
                    GameSystemRulesLabels.browseIntro(gameSystemId: gameSystem.id)
                )
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            }

            Section {
                Picker(String(localized: "Category"), selection: $selectedCategory) {
                    Text(String(localized: "All")).tag(RuleSectionCategory?.none)
                    ForEach(
                        GameSystemRulesLabels.availableCategories(gameSystemId: gameSystem.id),
                        id: \.self
                    ) { category in
                        Text(
                            GameSystemRulesLabels.categoryLabel(
                                category,
                                gameSystemId: gameSystem.id
                            )
                        )
                        .tag(Optional(category))
                    }
                }
                .accessibilityIdentifier("guide.rules.categoryPicker.\(gameSystem.id)")
            }

            Section(String(localized: "Sections")) {
                if filteredSections.isEmpty {
                    RulesBrowseEmptyState(searchText: searchText)
                } else {
                    ForEach(filteredSections) { section in
                        NavigationLink(value: RuleSectionLink(gameSystemId: gameSystem.id, sectionId: section.id)) {
                            RuleSectionRow(
                                title: section.title,
                                category: section.category,
                                gameSystemId: gameSystem.id,
                                accessibilityId: "guide.rules.section.\(section.id)"
                            )
                        }
                        .navigationLinkIndicatorVisibility(.hidden)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .tabBarScrollInset()
        .searchable(text: $searchText, prompt: GameSystemRulesLabels.rulesSearchPrompt(gameSystemId: gameSystem.id))
        .navigationTitle(GameSystemRulesLabels.rulesReferenceTitle(gameSystemId: gameSystem.id))
        .accessibilityIdentifier("guide.rulesList.\(gameSystem.id)")
    }
}
