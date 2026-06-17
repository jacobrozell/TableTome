import Foundation

public struct CombatRollOptions: Sendable, Equatable {
    public var critAutoWound: Bool
    public var critMortal: Bool
    public var mortalDamage: Bool

    public init(critAutoWound: Bool = false, critMortal: Bool = false, mortalDamage: Bool = false) {
        self.critAutoWound = critAutoWound
        self.critMortal = critMortal
        self.mortalDamage = mortalDamage
    }

    public static func from(weapon: SpearheadWeapon) -> CombatRollOptions {
        CombatRollOptions(
            critAutoWound: weapon.hasCritAutoWound,
            critMortal: weapon.hasCritMortal,
            mortalDamage: false
        )
    }
}

public enum WeaponDamageKind: Sendable, Equatable {
    case fixed(Int)
    case variable(WeaponVariableDamage)

    public var displayName: String {
        switch self {
        case .fixed(let value): return "\(value)"
        case .variable(let kind): return kind.rawValue
        }
    }
}

public enum WeaponVariableDamage: String, Sendable, Equatable, CaseIterable {
    case d3 = "D3"
    case d6 = "D6"
    case twoD6 = "2D6"
}

extension SpearheadWeapon {
    public var fixedAttackCount: Int? { Int(attacks) }

    public var hasCritMortal: Bool {
        ability?.localizedCaseInsensitiveContains("Crit (Mortal)") == true
    }

    public var hasCritAutoWound: Bool {
        ability?.localizedCaseInsensitiveContains("Crit (Auto-wound)") == true
    }

    public var hasShootInCombat: Bool {
        ability?.localizedCaseInsensitiveContains("Shoot in Combat") == true
    }

    public var damageKind: WeaponDamageKind? {
        if let fixed = Int(damage) { return .fixed(fixed) }
        if damage == "D3" { return .variable(.d3) }
        if damage == "D6" { return .variable(.d6) }
        if damage == "2D6" { return .variable(.twoD6) }
        return nil
    }

    public var isRollEvaluable: Bool {
        damageKind != nil
    }

    public func weaponBuffs(unitId: String) -> [CombatMatchupBuff] {
        var buffs: [CombatMatchupBuff] = []
        if hasCritAutoWound {
            buffs.append(
                CombatMatchupBuff(
                    id: "\(unitId)-\(id)-crit-auto-wound",
                    name: "Crit (Auto-wound)",
                    summary: "Unmodified 6 on the hit roll automatically wounds.",
                    side: .attacker,
                    source: name
                )
            )
        }
        if hasCritMortal {
            buffs.append(
                CombatMatchupBuff(
                    id: "\(unitId)-\(id)-crit-mortal",
                    name: "Crit (Mortal)",
                    summary: "Unmodified 6 on the wound roll inflicts mortal damage (no save).",
                    side: .attacker,
                    source: name
                )
            )
        }
        if hasShootInCombat {
            buffs.append(
                CombatMatchupBuff(
                    id: "\(unitId)-\(id)-shoot-in-combat",
                    name: "Shoot in Combat",
                    summary: "Reminder: this ranged weapon can be used in combat.",
                    side: .attacker,
                    source: name
                )
            )
        }
        return buffs
    }
}

public struct MultiAttackResult: Sendable, Equatable, Identifiable {
    public let id: Int
    public let evaluation: AttackRollEvaluation

    public init(id: Int, evaluation: AttackRollEvaluation) {
        self.id = id
        self.evaluation = evaluation
    }
}

public enum MultiAttackSequence {
    public static func totalDamage(from results: [MultiAttackResult]) -> Int {
        results.reduce(0) { $0 + $1.evaluation.damageDealt }
    }
}
