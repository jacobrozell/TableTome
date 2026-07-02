import Foundation

public enum PlayerExperienceLevel: String, Codable, Sendable {
    case beginner
    case tableRegular
}

public struct GuidedMatchPlayerPreferences: Codable, Sendable, Equatable {
    public var experienceLevel: PlayerExperienceLevel
    public var defaultDiceInputMode: String?
    public var preferredArmyIdByOpponentArmyId: [String: String]
    public var defaultRegimentAbilityByArmyId: [String: String]
    public var defaultEnhancementByArmyId: [String: String]
    public var showExpandedSetupSteps: Bool?
    public var dismissedCoachTipKeys: Set<String>

    public init(
        experienceLevel: PlayerExperienceLevel = .beginner,
        defaultDiceInputMode: String? = nil,
        preferredArmyIdByOpponentArmyId: [String: String] = [:],
        defaultRegimentAbilityByArmyId: [String: String] = [:],
        defaultEnhancementByArmyId: [String: String] = [:],
        showExpandedSetupSteps: Bool? = nil,
        dismissedCoachTipKeys: Set<String> = []
    ) {
        self.experienceLevel = experienceLevel
        self.defaultDiceInputMode = defaultDiceInputMode
        self.preferredArmyIdByOpponentArmyId = preferredArmyIdByOpponentArmyId
        self.defaultRegimentAbilityByArmyId = defaultRegimentAbilityByArmyId
        self.defaultEnhancementByArmyId = defaultEnhancementByArmyId
        self.showExpandedSetupSteps = showExpandedSetupSteps
        self.dismissedCoachTipKeys = dismissedCoachTipKeys
    }
}

public struct PlayerProfile: Codable, Sendable, Identifiable, Equatable {
    public let id: UUID
    public var displayName: String
    public var sortOrder: Int
    public var accentColorName: String?
    public var ownedSpearheadArmyIds: Set<String>
    public var linkedStarterBoxIds: Set<String>
    public var guidedMatchPreferences: GuidedMatchPlayerPreferences
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        displayName: String,
        sortOrder: Int,
        accentColorName: String? = nil,
        ownedSpearheadArmyIds: Set<String> = [],
        linkedStarterBoxIds: Set<String> = [],
        guidedMatchPreferences: GuidedMatchPlayerPreferences = GuidedMatchPlayerPreferences(),
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.displayName = displayName
        self.sortOrder = sortOrder
        self.accentColorName = accentColorName
        self.ownedSpearheadArmyIds = ownedSpearheadArmyIds
        self.linkedStarterBoxIds = linkedStarterBoxIds
        self.guidedMatchPreferences = guidedMatchPreferences
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public struct HouseholdPlayersState: Codable, Sendable, Equatable {
    public static let currentSchemaVersion = 1

    public var schemaVersion: Int
    public var profiles: [PlayerProfile]
    /// Profile used as default Player 1 — “This is me” on this device.
    public var defaultPlayerOneProfileId: UUID?

    public init(
        schemaVersion: Int = HouseholdPlayersState.currentSchemaVersion,
        profiles: [PlayerProfile] = [],
        defaultPlayerOneProfileId: UUID? = nil
    ) {
        self.schemaVersion = schemaVersion
        self.profiles = profiles
        self.defaultPlayerOneProfileId = defaultPlayerOneProfileId
    }

    public var sortedProfiles: [PlayerProfile] {
        profiles.sorted { lhs, rhs in
            if lhs.sortOrder != rhs.sortOrder { return lhs.sortOrder < rhs.sortOrder }
            return lhs.displayName.localizedCaseInsensitiveCompare(rhs.displayName) == .orderedAscending
        }
    }

    public func profile(id: UUID) -> PlayerProfile? {
        profiles.first { $0.id == id }
    }

    public var primaryProfile: PlayerProfile? {
        guard let defaultPlayerOneProfileId else { return nil }
        return profile(id: defaultPlayerOneProfileId)
    }
}

public enum PlayerProfileSeed {
    public static func makeDefaultHousehold(now: Date = Date()) -> HouseholdPlayersState {
        let jacob = PlayerProfile(
            displayName: "Jacob",
            sortOrder: 0,
            accentColorName: "blue",
            createdAt: now,
            updatedAt: now
        )
        let chris = PlayerProfile(
            displayName: "Chris",
            sortOrder: 1,
            accentColorName: "orange",
            createdAt: now,
            updatedAt: now
        )
        return HouseholdPlayersState(
            profiles: [jacob, chris],
            defaultPlayerOneProfileId: jacob.id
        )
    }
}
