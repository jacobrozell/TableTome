import Foundation

public enum MatchVictoryPointsReason: String, Codable, Sendable {
    case objective
    case tactic
    case manual
    case other
}

public struct MatchLogEventPayload: Codable, Sendable, Equatable {
    public var round: Int?
    public var phaseId: String?
    public var playerIsOne: Bool?
    public var playerName: String?
    public var delta: Int?
    public var newTotal: Int?
    public var pointsReason: MatchVictoryPointsReason?
    public var stepId: String?
    public var unitId: String?
    public var unitName: String?
    public var woundsRemoved: Int?
    public var woundsRemaining: Int?
    public var damageSource: String?
    public var abilityId: String?
    public var abilityName: String?
    public var archiveStatus: String?
    public var attackerUnitName: String?
    public var defenderUnitName: String?
    public var weaponName: String?
    public var combatHits: Int?
    public var combatWounds: Int?
    public var combatFailedSaves: Int?
    public var combatDamageDealt: Int?

    public init(
        round: Int? = nil,
        phaseId: String? = nil,
        playerIsOne: Bool? = nil,
        playerName: String? = nil,
        delta: Int? = nil,
        newTotal: Int? = nil,
        pointsReason: MatchVictoryPointsReason? = nil,
        stepId: String? = nil,
        unitId: String? = nil,
        unitName: String? = nil,
        woundsRemoved: Int? = nil,
        woundsRemaining: Int? = nil,
        damageSource: String? = nil,
        abilityId: String? = nil,
        abilityName: String? = nil,
        archiveStatus: String? = nil,
        attackerUnitName: String? = nil,
        defenderUnitName: String? = nil,
        weaponName: String? = nil,
        combatHits: Int? = nil,
        combatWounds: Int? = nil,
        combatFailedSaves: Int? = nil,
        combatDamageDealt: Int? = nil
    ) {
        self.round = round
        self.phaseId = phaseId
        self.playerIsOne = playerIsOne
        self.playerName = playerName
        self.delta = delta
        self.newTotal = newTotal
        self.pointsReason = pointsReason
        self.stepId = stepId
        self.unitId = unitId
        self.unitName = unitName
        self.woundsRemoved = woundsRemoved
        self.woundsRemaining = woundsRemaining
        self.damageSource = damageSource
        self.abilityId = abilityId
        self.abilityName = abilityName
        self.archiveStatus = archiveStatus
        self.attackerUnitName = attackerUnitName
        self.defenderUnitName = defenderUnitName
        self.weaponName = weaponName
        self.combatHits = combatHits
        self.combatWounds = combatWounds
        self.combatFailedSaves = combatFailedSaves
        self.combatDamageDealt = combatDamageDealt
    }
}
