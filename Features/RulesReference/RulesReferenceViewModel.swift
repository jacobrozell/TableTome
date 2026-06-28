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

    var showsGameSystemPicker: Bool {
        gameSystems.count > 1
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
