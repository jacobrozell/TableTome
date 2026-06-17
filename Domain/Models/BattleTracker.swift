import Foundation

public enum BattleTurnPhase: String, Codable, Sendable, CaseIterable, Identifiable {
    case deployment
    case hero
    case movement
    case shooting
    case charge
    case combat
    case endOfTurn
    case enemyMovement
    case endOfAnyTurn
    case anyCombat

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .deployment: String(localized: "Deployment")
        case .hero: String(localized: "Hero Phase")
        case .movement: String(localized: "Movement Phase")
        case .shooting: String(localized: "Shooting Phase")
        case .charge: String(localized: "Charge Phase")
        case .combat: String(localized: "Combat Phase")
        case .endOfTurn: String(localized: "End of Turn")
        case .enemyMovement: String(localized: "Enemy Movement")
        case .endOfAnyTurn: String(localized: "End of Any Turn")
        case .anyCombat: String(localized: "Any Combat Phase")
        }
    }

    public static let mainTurnPhases: [BattleTurnPhase] = [
        .hero, .movement, .shooting, .charge, .combat, .endOfTurn
    ]

    public var isCombatRelated: Bool {
        switch self {
        case .shooting, .charge, .combat, .anyCombat:
            true
        default:
            false
        }
    }
}

public enum AbilityUsageLimit: String, Codable, Sendable {
    case passive
    case eachTurn
    case eachPhase
    case oncePerBattle
    case oncePerPhase
    case reaction
}

public enum AbilityKind: String, Codable, Sendable {
    case ability
    case spell
    case passive
    case prayer
}

public struct TriggeredAbility: Codable, Sendable, Identifiable, Equatable {
    public let id: String
    public let name: String
    public let source: String
    public let flavor: String?
    public let phases: [BattleTurnPhase]
    public let usageLimit: AbilityUsageLimit
    public let declare: String?
    public let effect: String
    public let kind: AbilityKind

    public init(
        id: String,
        name: String,
        source: String,
        flavor: String? = nil,
        phases: [BattleTurnPhase],
        usageLimit: AbilityUsageLimit,
        declare: String? = nil,
        effect: String,
        kind: AbilityKind = .ability
    ) {
        self.id = id
        self.name = name
        self.source = source
        self.flavor = flavor
        self.phases = phases
        self.usageLimit = usageLimit
        self.declare = declare
        self.effect = effect
        self.kind = kind
    }

    public func matches(phase: BattleTurnPhase) -> Bool {
        if phases.contains(phase) { return true }
        if phase == .combat && phases.contains(.anyCombat) { return true }
        return false
    }

    public func isAvailableIn(
        phase: BattleTurnPhase,
        usedOncePerBattle: Set<String>
    ) -> Bool {
        guard matches(phase: phase) else { return false }
        if usageLimit == .oncePerBattle {
            return !usedOncePerBattle.contains(id)
        }
        return true
    }

    public var isPassive: Bool {
        usageLimit == .passive
    }

    public var suggestsCombatResolution: Bool {
        let combatPhases: Set<BattleTurnPhase> = [.shooting, .charge, .combat, .anyCombat]
        if phases.contains(where: combatPhases.contains) { return true }
        let text = effect.lowercased()
        return text.contains("attack")
            || text.contains("hit roll")
            || text.contains("wound roll")
            || text.contains("damage")
    }
}

public struct SpearheadUnit: Codable, Sendable, Identifiable, Equatable {
    public let id: String
    public let name: String
    public let move: String?
    public let save: Int?
    public let health: Int?
    public let control: Int?
    public let keywords: [String]
    public let notes: String?
    public let modelCount: Int?
    public let weapons: [SpearheadWeapon]
    public let abilities: [TriggeredAbility]

    public init(
        id: String,
        name: String,
        move: String? = nil,
        save: Int? = nil,
        health: Int? = nil,
        control: Int? = nil,
        keywords: [String] = [],
        notes: String? = nil,
        modelCount: Int? = nil,
        weapons: [SpearheadWeapon] = [],
        abilities: [TriggeredAbility] = []
    ) {
        self.id = id
        self.name = name
        self.move = move
        self.save = save
        self.health = health
        self.control = control
        self.keywords = keywords
        self.notes = notes
        self.modelCount = modelCount
        self.weapons = weapons
        self.abilities = abilities
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        move = try container.decodeIfPresent(String.self, forKey: .move)
        save = try container.decodeIfPresent(Int.self, forKey: .save)
        health = try container.decodeIfPresent(Int.self, forKey: .health)
        control = try container.decodeIfPresent(Int.self, forKey: .control)
        keywords = try container.decodeIfPresent([String].self, forKey: .keywords) ?? []
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        modelCount = try container.decodeIfPresent(Int.self, forKey: .modelCount)
        weapons = try container.decodeIfPresent([SpearheadWeapon].self, forKey: .weapons) ?? []
        abilities = try container.decodeIfPresent([TriggeredAbility].self, forKey: .abilities) ?? []
    }

