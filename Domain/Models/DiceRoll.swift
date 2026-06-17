import Foundation

public enum DiceInputMode: String, Sendable, CaseIterable {
    case physical
    case simulated
}

public enum DieType: Int, Sendable {
    case d6 = 6
}

public enum RollPurpose: Sendable, Equatable {
    case hit
    case wound
    case save
    case ward
    case damage
    case variableDamage(WeaponVariableDamage)
}

public struct DiceRollResult: Sendable, Equatable, Identifiable {
    public let id: UUID
    public let dieType: DieType
    public let purpose: RollPurpose
    public let faceValue: Int
    public let underlyingRolls: [Int]

    public init(
        id: UUID = UUID(),
        dieType: DieType,
        purpose: RollPurpose,
        faceValue: Int,
        underlyingRolls: [Int]
    ) {
        self.id = id
        self.dieType = dieType
        self.purpose = purpose
        self.faceValue = faceValue
        self.underlyingRolls = underlyingRolls
    }
}

public struct AttackRollParameters: Sendable, Equatable {
    public var hitTarget: Int
    public var woundTarget: Int
    public var saveTarget: Int
    public var rend: Int
    public var damage: Int
    public var hitModifier: Int
    public var woundModifier: Int
    public var saveModifier: Int
    public var wardTarget: Int?
    public var critAutoWound: Bool
    public var critMortal: Bool
    public var mortalDamage: Bool
    public var variableDamage: WeaponVariableDamage?

    public init(
        hitTarget: Int,
        woundTarget: Int,
        saveTarget: Int,
        rend: Int,
        damage: Int,
        hitModifier: Int = 0,
        woundModifier: Int = 0,
        saveModifier: Int = 0,
        wardTarget: Int? = nil,
        critAutoWound: Bool = false,
        critMortal: Bool = false,
        mortalDamage: Bool = false,
        variableDamage: WeaponVariableDamage? = nil
    ) {
        self.hitTarget = hitTarget
        self.woundTarget = woundTarget
        self.saveTarget = saveTarget
        self.rend = rend
        self.damage = damage
        self.hitModifier = hitModifier
        self.woundModifier = woundModifier
        self.saveModifier = saveModifier
        self.wardTarget = wardTarget
        self.critAutoWound = critAutoWound
        self.critMortal = critMortal
        self.mortalDamage = mortalDamage
        self.variableDamage = variableDamage
    }
}

public struct SimulatedAttackRolls: Sendable, Equatable {
    public var rolls: [DiceRollResult]
    public var hitRoll: Int
    public var woundRoll: Int
    public var saveRoll: Int
    public var wardRoll: Int?
    public var damage: Int

    public init(
        rolls: [DiceRollResult],
        hitRoll: Int,
        woundRoll: Int,
        saveRoll: Int,
        wardRoll: Int?,
        damage: Int
    ) {
        self.rolls = rolls
        self.hitRoll = hitRoll
        self.woundRoll = woundRoll
        self.saveRoll = saveRoll
        self.wardRoll = wardRoll
        self.damage = damage
    }
}
