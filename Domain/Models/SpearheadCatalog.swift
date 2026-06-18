import Foundation

public enum SpearheadAlliance: String, Codable, Sendable, CaseIterable {
    case order
    case chaos
    case death
    case destruction
}

public struct SpearheadCatalog: Codable, Sendable, Equatable {
    public let schemaVersion: Int
    public let factions: [SpearheadFaction]
    public let matchSteps: [MatchSetupStep]
    public let missions: [CombatPatrolMission]

    public init(
        schemaVersion: Int,
        factions: [SpearheadFaction],
        matchSteps: [MatchSetupStep],
        missions: [CombatPatrolMission] = []
    ) {
        self.schemaVersion = schemaVersion
        self.factions = factions
        self.matchSteps = matchSteps
        self.missions = missions
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        schemaVersion = try container.decode(Int.self, forKey: .schemaVersion)
        factions = try container.decode([SpearheadFaction].self, forKey: .factions)
        matchSteps = try container.decode([MatchSetupStep].self, forKey: .matchSteps)
        missions = try container.decodeIfPresent([CombatPatrolMission].self, forKey: .missions) ?? []
    }
}

public struct SpearheadFaction: Codable, Sendable, Identifiable, Equatable {
    public let id: String
    public let name: String
    public let alliance: SpearheadAlliance
    public let armies: [SpearheadArmy]

    public init(id: String, name: String, alliance: SpearheadAlliance, armies: [SpearheadArmy]) {
        self.id = id
        self.name = name
        self.alliance = alliance
        self.armies = armies
    }
}

public struct SpearheadArmy: Codable, Sendable, Identifiable, Equatable {
    public let id: String
    public let name: String
    public let general: String
    public let tagline: String
    public let playstyle: String
    public let unitCount: Int
    public let roster: [String]
    public let battleTraitName: String?
    public let officialRulesURL: String?
    public let battleTraits: [ArmyRuleOption]
    public let regimentAbilities: [ArmyRuleOption]
    public let enhancements: [ArmyRuleOption]
    public let secondaryObjectives: [ArmyRuleOption]
    public let stratagems: [CombatPatrolStratagem]
    public let units: [SpearheadUnit]

    public init(
        id: String,
        name: String,
        general: String,
        tagline: String,
        playstyle: String,
        unitCount: Int,
        roster: [String] = [],
        battleTraitName: String? = nil,
        officialRulesURL: String? = nil,
        battleTraits: [ArmyRuleOption] = [],
        regimentAbilities: [ArmyRuleOption] = [],
        enhancements: [ArmyRuleOption] = [],
        secondaryObjectives: [ArmyRuleOption] = [],
        stratagems: [CombatPatrolStratagem] = [],
        units: [SpearheadUnit] = []
    ) {
        self.id = id
        self.name = name
        self.general = general
        self.tagline = tagline
        self.playstyle = playstyle
        self.unitCount = unitCount
        self.roster = roster
        self.battleTraitName = battleTraitName
        self.officialRulesURL = officialRulesURL
        self.battleTraits = battleTraits
        self.regimentAbilities = regimentAbilities
        self.enhancements = enhancements
        self.secondaryObjectives = secondaryObjectives
        self.stratagems = stratagems
        self.units = units
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        general = try container.decode(String.self, forKey: .general)
        tagline = try container.decode(String.self, forKey: .tagline)
        playstyle = try container.decode(String.self, forKey: .playstyle)
        unitCount = try container.decode(Int.self, forKey: .unitCount)
        roster = try container.decodeIfPresent([String].self, forKey: .roster) ?? []
        battleTraitName = try container.decodeIfPresent(String.self, forKey: .battleTraitName)
        officialRulesURL = try container.decodeIfPresent(String.self, forKey: .officialRulesURL)
        battleTraits = try container.decodeIfPresent([ArmyRuleOption].self, forKey: .battleTraits) ?? []
        regimentAbilities = try container.decodeIfPresent([ArmyRuleOption].self, forKey: .regimentAbilities) ?? []
        enhancements = try container.decodeIfPresent([ArmyRuleOption].self, forKey: .enhancements) ?? []
        secondaryObjectives = try container.decodeIfPresent([ArmyRuleOption].self, forKey: .secondaryObjectives) ?? []
        stratagems = try container.decodeIfPresent([CombatPatrolStratagem].self, forKey: .stratagems) ?? []
        units = try container.decodeIfPresent([SpearheadUnit].self, forKey: .units) ?? []
    }
}

public struct ArmyRuleOption: Codable, Sendable, Identifiable, Equatable {
    public let id: String
    public let name: String
    public let summary: String
    public let newPlayerHint: String?
    public let timing: String?
    public let flavor: String?
    public let declare: String?
    public let effect: String?
    public let phases: [BattleTurnPhase]?
    public let usageLimit: AbilityUsageLimit?
    public let kind: AbilityKind?

