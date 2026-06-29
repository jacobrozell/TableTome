import Foundation

/// How many hit dice to roll, including variable Attacks (D6 / 2D6) weapons.
public struct HitDicePlan: Equatable, Sendable {
    public enum Quantity: Equatable, Sendable {
        case fixed(totalHitDice: Int)
        case variablePerModel(attackExpression: String, modelsWithWeapon: Int)
    }

    public let quantity: Quantity
    public let summary: String
    public let detail: String?

    public init(quantity: Quantity, summary: String, detail: String?) {
        self.quantity = quantity
        self.summary = summary
        self.detail = detail
    }

    public var fixedTotalHitDice: Int? {
        guard case .fixed(let total) = quantity else { return nil }
        return total
    }

    public var variableAttackExpression: String? {
        guard case .variablePerModel(let expression, _) = quantity else { return nil }
        return expression
    }
}

public enum WeaponAttackCharacteristic: Equatable, Sendable {
    case fixed(Int)
    case variable(String)

    public static func from(attacks: String) -> WeaponAttackCharacteristic {
        if let value = Int(attacks) { return .fixed(value) }
        return .variable(attacks)
    }
}

extension SpearheadWeapon {
    public var attackCharacteristic: WeaponAttackCharacteristic {
        WeaponAttackCharacteristic.from(attacks: attacks)
    }

    public var hasVariableAttacks: Bool {
        if case .variable = attackCharacteristic { return true }
        return false
    }
}

/// Computes how many attack rolls a weapon generates for a deployed unit.
public enum WeaponAttackRollCount {
    public static func attacksPerModel(for weapon: SpearheadWeapon) -> Int {
        guard case .fixed(let count) = weapon.attackCharacteristic else { return 1 }
        return max(1, count)
    }

    public static func defaultDeployedModelCount(for unit: SpearheadUnit) -> Int {
        max(1, unit.modelCount ?? 1)
    }

    public static func defaultDeployedModelCount(for unit: SpearheadUnit, weapon: SpearheadWeapon) -> Int {
        if let modelsWithWeapon = weapon.modelsWithWeapon {
            return max(1, modelsWithWeapon)
        }
        return defaultDeployedModelCount(for: unit)
    }

    public static func hitDicePlan(
        weapon: SpearheadWeapon,
        deployedModelCount: Int,
        resolvedAttackCount: Int? = nil
    ) -> HitDicePlan {
        if let resolved = resolvedAttackCount, weapon.hasVariableAttacks, resolved > 0 {
            return HitDicePlan(
                quantity: .fixed(totalHitDice: resolved),
                summary: String(localized: "\(resolved) hit dice after \(weapon.attacks) attack rolls"),
                detail: nil
            )
        }

        let models = max(1, deployedModelCount)
        switch weapon.attackCharacteristic {
        case .fixed(let perModel):
            let total = models * max(1, perModel)
            return HitDicePlan(
                quantity: .fixed(totalHitDice: total),
                summary: fixedHitDiceSummary(models: models, perModel: perModel, total: total),
                detail: nil
            )
        case .variable(let expression):
            return HitDicePlan(
                quantity: .variablePerModel(attackExpression: expression, modelsWithWeapon: models),
                summary: variableHitDiceSummary(expression: expression, models: models),
                detail: variableHitDiceDetail(expression: expression, models: models)
            )
        }
    }

    public static func totalAttacks(
        weapon: SpearheadWeapon,
        deployedModelCount: Int,
        resolvedAttackCount: Int? = nil
    ) -> Int {
        hitDicePlan(
            weapon: weapon,
            deployedModelCount: deployedModelCount,
            resolvedAttackCount: resolvedAttackCount
        ).fixedTotalHitDice ?? 1
    }

    public static func hitDiceSummary(
        weapon: SpearheadWeapon,
        deployedModelCount: Int,
        resolvedAttackCount: Int? = nil
    ) -> String {
        hitDicePlan(
            weapon: weapon,
            deployedModelCount: deployedModelCount,
            resolvedAttackCount: resolvedAttackCount
        ).summary
    }

    private static func fixedHitDiceSummary(models: Int, perModel: Int, total: Int) -> String {
        if models == 1, perModel == 1 {
            return String(localized: "Roll 1 hit dice")
        }
        if perModel == 1 {
            return String(localized: "\(models) models = \(total) hit dice to roll")
        }
        return String(localized: "\(models) models × \(perModel) attacks = \(total) hit dice to roll")
    }

    private static func variableHitDiceSummary(expression: String, models: Int) -> String {
        if models == 1 {
            return String(
                localized: "Roll \(expression) for attacks, then roll 1 hit dice per attack"
            )
        }
        return String(
            localized: "Roll \(expression) per model × \(models) models, then hit dice"
        )
    }

    private static func variableHitDiceDetail(expression: String, models: Int) -> String {
        if models == 1 {
            return String(
                localized: "Variable Attacks are per model — one roll of \(expression) for this model."
            )
        }
        return String(
            localized: """
            Roll \(expression) separately for each model using this weapon. Set the stepper to \
            models armed with it (not the whole unit — e.g. 1 Warpfire Gunner).
            """
        )
    }
}

extension SpearheadUnit {
    public func defaultDeployedModelCount(for weapon: SpearheadWeapon) -> Int {
        WeaponAttackRollCount.defaultDeployedModelCount(for: self, weapon: weapon)
    }

    public var defaultDeployedModelCount: Int {
        WeaponAttackRollCount.defaultDeployedModelCount(for: self)
    }

    public var shootingWeapons: [SpearheadWeapon] {
        weapons.filter(\.isRanged)
    }

    public var canShoot: Bool {
        !shootingWeapons.isEmpty
    }

    public var meleeWeapons: [SpearheadWeapon] {
        weapons.filter { !$0.isRanged }
    }

    public var canFight: Bool {
        !meleeWeapons.isEmpty
    }
}

extension TriggeredAbility {
    public var isStartOfBattleRound: Bool {
        let combined = [declare, effect]
            .compactMap { $0?.lowercased() }
            .joined(separator: " ")
        return combined.contains("start of battle round")
            || combined.contains("start of the battle round")
    }
}
