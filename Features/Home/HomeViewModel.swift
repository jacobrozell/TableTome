import Foundation
import SpearheadDomain

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var gameSystems: [GameSystem] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let rulesRepository: any RulesRepository

    init(rulesRepository: any RulesRepository) {
        self.rulesRepository = rulesRepository
    }

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let all = try await rulesRepository.availableGameSystems()
            gameSystems = all.filter { ReleaseSurface.isGameSystemVisible($0) }
        } catch {
            errorMessage = String(localized: "Could not load game guides. Check bundled data and try again.")
        }
    }
}