    public var hasWarscroll: Bool {
        save != nil || !weapons.isEmpty
    }
}

public struct BattleTrackerState: Codable, Sendable, Equatable {
    public var battleRound: Int
    public var activePlayerIsOne: Bool
    public var currentPhase: BattleTurnPhase
    public var showAllAbilities: Bool
    public var usedOncePerBattleAbilityIds: Set<String>
    public var playerOneVictoryPoints: Int
    public var playerTwoVictoryPoints: Int
    public var completedRoundChecklistSteps: [String: Set<String>]
    public var unitWoundsRemaining: [String: Int]
    public var completedDeploymentSteps: Set<String>

    public init(
        battleRound: Int = 1,
        activePlayerIsOne: Bool = true,
        currentPhase: BattleTurnPhase = .hero,
        showAllAbilities: Bool = false,
        usedOncePerBattleAbilityIds: Set<String> = [],
        playerOneVictoryPoints: Int = 0,
        playerTwoVictoryPoints: Int = 0,
        completedRoundChecklistSteps: [String: Set<String>] = [:],
        unitWoundsRemaining: [String: Int] = [:],
        completedDeploymentSteps: Set<String> = []
    ) {
        self.battleRound = battleRound
        self.activePlayerIsOne = activePlayerIsOne
        self.currentPhase = currentPhase
        self.showAllAbilities = showAllAbilities
        self.usedOncePerBattleAbilityIds = usedOncePerBattleAbilityIds
        self.playerOneVictoryPoints = playerOneVictoryPoints
        self.playerTwoVictoryPoints = playerTwoVictoryPoints
        self.completedRoundChecklistSteps = completedRoundChecklistSteps
        self.unitWoundsRemaining = unitWoundsRemaining
        self.completedDeploymentSteps = completedDeploymentSteps
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        battleRound = try container.decodeIfPresent(Int.self, forKey: .battleRound) ?? 1
        activePlayerIsOne = try container.decodeIfPresent(Bool.self, forKey: .activePlayerIsOne) ?? true
        currentPhase = try container.decodeIfPresent(BattleTurnPhase.self, forKey: .currentPhase) ?? .hero
        showAllAbilities = try container.decodeIfPresent(Bool.self, forKey: .showAllAbilities) ?? false
        usedOncePerBattleAbilityIds = try container.decodeIfPresent(Set<String>.self, forKey: .usedOncePerBattleAbilityIds) ?? []
        playerOneVictoryPoints = try container.decodeIfPresent(Int.self, forKey: .playerOneVictoryPoints) ?? 0
        playerTwoVictoryPoints = try container.decodeIfPresent(Int.self, forKey: .playerTwoVictoryPoints) ?? 0
        completedRoundChecklistSteps = try container.decodeIfPresent([String: Set<String>].self, forKey: .completedRoundChecklistSteps) ?? [:]
        unitWoundsRemaining = try container.decodeIfPresent([String: Int].self, forKey: .unitWoundsRemaining) ?? [:]
        completedDeploymentSteps = try container.decodeIfPresent(Set<String>.self, forKey: .completedDeploymentSteps) ?? []
    }
}

public enum BattleAbilityCatalog {
    public static func abilities(for army: SpearheadArmy) -> [TriggeredAbility] {
        var result = army.battleTraits.map { trait in
            triggeredAbility(
                from: trait,
                armyId: army.id,
                source: army.battleTraitName ?? army.name,
                idPrefix: "trait"
            )
        }
        for unit in army.units {
            result.append(contentsOf: unit.abilities.map { ability in
                namespaced(ability, armyId: army.id, unitId: unit.id)
            })
        }
        return result
    }

    private static func triggeredAbility(
        from trait: ArmyRuleOption,
        armyId: String,
        source: String,
        idPrefix: String
    ) -> TriggeredAbility {
        TriggeredAbility(
            id: "\(armyId):\(idPrefix):\(trait.id)",
            name: trait.name,
            source: String(localized: "Army: \(source)"),
            flavor: trait.flavor,
            phases: trait.phases ?? [],
            usageLimit: trait.usageLimit ?? .oncePerBattle,
            declare: trait.declare,
            effect: trait.effect ?? trait.summary,
            kind: trait.kind ?? .ability
        )
    }

    private static func namespaced(_ ability: TriggeredAbility, armyId: String, unitId: String) -> TriggeredAbility {
        TriggeredAbility(
            id: "\(armyId):\(unitId):\(ability.id)",
            name: ability.name,
            source: ability.source,
            flavor: ability.flavor,
            phases: ability.phases,
            usageLimit: ability.usageLimit,
            declare: ability.declare,
            effect: ability.effect,
            kind: ability.kind
        )
    }
}
