import SwiftUI
import TabletomeDomain
import TabletomeData

@MainActor
final class AppDependencies: ObservableObject {
    let rulesRepository: any RulesRepository
    let spearheadCatalogRepository: any SpearheadCatalogRepository

    init(
        rulesRepository: any RulesRepository = BundledRulesRepository(),
        spearheadCatalogRepository: any SpearheadCatalogRepository = BundledSpearheadCatalogRepository()
    ) {
        self.rulesRepository = rulesRepository
        self.spearheadCatalogRepository = spearheadCatalogRepository
    }

    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(rulesRepository: rulesRepository)
    }

    func makeRulesReferenceViewModel() -> RulesReferenceViewModel {
        RulesReferenceViewModel(rulesRepository: rulesRepository)
    }

    func makeAppSearchViewModel() -> AppSearchViewModel {
        AppSearchViewModel(
            rulesRepository: rulesRepository,
            catalogRepository: spearheadCatalogRepository
        )
    }

    func makeGuidedMatchViewModel() -> GuidedMatchViewModel {
        GuidedMatchViewModel(catalogRepository: spearheadCatalogRepository)
    }
}
