import SwiftUI
import TabletomeDomain
import TabletomeData

@MainActor
final class AppDependencies: ObservableObject {
    let rulesRepository: any RulesRepository
    let gameSystemRegistry: GameSystemRegistry
    let playCatalogRepository: any PlayCatalogRepository
    let matchHistoryRepository: any MatchHistoryRepository

    init(
        rulesRepository: any RulesRepository = BundledRulesRepository(),
        gameSystemRegistry: GameSystemRegistry = .bundled(withBoxSetsFrom: .main),
        playCatalogRepository: (any PlayCatalogRepository)? = nil,
        matchHistoryRepository: any MatchHistoryRepository = JSONMatchHistoryRepository()
    ) {
        self.rulesRepository = rulesRepository
        self.gameSystemRegistry = gameSystemRegistry
        self.playCatalogRepository = playCatalogRepository
            ?? BundledPlayCatalogRepository(registry: gameSystemRegistry)
        self.matchHistoryRepository = matchHistoryRepository
    }

    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(rulesRepository: rulesRepository)
    }

    func makeRulesReferenceViewModel(gameSystemId: GameSystemId? = nil) -> RulesReferenceViewModel {
        let resolvedId = gameSystemId?.rawValue ?? ActiveGameContextStore.gameSystemId
        return RulesReferenceViewModel(rulesRepository: rulesRepository, gameSystemId: resolvedId)
    }

    func catalogRepository(for gameSystemId: GameSystemId) -> any SpearheadCatalogRepository {
        GameSystemCatalogRepository(
            gameSystemId: gameSystemId.rawValue,
            repository: playCatalogRepository
        )
    }

    func makeAppSearchViewModel(gameSystemId: String? = nil) -> AppSearchViewModel {
        AppSearchViewModel(
            rulesRepository: rulesRepository,
            catalogRepository: { [weak self] gameSystemId in
                guard let self else {
                    return GameSystemCatalogRepository(
                        gameSystemId: gameSystemId,
                        repository: BundledPlayCatalogRepository()
                    )
                }
                return self.catalogRepository(for: GameSystemId(resolving: gameSystemId))
            },
            gameSystemId: gameSystemId ?? ActiveGameContextStore.gameSystemId,
            visibleGameSystemFilter: { ReleaseSurface.isGameSystemVisible($0, registry: self.gameSystemRegistry) }
        )
    }

    func makeGuidedMatchViewModel(gameSystemId: GameSystemId = .default) -> GuidedMatchViewModel {
        GuidedMatchViewModel(
            gameSystemId: gameSystemId,
            catalogRepository: catalogRepository(for: gameSystemId)
        )
    }

    func makeMatchHistoryViewModel() -> MatchHistoryViewModel {
        MatchHistoryViewModel(
            historyRepository: matchHistoryRepository,
            rulesRepository: rulesRepository
        )
    }
}
