import SwiftUI
import SpearheadDomain
import SpearheadData

@MainActor
final class AppDependencies: ObservableObject {
    let rulesRepository: any RulesRepository

    init(rulesRepository: any RulesRepository = BundledRulesRepository()) {
        self.rulesRepository = rulesRepository
    }

    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(rulesRepository: rulesRepository)
    }

    func makeRulesReferenceViewModel() -> RulesReferenceViewModel {
        RulesReferenceViewModel(rulesRepository: rulesRepository)
    }
}
