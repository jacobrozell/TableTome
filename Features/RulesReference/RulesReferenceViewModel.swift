import Foundation
import TabletomeDomain

@MainActor
final class RulesReferenceViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var selectedCategory: RuleSectionCategory?
    @Published private(set) var sections: [RuleSection] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let rulesRepository: any RulesRepository
    private let gameSystemId: String

    init(rulesRepository: any RulesRepository, gameSystemId: String = "aos-spearhead") {
        self.rulesRepository = rulesRepository
        self.gameSystemId = gameSystemId
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
            let system = try await rulesRepository.gameSystem(id: gameSystemId)
            sections = system.ruleSections
        } catch {
            errorMessage = String(localized: "Rules reference could not be loaded.")
        }
    }
}
