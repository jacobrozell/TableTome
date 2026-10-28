import Foundation
import TabletomeDomain

@MainActor
final class RulesReferenceViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var selectedCategory: RuleSectionCategory?
    @Published var selectedGameSystemId: String
    @Published private(set) var gameSystems: [GameSystem] = []
    @Published private(set) var sections: [RuleSection] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let rulesRepository: any RulesRepository

    init(rulesRepository: any RulesRepository, gameSystemId: GameSystemId = .default) {
        self.rulesRepository = rulesRepository
        self.selectedGameSystemId = gameSystemId.rawValue
    }

    convenience init(rulesRepository: any RulesRepository, gameSystemId: String) {
        self.init(rulesRepository: rulesRepository, gameSystemId: GameSystemId(resolving: gameSystemId))
    }

    var resolvedGameSystemId: GameSystemId {
        GameSystemId(resolving: selectedGameSystemId)
    }

    /// Rules-content keys from `rules-v1.json`. Not game-system ids.
    static let quickReferenceSectionIds = [
        "combat-sequence",
        "turn-structure",
        "spearhead-scoring",
        "glossary-objective-control"
    ]

    var showsGameSystemPicker: Bool {
        gameSystems.count > 1
    }

    var quickReferenceSections: [RuleSection] {
        Self.quickReferenceSectionIds.compactMap { id in
            sections.first { $0.id == id }
        }
    }

    var showsQuickReference: Bool {
        searchText.isEmpty && selectedCategory == nil && quickReferenceSections.count >= 2
    }

    var browseGroups: [RulesBrowseGroup] {
        let filtered = filteredSections
        var categories: [RuleSectionCategory] = []
        if let selectedCategory {
            categories = [selectedCategory]
        } else {
            categories = GameSystemRulesLabels.availableCategories(gameSystemId: selectedGameSystemId)
            for section in filtered where !categories.contains(section.category) {
                categories.append(section.category)
            }
        }
        return categories.compactMap { category in
            let rows = filtered.filter { $0.category == category }
            guard !rows.isEmpty else { return nil }
            return RulesBrowseGroup(category: category, sections: rows)
        }
    }

    var filteredSections: [RuleSection] {
        sections
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

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let all = try await rulesRepository.availableGameSystems()
            gameSystems = all.filter { ReleaseSurface.isGameSystemVisible($0) }
            if !gameSystems.contains(where: { $0.id == selectedGameSystemId }),
               let first = gameSystems.first {
                selectedGameSystemId = first.id
            }
            applySections(
                from: gameSystems.first { $0.id == selectedGameSystemId },
                resetFilters: false
            )
        } catch {
            errorMessage = String(localized: "Rules reference could not be loaded.")
        }
    }

    func selectGameSystem(_ id: String) {
        guard id != selectedGameSystemId else { return }
        selectedGameSystemId = id
        if let system = gameSystems.first(where: { $0.id == id }) {
            applySections(from: system, resetFilters: true)
        }
        if let selectedCategory,
           !GameSystemRulesLabels.availableCategories(gameSystemId: id).contains(selectedCategory) {
            self.selectedCategory = nil
        }
    }

    private func applySections(from system: GameSystem?, resetFilters: Bool) {
        sections = system?.ruleSections ?? []
        guard resetFilters else { return }
        selectedCategory = nil
        searchText = ""
    }
}

struct RulesBrowseGroup: Identifiable, Equatable {
    let category: RuleSectionCategory
    let sections: [RuleSection]

    var id: RuleSectionCategory { category }
}
