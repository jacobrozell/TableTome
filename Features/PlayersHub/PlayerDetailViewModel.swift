import Foundation
import TabletomeDomain

@MainActor
final class PlayerDetailViewModel: ObservableObject {
    @Published private(set) var profile: PlayerProfile?
    @Published private(set) var stats = PlayerMatchStats()
    @Published private(set) var matchRecords: [MatchRecord] = []
    @Published private(set) var catalog: SpearheadCatalog?
    @Published private(set) var boxSets: [BoxSet] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    let profileId: UUID
    private let profileStore: PlayerProfileStore
    private let matchHistoryRepository: any MatchHistoryRepository
    private let catalogRepository: any SpearheadCatalogRepository
    private let logger: any AppLogger

    init(
        profileId: UUID,
        profileStore: PlayerProfileStore,
        matchHistoryRepository: any MatchHistoryRepository,
        catalogRepository: any SpearheadCatalogRepository,
        logger: any AppLogger
    ) {
        self.profileId = profileId
        self.profileStore = profileStore
        self.matchHistoryRepository = matchHistoryRepository
        self.catalogRepository = catalogRepository
        self.logger = logger
    }

    var isPrimary: Bool {
        profile?.id != nil // set from household in load
    }

    private var householdPrimaryId: UUID?

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let household = try await profileStore.loadHousehold()
            householdPrimaryId = household.defaultPlayerOneProfileId
            profile = household.profile(id: profileId)
            guard let profile else {
                errorMessage = String(localized: "Player not found.")
                return
            }
            catalog = try await catalogRepository.loadCatalog()
            boxSets = BoxSetCatalogLoader.load(for: .aosSpearhead)?.boxSets ?? []
            let allRecords = try await matchHistoryRepository.fetchRecords(limit: nil, gameSystemId: nil)
            matchRecords = PlayerMatchStatsCalculator.records(involving: profile, from: allRecords)
            stats = PlayerMatchStatsCalculator.stats(for: profile, records: allRecords)
            errorMessage = nil
        } catch {
            errorMessage = String(localized: "Could not load player.")
        }
    }

    func isPrimaryPlayer() -> Bool {
        guard let profile, let householdPrimaryId else { return false }
        return profile.id == householdPrimaryId
    }

    func updateDisplayName(_ name: String) async {
        guard var profile else { return }
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        profile.displayName = trimmed
        do {
            try await profileStore.updateProfile(profile)
            await load()
        } catch {
            errorMessage = String(localized: "Could not save name.")
        }
    }

    func setAccentColor(_ name: String) async {
        guard var profile else { return }
        profile.accentColorName = name
        do {
            try await profileStore.updateProfile(profile)
            await load()
        } catch {
            errorMessage = String(localized: "Could not save color.")
        }
    }

    func setPrimary() async {
        do {
            try await profileStore.setPrimaryProfile(id: profileId)
            await load()
        } catch {
            errorMessage = String(localized: "Could not set as primary player.")
        }
    }

    func toggleOwnedArmy(_ armyId: String) async {
        do {
            let isOwned = try await profileStore.toggleOwnedArmy(profileId: profileId, armyId: armyId)
            logger.info(
                .ui,
                eventName: "owned_army_toggled",
                message: "Owned army toggled.",
                metadata: ["isOwned": isOwned ? "true" : "false"]
            )
            await load()
        } catch {
            errorMessage = String(localized: "Could not update owned armies.")
        }
    }

    func linkStarterBox(_ box: BoxSet) async {
        let armyIds = box.armyIds ?? [box.playerOne.armyId, box.playerTwo.armyId]
        do {
            try await profileStore.linkStarterBox(
                profileId: profileId,
                boxId: box.id,
                armyIds: armyIds
            )
            await load()
        } catch {
            errorMessage = String(localized: "Could not link starter box.")
        }
    }

    func ownedArmyIds() -> Set<String> {
        guard let profile else { return [] }
        return OwnedArmyResolver.ownedArmyIds(for: profile)
    }
}
