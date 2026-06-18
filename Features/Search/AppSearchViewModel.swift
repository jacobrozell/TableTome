import Foundation
import TabletomeDomain

@MainActor
final class AppSearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published private(set) var index: [AppSearchResult] = []
    @Published private(set) var ruleSections: [RuleSection] = []
    @Published private(set) var gettingStartedSteps: [GuideStep] = []
    @Published private(set) var armies: [SpearheadArmy] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let rulesRepository: any RulesRepository
    private let catalogRepository: any SpearheadCatalogRepository
    private let gameSystemId: String

    init(
        rulesRepository: any RulesRepository,
        catalogRepository: any SpearheadCatalogRepository,
        gameSystemId: String = "aos-spearhead"
    ) {
        self.rulesRepository = rulesRepository
        self.catalogRepository = catalogRepository
        self.gameSystemId = gameSystemId
    }

    var searchResults: [AppSearchResult] {
        AppSearchEngine.search(query: searchText, in: index)
    }

    var groupedSearchResults: [(kind: AppSearchResultKind, results: [AppSearchResult])] {
        let results = searchResults
        return AppSearchResultKind.allCases.compactMap { kind in
            let matches = results.filter { $0.kind == kind }
            guard !matches.isEmpty else { return nil }
            return (kind, matches)
        }
    }

    var isShowingSearchResults: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let gameSystem = try await rulesRepository.gameSystem(id: gameSystemId)
            ruleSections = gameSystem.ruleSections
            gettingStartedSteps = gameSystem.gettingStartedSteps

            var catalog: SpearheadCatalog?
            if gameSystemId == "aos-spearhead" {
                catalog = try await catalogRepository.loadCatalog()
                armies = catalog?.factions.flatMap(\.armies) ?? []
            }

            index = AppSearchIndexBuilder.build(gameSystem: gameSystem, catalog: catalog)
        } catch {
            errorMessage = String(localized: "Search could not be loaded.")
        }
    }
}
