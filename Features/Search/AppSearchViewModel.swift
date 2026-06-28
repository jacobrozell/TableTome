import Foundation
import TabletomeDomain

@MainActor
final class AppSearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var selectedGameSystemId: String
    @Published private(set) var gameSystems: [GameSystem] = []
    @Published private(set) var index: [AppSearchResult] = []
    @Published private(set) var ruleSections: [RuleSection] = []
    @Published private(set) var gettingStartedSteps: [GuideStep] = []
    @Published private(set) var editionMigrationSteps: [GuideStep] = []
    @Published private(set) var armies: [SpearheadArmy] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let rulesRepository: any RulesRepository
    private let catalogRepository: (String) -> any SpearheadCatalogRepository
    private let visibleGameSystemFilter: (GameSystem) -> Bool

    init(
        rulesRepository: any RulesRepository,
        catalogRepository: @escaping (String) -> any SpearheadCatalogRepository,
        gameSystemId: String = GameSystemRulesLabels.defaultGameSystemId,
        visibleGameSystemFilter: @escaping (GameSystem) -> Bool = { _ in true }
    ) {
        self.rulesRepository = rulesRepository
        self.catalogRepository = catalogRepository
        self.selectedGameSystemId = gameSystemId
        self.visibleGameSystemFilter = visibleGameSystemFilter
    }

    var scopedGameSystemId: String { selectedGameSystemId }

    var showsGameSystemPicker: Bool {
        gameSystems.count > 1
    }

    var searchResults: [AppSearchResult] {
        AppSearchEngine.search(query: searchText, in: index)
    }

    var groupedSearchResults: [(kind: AppSearchResultKind, results: [AppSearchResult])] {
        let results = searchResults
        return AppSearchResultKind.visibleKinds(for: selectedGameSystemId).compactMap { kind in
            let matches = results.filter { $0.kind == kind }
            guard !matches.isEmpty else { return nil }
            return (kind, matches)
        }
    }

    var isShowingSearchResults: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func selectGameSystem(_ id: String) {
        guard id != selectedGameSystemId else { return }
        selectedGameSystemId = id
        searchText = ""
        Task { await load() }
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            if gameSystems.isEmpty {
                let all = try await rulesRepository.availableGameSystems()
                gameSystems = all.filter(visibleGameSystemFilter)
                if !gameSystems.contains(where: { $0.id == selectedGameSystemId }),
                   let first = gameSystems.first {
                    selectedGameSystemId = first.id
                }
            }

            let gameSystem = try await rulesRepository.gameSystem(id: selectedGameSystemId)
            ruleSections = gameSystem.ruleSections
            gettingStartedSteps = gameSystem.gettingStartedSteps
            editionMigrationSteps = gameSystem.editionMigrationSteps

            let catalog = try await catalogRepository(selectedGameSystemId).loadCatalog()
            armies = catalog.factions.flatMap(\.armies)
            index = AppSearchIndexBuilder.build(gameSystem: gameSystem, catalog: catalog)
        } catch {
            armies = []
            index = []
            errorMessage = String(localized: "Search could not be loaded.")
        }
    }
}