    public init(
        id: String,
        name: String,
        summary: String,
        newPlayerHint: String? = nil,
        timing: String? = nil,
        flavor: String? = nil,
        declare: String? = nil,
        effect: String? = nil,
        phases: [BattleTurnPhase]? = nil,
        usageLimit: AbilityUsageLimit? = nil,
        kind: AbilityKind? = nil
    ) {
        self.id = id
        self.name = name
        self.summary = summary
        self.newPlayerHint = newPlayerHint
        self.timing = timing
        self.flavor = flavor
        self.declare = declare
        self.effect = effect
        self.phases = phases
        self.usageLimit = usageLimit
        self.kind = kind
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        summary = try container.decode(String.self, forKey: .summary)
        newPlayerHint = try container.decodeIfPresent(String.self, forKey: .newPlayerHint)
        timing = try container.decodeIfPresent(String.self, forKey: .timing)
        flavor = try container.decodeIfPresent(String.self, forKey: .flavor)
        declare = try container.decodeIfPresent(String.self, forKey: .declare)
        effect = try container.decodeIfPresent(String.self, forKey: .effect)
        phases = try container.decodeIfPresent([BattleTurnPhase].self, forKey: .phases)
        usageLimit = try container.decodeIfPresent(AbilityUsageLimit.self, forKey: .usageLimit)
        kind = try container.decodeIfPresent(AbilityKind.self, forKey: .kind)
    }
}

public struct MatchSetupStep: Codable, Sendable, Identifiable, Equatable {
    public let id: String
    public let order: Int
    public let title: String
    public let summary: String
    public let body: String
    public let tips: [String]
    public let relatedRuleSectionId: String?

    public init(
        id: String,
        order: Int,
        title: String,
        summary: String,
        body: String,
        tips: [String] = [],
        relatedRuleSectionId: String? = nil
    ) {
        self.id = id
        self.order = order
        self.title = title
        self.summary = summary
        self.body = body
        self.tips = tips
        self.relatedRuleSectionId = relatedRuleSectionId
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        order = try container.decode(Int.self, forKey: .order)
        title = try container.decode(String.self, forKey: .title)
        summary = try container.decode(String.self, forKey: .summary)
        body = try container.decode(String.self, forKey: .body)
        tips = try container.decodeIfPresent([String].self, forKey: .tips) ?? []
        relatedRuleSectionId = try container.decodeIfPresent(String.self, forKey: .relatedRuleSectionId)
    }
}

public struct PlayerArmySelection: Codable, Sendable, Equatable {
    public var playerName: String
    public var factionId: String
    public var armyId: String
    public var regimentAbilityId: String?
    public var enhancementId: String?
    public var secondaryObjectiveId: String?

    public init(
        playerName: String,
        factionId: String = "",
        armyId: String = "",
        regimentAbilityId: String? = nil,
        enhancementId: String? = nil,
        secondaryObjectiveId: String? = nil
    ) {
        self.playerName = playerName
        self.factionId = factionId
        self.armyId = armyId
        self.regimentAbilityId = regimentAbilityId
        self.enhancementId = enhancementId
        self.secondaryObjectiveId = secondaryObjectiveId
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        playerName = try container.decode(String.self, forKey: .playerName)
        factionId = try container.decode(String.self, forKey: .factionId)
        armyId = try container.decode(String.self, forKey: .armyId)
        regimentAbilityId = try container.decodeIfPresent(String.self, forKey: .regimentAbilityId)
        enhancementId = try container.decodeIfPresent(String.self, forKey: .enhancementId)
        secondaryObjectiveId = try container.decodeIfPresent(String.self, forKey: .secondaryObjectiveId)
    }
}

public struct GuidedMatchState: Codable, Sendable, Equatable {
    public var playerOne: PlayerArmySelection
    public var playerTwo: PlayerArmySelection
    public var attackerIsPlayerOne: Bool?
    public var firstTurnIsPlayerOne: Bool?
    public var selectedMissionId: String?
    public var completedStepIds: Set<String>

    public init(
        playerOne: PlayerArmySelection = PlayerArmySelection(playerName: "Player 1"),
        playerTwo: PlayerArmySelection = PlayerArmySelection(playerName: "Player 2"),
        attackerIsPlayerOne: Bool? = nil,
        firstTurnIsPlayerOne: Bool? = nil,
        selectedMissionId: String? = nil,
        completedStepIds: Set<String> = []
    ) {
        self.playerOne = playerOne
        self.playerTwo = playerTwo
        self.attackerIsPlayerOne = attackerIsPlayerOne
        self.firstTurnIsPlayerOne = firstTurnIsPlayerOne
        self.selectedMissionId = selectedMissionId
        self.completedStepIds = completedStepIds
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        playerOne = try container.decode(PlayerArmySelection.self, forKey: .playerOne)
        playerTwo = try container.decode(PlayerArmySelection.self, forKey: .playerTwo)
        attackerIsPlayerOne = try container.decodeIfPresent(Bool.self, forKey: .attackerIsPlayerOne)
        firstTurnIsPlayerOne = try container.decodeIfPresent(Bool.self, forKey: .firstTurnIsPlayerOne)
        selectedMissionId = try container.decodeIfPresent(String.self, forKey: .selectedMissionId)
        completedStepIds = try container.decodeIfPresent(Set<String>.self, forKey: .completedStepIds) ?? []
    }

    public var hasBothArmies: Bool {
        !playerOne.armyId.isEmpty && !playerTwo.armyId.isEmpty
    }
}
