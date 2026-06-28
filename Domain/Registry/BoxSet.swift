import Foundation

/// Data-driven box-set definitions for a game system (Phase 4 of the
/// architecture refactor). Replaces the hardcoded `FeaturedArmiesConfig`
/// literals in `GameSystemId+Bundled.swift`: adding a box set becomes a JSON
/// row validated by `Scripts/validate_content.py`, not a Swift edit.
///
/// Loaded from `Resources/Rules/<system>-boxsets-v1.json`.
public struct BoxSetCatalog: Codable, Sendable, Equatable {
    public let schemaVersion: Int
    public let gameSystemId: String
    public let boxSets: [BoxSet]

    public init(schemaVersion: Int, gameSystemId: String, boxSets: [BoxSet]) {
        self.schemaVersion = schemaVersion
        self.gameSystemId = gameSystemId
        self.boxSets = boxSets
    }

    /// The primary featured box set (first declared) as the legacy
    /// `FeaturedArmiesConfig`, so existing call sites keep working unchanged
    /// while the data source moves to JSON.
    public var primaryFeaturedArmies: FeaturedArmiesConfig? {
        boxSets.first?.featuredArmiesConfig()
    }
}

public struct BoxSet: Codable, Sendable, Equatable, Identifiable {
    public let id: String
    public let starterMatchupTitle: String
    public let starterSetDescription: String?
    public let starterSetBadge: String?
    public let defaultMissionId: String?
    public let armyIds: [String]?
    public let playerOne: BoxSetArmySelection
    public let playerTwo: BoxSetArmySelection

    public init(
        id: String,
        starterMatchupTitle: String,
        starterSetDescription: String? = nil,
        starterSetBadge: String? = nil,
        defaultMissionId: String? = nil,
        armyIds: [String]? = nil,
        playerOne: BoxSetArmySelection,
        playerTwo: BoxSetArmySelection
    ) {
        self.id = id
        self.starterMatchupTitle = starterMatchupTitle
        self.starterSetDescription = starterSetDescription
        self.starterSetBadge = starterSetBadge
        self.defaultMissionId = defaultMissionId
        self.armyIds = armyIds
        self.playerOne = playerOne
        self.playerTwo = playerTwo
    }

    /// Bridges a JSON box set to the legacy in-memory featured-armies type.
    public func featuredArmiesConfig() -> FeaturedArmiesConfig {
        FeaturedArmiesConfig(
            armyIds: Set(armyIds ?? [playerOne.armyId, playerTwo.armyId]),
            starterMatchupTitle: starterMatchupTitle,
            starterSetDescription: starterSetDescription ?? "",
            starterSetBadge: starterSetBadge ?? "",
            playerOne: playerOne.starterArmySelection,
            playerTwo: playerTwo.starterArmySelection,
            defaultMissionId: defaultMissionId
        )
    }
}

extension GameSystemDescriptor {
    /// A copy of this descriptor with `featuredArmies` replaced — used to source
    /// featured armies from box-set JSON while every other field stays put.
    public func replacingFeaturedArmies(_ featuredArmies: FeaturedArmiesConfig?) -> GameSystemDescriptor {
        GameSystemDescriptor(
            id: id,
            publisher: publisher,
            playEngine: playEngine,
            capabilities: capabilities,
            copy: copy,
            victoryPointsScoring: victoryPointsScoring,
            featuredArmies: featuredArmies,
            catalogBundleName: catalogBundleName,
            armyDetailsSubdirectories: armyDetailsSubdirectories
        )
    }
}

public struct BoxSetArmySelection: Codable, Sendable, Equatable {
    public let playerName: String?
    public let factionId: String
    public let armyId: String

    public init(playerName: String? = nil, factionId: String, armyId: String) {
        self.playerName = playerName
        self.factionId = factionId
        self.armyId = armyId
    }

    public var starterArmySelection: StarterArmySelection {
        StarterArmySelection(
            playerName: playerName ?? "",
            factionId: factionId,
            armyId: armyId
        )
    }
}
