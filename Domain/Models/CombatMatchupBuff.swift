import Foundation

public enum CombatMatchupSide: String, Sendable, Equatable {
    case attacker
    case defender
}

public struct CombatMatchupBuff: Identifiable, Sendable, Equatable {
    public let id: String
    public let name: String
    public let summary: String
    public let side: CombatMatchupSide
    public let hitModifier: Int
    public let woundModifier: Int
    public let saveModifier: Int
    public let wardTarget: Int?
    public let source: String
    public let isGeneric: Bool

    public init(
        id: String,
        name: String,
        summary: String,
        side: CombatMatchupSide,
        hitModifier: Int = 0,
        woundModifier: Int = 0,
        saveModifier: Int = 0,
        wardTarget: Int? = nil,
        source: String,
        isGeneric: Bool = false
    ) {
        self.id = id
        self.name = name
        self.summary = summary
        self.side = side
        self.hitModifier = hitModifier
        self.woundModifier = woundModifier
        self.saveModifier = saveModifier
        self.wardTarget = wardTarget
        self.source = source
        self.isGeneric = isGeneric
    }
}

public struct CombatMatchupModifiers: Sendable, Equatable {
    public let hit: Int
    public let wound: Int
    public let save: Int
    public let wardTarget: Int?

    public init(hit: Int = 0, wound: Int = 0, save: Int = 0, wardTarget: Int? = nil) {
        self.hit = hit
        self.wound = wound
        self.save = save
        self.wardTarget = wardTarget
    }
}

public enum CombatMatchupBuffCatalog {
    public static func buffs(for unit: SpearheadUnit, side: CombatMatchupSide) -> [CombatMatchupBuff] {
        var result = wardBuffs(for: unit)
        for ability in unit.abilities {
            result.append(contentsOf: parseAbilityBuffs(ability, unit: unit, side: side))
        }
        return result
    }

    public static func genericBuffs(for side: CombatMatchupSide) -> [CombatMatchupBuff] {
        switch side {
        case .attacker:
            return [
                CombatMatchupBuff(
                    id: "generic-attacker-hit-plus",
                    name: "+1 to Hit",
                    summary: "Apply a +1 modifier to the hit roll.",
                    side: .attacker,
                    hitModifier: 1,
                    source: String(localized: "Table modifier"),
                    isGeneric: true
                ),
                CombatMatchupBuff(
                    id: "generic-attacker-hit-minus",
                    name: "−1 to Hit",
                    summary: "Apply a −1 modifier to the hit roll.",
                    side: .attacker,
                    hitModifier: -1,
                    source: String(localized: "Table modifier"),
                    isGeneric: true
                ),
                CombatMatchupBuff(
                    id: "generic-attacker-wound-plus",
                    name: "+1 to Wound",
                    summary: "Apply a +1 modifier to the wound roll.",
                    side: .attacker,
                    woundModifier: 1,
                    source: String(localized: "Table modifier"),
                    isGeneric: true
                )
            ]
        case .defender:
            return [
                CombatMatchupBuff(
                    id: "generic-defender-save-plus",
                    name: "+1 to Save",
                    summary: "Apply a +1 modifier to the save roll.",
                    side: .defender,
                    saveModifier: 1,
                    source: String(localized: "Table modifier"),
                    isGeneric: true
                ),
                CombatMatchupBuff(
                    id: "generic-defender-save-minus",
                    name: "−1 to Save",
                    summary: "Apply a −1 modifier to the save roll.",
                    side: .defender,
                    saveModifier: -1,
                    source: String(localized: "Table modifier"),
                    isGeneric: true
                )
            ]
        }
    }

    public static func matchupBuffs(
        attacker: SpearheadUnit?,
        defender: SpearheadUnit?,
        weapon: SpearheadWeapon? = nil
    ) -> [CombatMatchupBuff] {
        var result: [CombatMatchupBuff] = []
        if let attacker {
            result.append(contentsOf: buffs(for: attacker, side: .attacker))
            result.append(contentsOf: genericBuffs(for: .attacker))
            if let weapon {
                result.append(contentsOf: weapon.weaponBuffs(unitId: attacker.id))
            }
        }
        if let defender {
            result.append(contentsOf: buffs(for: defender, side: .defender))
            result.append(contentsOf: genericBuffs(for: .defender))
        }
        return result
    }

    public static func aggregateModifiers(
        from buffs: [CombatMatchupBuff],
        enabledIds: Set<String>
    ) -> CombatMatchupModifiers {
        let active = buffs.filter { enabledIds.contains($0.id) }
        let hit = active.reduce(0) { $0 + $1.hitModifier }
        let wound = active.reduce(0) { $0 + $1.woundModifier }
        let save = active.reduce(0) { $0 + $1.saveModifier }
        let wardTarget = active.compactMap(\.wardTarget).min()
        return CombatMatchupModifiers(hit: hit, wound: wound, save: save, wardTarget: wardTarget)
    }

    private static func wardBuffs(for unit: SpearheadUnit) -> [CombatMatchupBuff] {
        unit.keywords.compactMap { keyword in
            guard let ward = parseWardThreshold(keyword) else { return nil }
            return CombatMatchupBuff(
                id: "\(unit.id)-ward-\(ward)",
                name: keyword,
                summary: "After a failed save, roll ward — on \(ward)+ ignore damage.",
                side: .defender,
                wardTarget: ward,
                source: unit.name
            )
        }
    }

    private static func parseWardThreshold(_ keyword: String) -> Int? {
        let pattern = /Ward \((\d+)\+\)/
        guard let match = keyword.firstMatch(of: pattern), let value = Int(match.1) else { return nil }
        return value
    }

    private static func parseAbilityBuffs(
        _ ability: TriggeredAbility,
        unit: SpearheadUnit,
        side: CombatMatchupSide
    ) -> [CombatMatchupBuff] {
        let effect = ability.effect.lowercased()
        var buffs: [CombatMatchupBuff] = []

        if effect.contains("add 1 to hit") {
            buffs.append(
                CombatMatchupBuff(
                    id: "\(unit.id)-\(ability.id)-hit",
                    name: ability.name,
                    summary: ability.effect,
                    side: side,
                    hitModifier: 1,
                    source: unit.name
                )
            )
        }

        if effect.contains("add 1 to wound") || effect.contains("add 1 to wound rolls") {
            buffs.append(
                CombatMatchupBuff(
                    id: "\(unit.id)-\(ability.id)-wound",
                    name: ability.name,
                    summary: ability.effect,
                    side: side,
                    woundModifier: 1,
                    source: unit.name
                )
            )
        }

        if effect.contains("subtract 1 from save") {
            buffs.append(
                CombatMatchupBuff(
                    id: "\(unit.id)-\(ability.id)-rend-save",
                    name: ability.name,
                    summary: ability.effect,
                    side: .defender,
                    saveModifier: -1,
                    source: unit.name
                )
            )
        }

        return buffs
    }
}

public struct MatchupUnitPrefill: Sendable, Equatable {
    public let armyId: String
    public let unitId: String
    public let weaponId: String?

    public init(armyId: String, unitId: String, weaponId: String? = nil) {
        self.armyId = armyId
        self.unitId = unitId
        self.weaponId = weaponId
    }
}
