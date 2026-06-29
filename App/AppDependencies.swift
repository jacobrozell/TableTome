import SwiftUI
import TabletomeDomain
import TabletomeData
import TabletomeHobbyData

@MainActor
final class AppDependencies: ObservableObject {
    let logger: any AppLogger
    let rulesRepository: any RulesRepository
    let gameSystemRegistry: GameSystemRegistry
    let playCatalogRepository: any PlayCatalogRepository
    let matchHistoryRepository: any MatchHistoryRepository

    init(
        logger: any AppLogger = DefaultAppLogger.makeForCurrentBuild(),
        rulesRepository: any RulesRepository = BundledRulesRepository(),
        gameSystemRegistry: GameSystemRegistry = .bundled(withBoxSetsFrom: .main),
        playCatalogRepository: (any PlayCatalogRepository)? = nil,
        matchHistoryRepository: any MatchHistoryRepository = JSONMatchHistoryRepository()
    ) {
        self.logger = logger
        TabletomeAnalytics.register(logger)
        HobbyAppContainer.openFailureHandler = { operation, errorDescription in
            logger.error(
                .persistence,
                eventName: "hobby_container_open_failed",
                message: "Hobby SwiftData container open failed.",
                metadata: [
                    "operation": operation,
                    "errorCode": String(errorDescription.prefix(100)),
                    "schemaVersion": String(HobbySchemaPolicy.version)
                ]
            )
        }
        GameSystemRegistry.installBundled(gameSystemRegistry)
        self.rulesRepository = rulesRepository
        self.gameSystemRegistry = gameSystemRegistry
        self.playCatalogRepository = playCatalogRepository
            ?? BundledPlayCatalogRepository(registry: gameSystemRegistry)
        self.matchHistoryRepository = matchHistoryRepository
    }

    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(rulesRepository: rulesRepository, logger: logger)
    }

    func makeRulesReferenceViewModel(
        gameSystemId: GameSystemId? = nil,
        activeGameSystemId: String = ActiveGameContextPersistence.gameSystemId
    ) -> RulesReferenceViewModel {
        let resolvedId = gameSystemId?.rawValue ?? activeGameSystemId
        return RulesReferenceViewModel(rulesRepository: rulesRepository, gameSystemId: resolvedId)
    }

    func catalogRepository(for gameSystemId: GameSystemId) -> any SpearheadCatalogRepository {
        GameSystemCatalogRepository(
            gameSystemId: gameSystemId.rawValue,
            repository: playCatalogRepository
        )
    }

    func makeAppSearchViewModel(
        gameSystemId: String? = nil,
        activeGameSystemId: String = ActiveGameContextPersistence.gameSystemId
    ) -> AppSearchViewModel {
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
            gameSystemId: gameSystemId ?? activeGameSystemId,
            visibleGameSystemFilter: { ReleaseSurface.isGameSystemVisible($0, registry: self.gameSystemRegistry) }
        )
    }

    func makeGuidedMatchViewModel(gameSystemId: GameSystemId = .default) -> GuidedMatchViewModel {
        GuidedMatchViewModel(
            gameSystemId: gameSystemId,
            catalogRepository: catalogRepository(for: gameSystemId),
            logger: logger
        )
    }

    func makeMatchHistoryViewModel() -> MatchHistoryViewModel {
        MatchHistoryViewModel(
            historyRepository: matchHistoryRepository,
            rulesRepository: rulesRepository,
            logger: logger
        )
    }
}
