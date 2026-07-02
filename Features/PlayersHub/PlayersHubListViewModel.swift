import Foundation
import TabletomeDomain

@MainActor
final class PlayersHubListViewModel: ObservableObject {
    @Published private(set) var household: HouseholdPlayersState?
    @Published private(set) var statsByProfileId: [UUID: PlayerMatchStats] = [:]
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let profileStore: PlayerProfileStore
    private let matchHistoryRepository: any MatchHistoryRepository
    private let logger: any AppLogger

    init(
        profileStore: PlayerProfileStore,
        matchHistoryRepository: any MatchHistoryRepository,
        logger: any AppLogger
    ) {
        self.profileStore = profileStore
        self.matchHistoryRepository = matchHistoryRepository
        self.logger = logger
    }

    var profiles: [PlayerProfile] {
        household?.sortedProfiles ?? []
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let household = try await profileStore.loadHousehold()
            self.household = household
            let records = try await matchHistoryRepository.fetchRecords(limit: nil, gameSystemId: nil)
            var stats: [UUID: PlayerMatchStats] = [:]
            for profile in household.sortedProfiles {
                stats[profile.id] = PlayerMatchStatsCalculator.stats(for: profile, records: records)
            }
            statsByProfileId = stats
            errorMessage = nil
            logger.info(
                .ui,
                eventName: "players_hub_opened",
                message: "Players hub loaded.",
                metadata: ["profileCount": String(household.profiles.count)]
            )
        } catch {
            errorMessage = String(localized: "Players could not be loaded.")
        }
    }

    func createProfile(name: String) async {
        do {
            _ = try await profileStore.createProfile(displayName: name)
            await load()
            logger.info(.ui, eventName: "player_profile_created", message: "Player profile created.", metadata: [:])
        } catch {
            errorMessage = String(localized: "Could not add player.")
        }
    }

    func deleteProfile(id: UUID) async -> Bool {
        do {
            try await profileStore.deleteProfile(id: id)
            await load()
            return true
        } catch PlayerProfileRepositoryError.cannotDeleteLastProfile {
            errorMessage = String(localized: "Keep at least one player on this device.")
            return false
        } catch {
            errorMessage = String(localized: "Could not delete player.")
            return false
        }
    }

    func setPrimaryProfile(id: UUID) async {
        do {
            try await profileStore.setPrimaryProfile(id: id)
            await load()
        } catch {
            errorMessage = String(localized: "Could not update primary player.")
        }
    }

    func stats(for profileId: UUID) -> PlayerMatchStats {
        statsByProfileId[profileId] ?? PlayerMatchStats()
    }

    func isPrimary(_ profile: PlayerProfile) -> Bool {
        household?.defaultPlayerOneProfileId == profile.id
    }
}
