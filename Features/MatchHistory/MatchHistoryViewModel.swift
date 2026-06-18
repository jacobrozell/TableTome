import Foundation
import TabletomeDomain

@MainActor
final class MatchHistoryViewModel: ObservableObject {
    @Published private(set) var records: [MatchRecord] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published var filterGameSystemId: String? {
        didSet { Task { await load() } }
    }

    private let historyRepository: any MatchHistoryRepository
    private let rulesRepository: any RulesRepository

    init(
        historyRepository: any MatchHistoryRepository,
        rulesRepository: any RulesRepository
    ) {
        self.historyRepository = historyRepository
        self.rulesRepository = rulesRepository
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            records = try await historyRepository.fetchRecords(limit: nil, gameSystemId: filterGameSystemId)
            errorMessage = nil
        } catch {
            errorMessage = String(localized: "Match history could not be loaded.")
        }
    }

    func delete(record: MatchRecord) async {
        do {
            try await historyRepository.deleteRecord(id: record.id)
            await load()
        } catch {
            errorMessage = String(localized: "Could not delete this match.")
        }
    }

    func record(id: UUID) async -> MatchRecord? {
        if let cached = records.first(where: { $0.id == id }) {
            return cached
        }
        return try? await historyRepository.fetchRecord(id: id)
    }

    func log(matchId: UUID) async -> [MatchLogEvent] {
        (try? await historyRepository.fetchLog(matchId: matchId)) ?? []
    }

    func availableFilters() async -> [(id: String?, label: String)] {
        var filters: [(String?, String)] = [(nil, String(localized: "All"))]
        if let systems = try? await rulesRepository.availableGameSystems() {
            for system in systems where ReleaseSurface.isGameSystemVisible(system) {
                filters.append((system.id, GameSystemRulesLabels.tabTitle(gameSystemId: system.id)))
            }
        }
        return filters
    }
}
