import Foundation

public struct PlayerProfileStore: Sendable {
    private let repository: any PlayerProfileRepository

    public init(repository: any PlayerProfileRepository) {
        self.repository = repository
    }

    public func loadHousehold() async throws -> HouseholdPlayersState {
        try await repository.loadHousehold()
    }

    public func saveHousehold(_ state: HouseholdPlayersState) async throws {
        try await repository.saveHousehold(state)
    }

    public func createProfile(displayName: String) async throws -> PlayerProfile {
        var household = try await repository.loadHousehold()
        let trimmed = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw PlayerProfileRepositoryError.writeFailed
        }
        let now = Date()
        let profile = PlayerProfile(
            displayName: trimmed,
            sortOrder: household.profiles.count,
            createdAt: now,
            updatedAt: now
        )
        household.profiles.append(profile)
        if household.defaultPlayerOneProfileId == nil {
            household.defaultPlayerOneProfileId = profile.id
        }
        try await repository.saveHousehold(household)
        return profile
    }

    public func updateProfile(_ profile: PlayerProfile) async throws {
        var household = try await repository.loadHousehold()
        guard let index = household.profiles.firstIndex(where: { $0.id == profile.id }) else {
            throw PlayerProfileRepositoryError.profileNotFound
        }
        var updated = profile
        updated.updatedAt = Date()
        household.profiles[index] = updated
        try await repository.saveHousehold(household)
    }

    public func deleteProfile(id: UUID) async throws {
        var household = try await repository.loadHousehold()
        guard household.profiles.count > 1 else {
            throw PlayerProfileRepositoryError.cannotDeleteLastProfile
        }
        household.profiles.removeAll { $0.id == id }
        if household.defaultPlayerOneProfileId == id {
            household.defaultPlayerOneProfileId = household.sortedProfiles.first?.id
        }
        try await repository.saveHousehold(household)
    }

    public func setPrimaryProfile(id: UUID) async throws {
        var household = try await repository.loadHousehold()
        guard household.profiles.contains(where: { $0.id == id }) else {
            throw PlayerProfileRepositoryError.profileNotFound
        }
        household.defaultPlayerOneProfileId = id
        try await repository.saveHousehold(household)
    }

    public func toggleOwnedArmy(profileId: UUID, armyId: String) async throws -> Bool {
        var household = try await repository.loadHousehold()
        guard let index = household.profiles.firstIndex(where: { $0.id == profileId }) else {
            throw PlayerProfileRepositoryError.profileNotFound
        }
        var profile = household.profiles[index]
        let isOwned: Bool
        if profile.ownedSpearheadArmyIds.contains(armyId) {
            profile.ownedSpearheadArmyIds.remove(armyId)
            isOwned = false
        } else {
            profile.ownedSpearheadArmyIds.insert(armyId)
            isOwned = true
        }
        profile.updatedAt = Date()
        household.profiles[index] = profile
        try await repository.saveHousehold(household)
        return isOwned
    }

    public func linkStarterBox(profileId: UUID, boxId: String, armyIds: [String]) async throws {
        var household = try await repository.loadHousehold()
        guard let index = household.profiles.firstIndex(where: { $0.id == profileId }) else {
            throw PlayerProfileRepositoryError.profileNotFound
        }
        var profile = household.profiles[index]
        profile.linkedStarterBoxIds.insert(boxId)
        for armyId in armyIds {
            profile.ownedSpearheadArmyIds.insert(armyId)
        }
        profile.updatedAt = Date()
        household.profiles[index] = profile
        try await repository.saveHousehold(household)
    }
}
