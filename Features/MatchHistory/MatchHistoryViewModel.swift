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

    /// Newest first: "This Month", "Last Month", then "Month Year".
    var sections: [(title: String, records: [MatchRecord])] {
        Self.sections(from: records)
    }

    static func sections(
        from records: [MatchRecord],
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> [(title: String, records: [MatchRecord])] {
        let sorted = records.sorted { $0.endedAt > $1.endedAt }
        var titles: [String] = []
        var grouped: [String: [MatchRecord]] = [:]
        for record in sorted {
            let title = sectionTitle(for: record.endedAt, now: now, calendar: calendar)
            if grouped[title] == nil {
                titles.append(title)
                grouped[title] = []
            }
            grouped[title]?.append(record)
        }
        return titles.map { (title: $0, records: grouped[$0] ?? []) }
    }

    private static func sectionTitle(for date: Date, now: Date, calendar: Calendar) -> String {
        let month = calendar.dateComponents([.year, .month], from: date)
        let thisMonth = calendar.dateComponents([.year, .month], from: now)
        if month.year == thisMonth.year, month.month == thisMonth.month {
            return String(localized: "This Month")
        }
        let thisStart = calendar.date(from: thisMonth) ?? now
        if let lastStart = calendar.date(byAdding: .month, value: -1, to: thisStart) {
            let lastMonth = calendar.dateComponents([.year, .month], from: lastStart)
            if month.year == lastMonth.year, month.month == lastMonth.month {
                return String(localized: "Last Month")
            }
        }
        return date.formatted(.dateTime.month(.wide).year())
    }
}
