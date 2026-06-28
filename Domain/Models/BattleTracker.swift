import Foundation

public enum BattleTurnPhase: String, Codable, Sendable, CaseIterable, Identifiable {
    case deployment
    case command
    case hero
    case movement
    case assault
    case shooting
    case charge
    case combat
    case scoring
    case endOfTurn
    case enemyMovement
    case endOfAnyTurn
    case anyCombat

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .deployment: String(localized: "Deployment")
        case .command: String(localized: "Command Phase")
        case .hero: String(localized: "Hero Phase")
        case .movement: String(localized: "Movement Phase")
        case .assault: String(localized: "Assault Phase")
        case .shooting: String(localized: "Shooting Phase")
        case .charge: String(localized: "Charge Phase")
        case .combat: String(localized: "Fight Phase")
        case .scoring: String(localized: "Scoring Phase")
        case .endOfTurn: String(localized: "End of Turn")
        case .enemyMovement: String(localized: "Enemy Movement")
        case .endOfAnyTurn: String(localized: "End of Any Turn")
        case .anyCombat: String(localized: "Any Combat Phase")
        }
    }

    public static let mainTurnPhases: [BattleTurnPhase] = [
        .deployment, .hero, .movement, .shooting, .charge, .combat, .endOfTurn
    ]

    public var isCombatRelated: Bool {
        switch self {
        case .shooting, .assault, .charge, .combat, .anyCombat:
            true
        default:
            false
        }
    }

    public var nextMainPhase: BattleTurnPhase? {
        guard let index = Self.mainTurnPhases.firstIndex(of: self),
              index < Self.mainTurnPhases.count - 1 else { return nil }
        return Self.mainTurnPhases[index + 1]
    }

    public var newPlayerSummary: String {
        switch self {
        case .deployment:
            String(
                localized: "Set up terrain and deploy units. The defender picks a board side first, then players alternate placing units."
            )
        case .command:
            String(
                localized: "Gain Command Points, resolve battle-shock tests, use stratagems, and score mission objectives at the end of the phase."
            )
        case .hero:
            String(
                localized: "Use heroic abilities, spells, and prayers. Pick which player goes first if it is round 1."
            )
        case .movement:
            String(
                localized: "Move units up to their Move characteristic. Deploy from reserves during Movement in StarCraft TMG."
            )
        case .assault:
            String(
                localized: "Shoot and charge with alternating activations. Surge and counter matchups matter."
            )
        case .shooting:
            String(
                localized: "Pick a unit that can shoot, choose targets in range, then roll to hit and wound. Resolve saves in the combat resolver."
            )
        case .charge:
            String(
                localized: "Try to charge enemy units within 12\". Roll 2D6 for charge distance — pick a unit, declare a target, then roll."
            )
        case .combat, .anyCombat:
            String(
                localized: "Fight with units in combat. Pick attacker and defender, roll hit and wound dice, then saves and wards."
            )
        case .scoring:
            String(
                localized: "Score mission victory points. Objectives use Supply within 3\", not model count."
            )
        case .endOfTurn:
            String(
                localized: "Score victory points from objectives and battle tactics, then pass play to your opponent."
            )
        case .enemyMovement:
            String(
                localized: "Some abilities trigger when enemy units move. Check your passive and reaction abilities now."
            )
        case .endOfAnyTurn:
            String(
                localized: "Abilities that fire at the end of either player's turn. Check both armies' end-of-turn effects."
            )
        }
    }

    public func playerFacingSummary(gameSystemId: String) -> String {
        let context = GameSystemPlayContext.context(for: gameSystemId)
        if context.capabilities.showsActivationBar {
            return starCraftPlayerSummary
        }
        if context.capabilities.resolvesWh40kRules {
            return wh40kPlayerSummary
        }
        return newPlayerSummary
    }

    private var wh40kPlayerSummary: String {
        switch self {
        case .command:
            String(
                localized: "Gain Command Points, test Battle-shock, use stratagems, then score objectives that trigger now."
            )
        case .movement:
            String(
                localized: "Move units up to their Move characteristic. Advancing adds distance but usually stops shooting."
            )
        case .shooting:
            String(
                localized: "Pick units to shoot, measure range, then resolve hit, wound, save, and damage on your datasheets."
            )
        case .charge:
            String(
                localized: "Declare charges into engagement range, then roll 2D6 — both dice must reach the target."
            )
        case .combat, .anyCombat:
            String(
                localized: "Fight with units in engagement range. Alternate attacks, then update wounds in Army Health."
            )
        case .endOfTurn:
            String(
                localized: "Score primary and secondary objectives for this turn, then pass the phone."
            )
        case .deployment:
            String(
                localized: "Set up the mission, terrain footprints, and deploy armies before the first battle round."
            )
        default:
            String(localized: "Follow the current phase on your datasheet and the core rules.")
        }
    }

    private var starCraftPlayerSummary: String {
        switch self {
        case .movement:
            String(
                localized: "Alternate activations — deploy from reserves, move one unit, then hand off. Pass to claim the First Player Marker for Assault."
            )
        case .assault:
            String(
                localized: "Alternate activations to shoot and charge. Surge and counter matchups matter. Pass to claim the marker for Combat."
            )
        case .combat:
            String(
                localized: "Alternate melee activations. Consolidate where allowed, then hand off with Done or Pass."
            )
        case .scoring:
            String(
                localized: "Award mission victory points. Objectives use total Supply within 3\", not model count."
            )
        default:
            String(
                localized: "StarCraft TMG alternates activations across Movement, Assault, Combat, and Scoring."
            )
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
    public let invulnerableSave: Int?
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
        invulnerableSave: Int? = nil,
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
        self.invulnerableSave = invulnerableSave
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
        invulnerableSave = try container.decodeIfPresent(Int.self, forKey: .invulnerableSave)
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
    public var unitHealthPerModelOverrides: [String: Int]
    public var completedDeploymentSteps: Set<String>
    /// Player one holds the First Player Marker when `true`; unset until someone passes.
    public var scFirstPlayerMarkerIsPlayerOne: Bool?
    /// Who passed this phase to claim the marker; cleared when the phase changes.
    public var scPhasePassClaimedByPlayerOne: Bool?
    /// Combat Patrol — Battle Ready bonus (+10 VP) agreed per player.
    public var playerOneBattleReady: Bool?
    public var playerTwoBattleReady: Bool?
    /// Combat Patrol — objective markers secured by Battleline (A–D).
    public var securedObjectiveIds: Set<String>
    /// Combat Patrol — stratagem ids used this battle (`armyId:stratagemId`).
    public var usedStratagemIds: Set<String>
    /// Combat Patrol — Retrieve Intelligence: objectives data recovered from.
    public var intelRecoveredObjectiveIds: Set<String>

    public init(
        battleRound: Int = 1,
        activePlayerIsOne: Bool = true,
        currentPhase: BattleTurnPhase = .deployment,
        showAllAbilities: Bool = false,
        usedOncePerBattleAbilityIds: Set<String> = [],
        playerOneVictoryPoints: Int = 0,
        playerTwoVictoryPoints: Int = 0,
        completedRoundChecklistSteps: [String: Set<String>] = [:],
        unitWoundsRemaining: [String: Int] = [:],
        unitHealthPerModelOverrides: [String: Int] = [:],
        completedDeploymentSteps: Set<String> = [],
        scFirstPlayerMarkerIsPlayerOne: Bool? = nil,
        scPhasePassClaimedByPlayerOne: Bool? = nil,
        playerOneBattleReady: Bool? = nil,
        playerTwoBattleReady: Bool? = nil,
        securedObjectiveIds: Set<String> = [],
        usedStratagemIds: Set<String> = [],
        intelRecoveredObjectiveIds: Set<String> = []
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
        self.unitHealthPerModelOverrides = unitHealthPerModelOverrides
        self.completedDeploymentSteps = completedDeploymentSteps
        self.scFirstPlayerMarkerIsPlayerOne = scFirstPlayerMarkerIsPlayerOne
        self.scPhasePassClaimedByPlayerOne = scPhasePassClaimedByPlayerOne
        self.playerOneBattleReady = playerOneBattleReady
        self.playerTwoBattleReady = playerTwoBattleReady
        self.securedObjectiveIds = securedObjectiveIds
        self.usedStratagemIds = usedStratagemIds
        self.intelRecoveredObjectiveIds = intelRecoveredObjectiveIds
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
        unitHealthPerModelOverrides = try container.decodeIfPresent(
            [String: Int].self,
            forKey: .unitHealthPerModelOverrides
        ) ?? [:]
        completedDeploymentSteps = try container.decodeIfPresent(Set<String>.self, forKey: .completedDeploymentSteps) ?? []
        scFirstPlayerMarkerIsPlayerOne = try container.decodeIfPresent(Bool.self, forKey: .scFirstPlayerMarkerIsPlayerOne)
        scPhasePassClaimedByPlayerOne = try container.decodeIfPresent(Bool.self, forKey: .scPhasePassClaimedByPlayerOne)
        playerOneBattleReady = try container.decodeIfPresent(Bool.self, forKey: .playerOneBattleReady)
        playerTwoBattleReady = try container.decodeIfPresent(Bool.self, forKey: .playerTwoBattleReady)
        securedObjectiveIds = try container.decodeIfPresent(Set<String>.self, forKey: .securedObjectiveIds) ?? []
        usedStratagemIds = try container.decodeIfPresent(Set<String>.self, forKey: .usedStratagemIds) ?? []
        intelRecoveredObjectiveIds = try container.decodeIfPresent(Set<String>.self, forKey: .intelRecoveredObjectiveIds) ?? []
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
