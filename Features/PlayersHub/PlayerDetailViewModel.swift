import Foundation
import TabletomeDomain
import TabletomeData

@MainActor
final class PlayerDetailViewModel: ObservableObject {
    @Published private(set) var profile: PlayerProfile?
    @Published private(set) var stats = PlayerMatchStats()
    @Published private(set) var matchRecords: [MatchRecord] = []
    @Published private(set) var catalog: SpearheadCatalog?
    @Published private(set) var boxSets: [BoxSet] = []
    @Published private(set) var household: HouseholdPlayersState?
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
            self.household = household
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

    func setExperienceLevel(_ level: PlayerExperienceLevel) async {
        guard var profile else { return }
        profile.guidedMatchPreferences.experienceLevel = level
        await saveProfile(profile)
    }

    func setDefaultDiceInputMode(_ rawValue: String?) async {
        guard var profile else { return }
        profile.guidedMatchPreferences.defaultDiceInputMode = rawValue
        await saveProfile(profile)
    }

    func setDefaultRegimentAbility(armyId: String, abilityId: String) async {
        guard var profile else { return }
        profile.guidedMatchPreferences.defaultRegimentAbilityByArmyId[armyId] = abilityId
        await saveProfile(profile)
    }

    func setDefaultEnhancement(armyId: String, enhancementId: String) async {
        guard var profile else { return }
        profile.guidedMatchPreferences.defaultEnhancementByArmyId[armyId] = enhancementId
        await saveProfile(profile)
    }

    func setPreferredArmy(opponentArmyId: String, armyId: String) async {
        guard var profile else { return }
        profile.guidedMatchPreferences.preferredArmyIdByOpponentArmyId[opponentArmyId] = armyId
        await saveProfile(profile)
    }

    func opponentArmyOptions(catalog: SpearheadCatalog, household: HouseholdPlayersState) -> [SpearheadArmy] {
        let ownedByOthers = Set(
            household.sortedProfiles
                .filter { $0.id != profileId }
                .flatMap(\.ownedSpearheadArmyIds)
        )
        let savedOpponents = Set(profile?.guidedMatchPreferences.preferredArmyIdByOpponentArmyId.keys.map { $0 } ?? [])
        let opponentIds = ownedByOthers.union(savedOpponents)
        return catalog.factions
            .flatMap(\.armies)
            .filter { opponentIds.contains($0.id) }
            .sorted { $0.name < $1.name }
    }

    func orphanedOwnedArmyIds(catalog: SpearheadCatalog?) -> [String] {
        guard let catalog, let profile else { return [] }
        let catalogIds = Set(catalog.factions.flatMap(\.armies).map(\.id))
        return profile.ownedSpearheadArmyIds
            .subtracting(catalogIds)
            .sorted()
    }

    func resetCoachingTips() async {
        do {
            try await profileStore.resetCoachingTips(profileId: profileId)
            await load()
        } catch {
            errorMessage = String(localized: "Could not reset coaching tips.")
        }
    }

    func deleteProfile() async -> Bool {
        do {
            try await profileStore.deleteProfile(id: profileId)
            return true
        } catch PlayerProfileRepositoryError.cannotDeleteLastProfile {
            errorMessage = String(localized: "Keep at least one player on this device.")
            return false
        } catch {
            errorMessage = String(localized: "Could not delete player.")
            return false
        }
    }

    private func saveProfile(_ profile: PlayerProfile) async {
        do {
            try await profileStore.updateProfile(profile)
            await load()
        } catch {
            errorMessage = String(localized: "Could not save preferences.")
        }
    }
}
