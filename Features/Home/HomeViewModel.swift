import Foundation
import TabletomeDomain

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var gameSystems: [GameSystem] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let rulesRepository: any RulesRepository
    private let logger: any AppLogger

    init(rulesRepository: any RulesRepository, logger: any AppLogger = DefaultAppLogger.makeForCurrentBuild()) {
        self.rulesRepository = rulesRepository
        self.logger = logger
    }

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let all = try await rulesRepository.availableGameSystems()
            gameSystems = all.filter { ReleaseSurface.isGameSystemVisible($0) }
        } catch let error as RulesRepositoryError {
            errorMessage = String(localized: "Could not load game guides. Check bundled data and try again.")
            TabletomeAnalytics.logRulesLoadFailed(
                logger: logger,
                layer: "home",
                error: error
            )
        } catch {
            errorMessage = String(localized: "Could not load game guides. Check bundled data and try again.")
            logger.error(
                .catalog,
                eventName: "rules_load_failed",
                message: "Unexpected rules load failure.",
                metadata: ["layer": "home", "errorCode": "unknown"]
            )
        }
    }
}
