import Foundation
import TabletomeDomain

@MainActor
final class MatchHistoryViewModel: ObservableObject {
    @Published private(set) var records: [MatchRecord] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var householdProfiles: [PlayerProfile] = []

    @Published var filterGameSystemId: String? {
        didSet { Task { await load() } }
    }

    @Published var filterProfileId: UUID? {
        didSet { Task { await load() } }
    }

    private let historyRepository: any MatchHistoryRepository
    private let rulesRepository: any RulesRepository
    private let profileStore: PlayerProfileStore?
    private let logger: any AppLogger

    init(
        historyRepository: any MatchHistoryRepository,
        rulesRepository: any RulesRepository,
        profileStore: PlayerProfileStore? = nil,
        logger: any AppLogger = DefaultAppLogger.makeForCurrentBuild()
    ) {
        self.historyRepository = historyRepository
        self.rulesRepository = rulesRepository
        self.profileStore = profileStore
        self.logger = logger
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            if ReleaseSurface.showsPlayersHub, let profileStore {
                let household = try await profileStore.loadHousehold()
                householdProfiles = household.sortedProfiles
            } else {
                householdProfiles = []
            }

            var loaded = try await historyRepository.fetchRecords(
                limit: nil,
                gameSystemId: filterGameSystemId,
                involvingProfileId: nil
            )

            if let filterProfileId,
               let profile = householdProfiles.first(where: { $0.id == filterProfileId }) {
                loaded = PlayerMatchStatsCalculator.records(involving: profile, from: loaded)
            }

            records = loaded
            errorMessage = nil
            var metadata: [String: String] = [
                "recordCount": String(records.count)
            ]
            if let filterGameSystemId {
                metadata["filterGameSystemId"] = filterGameSystemId
            }
            if let filterProfileId {
                metadata["filterProfileId"] = filterProfileId.uuidString
            }
            logger.info(
                .persistence,
                eventName: "match_history_loaded",
                message: "Match history loaded.",
                metadata: metadata
            )
        } catch let error as MatchHistoryRepositoryError {
            errorMessage = String(localized: "Match history could not be loaded.")
            logger.error(
                .persistence,
                eventName: "match_history_load_failed",
                message: "Match history load failed.",
                metadata: [
                    "errorCode": TabletomeAnalytics.errorCode(for: error),
                    "filterGameSystemId": filterGameSystemId ?? "all"
                ]
            )
        } catch {
            errorMessage = String(localized: "Match history could not be loaded.")
            logger.error(
                .persistence,
                eventName: "match_history_load_failed",
                message: "Match history load failed.",
                metadata: ["errorCode": "unknown"]
            )
        }
    }

    func delete(record: MatchRecord) async {
        do {
            try await historyRepository.deleteRecord(id: record.id)
            logger.info(
                .persistence,
                eventName: "match_history_deleted",
                message: "Match history record deleted.",
                metadata: [
                    "gameSystemId": record.gameSystemId,
                    "status": record.status.rawValue
                ]
            )
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
