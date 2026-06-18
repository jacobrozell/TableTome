import Foundation

public struct CombatBatchLogContext: Sendable, Equatable {
    public var attackerUnitName: String
    public var defenderUnitName: String
    public var weaponName: String
    public var hits: Int
    public var wounds: Int
    public var failedSaves: Int
    public var damageDealt: Int

    public init(
        attackerUnitName: String,
        defenderUnitName: String,
        weaponName: String,
        hits: Int,
        wounds: Int,
        failedSaves: Int,
        damageDealt: Int
    ) {
        self.attackerUnitName = attackerUnitName
        self.defenderUnitName = defenderUnitName
        self.weaponName = weaponName
        self.hits = hits
        self.wounds = wounds
        self.failedSaves = failedSaves
        self.damageDealt = damageDealt
    }
}
