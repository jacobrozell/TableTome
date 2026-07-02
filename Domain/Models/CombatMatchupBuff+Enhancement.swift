import Foundation

extension CombatMatchupBuffCatalog {
    /// Generates buffs from a selected enhancement for the general.
    public static func enhancementBuffs(
        for enhancement: ArmyRuleOption?,
        generalUnit: SpearheadUnit?,
        defenderUnit: SpearheadUnit?
    ) -> [CombatMatchupBuff] {
        guard let enhancement, let generalUnit, let defenderUnit else { return [] }

        // Enhancement only applies if the defending unit is the general
        guard generalUnit.id == defenderUnit.id else { return [] }

        return parseEnhancementEffects(enhancement, generalName: generalUnit.name)
    }

    /// Parses enhancement summary for combat effects.
    private static func parseEnhancementEffects(
        _ enhancement: ArmyRuleOption,
        generalName: String
    ) -> [CombatMatchupBuff] {
        let text = enhancement.summary.lowercased()
        var buffs: [CombatMatchupBuff] = []

        // Ward detection
        if let wardMatch = text.firstMatch(of: /ward\s*\(?\s*(\d+)\+?\)?/) {
            if let wardValue = Int(wardMatch.1) {
                buffs.append(
                    CombatMatchupBuff(
                        id: "enhancement-\(enhancement.id)-ward",
                        name: "Ward (\(wardValue)+)",
                        summary: enhancement.summary,
                        side: .defender,
                        wardTarget: wardValue,
                        source: enhancement.name
                    )
                )
            }
        }

        // +1 to hit for attacker (enhancement on general attacking)
        if text.contains("+1 to hit") || text.contains("add 1 to hit") {
            buffs.append(
                CombatMatchupBuff(
                    id: "enhancement-\(enhancement.id)-hit",
                    name: "+1 to Hit",
                    summary: enhancement.summary,
                    side: .attacker,
                    hitModifier: 1,
                    source: enhancement.name
                )
            )
        }

        // +1 to wound
        if text.contains("+1 to wound") || text.contains("add 1 to wound") {
            buffs.append(
                CombatMatchupBuff(
                    id: "enhancement-\(enhancement.id)-wound",
                    name: "+1 to Wound",
                    summary: enhancement.summary,
                    side: .attacker,
                    woundModifier: 1,
                    source: enhancement.name
                )
            )
        }

        // +1 to save
        if text.contains("+1 to save") || text.contains("add 1 to save") || text.contains("improve.*save") {
            buffs.append(
                CombatMatchupBuff(
                    id: "enhancement-\(enhancement.id)-save",
                    name: "+1 to Save",
                    summary: enhancement.summary,
                    side: .defender,
                    saveModifier: 1,
                    source: enhancement.name
                )
            )
        }

        // -1 to hit against (enemy attacking this unit)
        if text.contains("-1 to hit") && (text.contains("against") || text.contains("targeting")) {
            buffs.append(
                CombatMatchupBuff(
                    id: "enhancement-\(enhancement.id)-hit-debuff",
                    name: "-1 to Hit (enemy)",
                    summary: enhancement.summary,
                    side: .attacker,
                    hitModifier: -1,
                    source: enhancement.name
                )
            )
        }

        return buffs
    }

    /// Extended matchup buffs that include enhancement effects.
    public static func matchupBuffsWithEnhancement(
        attacker: SpearheadUnit?,
        defender: SpearheadUnit?,
        weapon: SpearheadWeapon? = nil,
        defenderEnhancement: ArmyRuleOption?,
        defenderGeneral: SpearheadUnit?
    ) -> [CombatMatchupBuff] {
        var result = matchupBuffs(attacker: attacker, defender: defender, weapon: weapon)

        // Add enhancement buffs if defender is the general
        let enhancementBuffs = enhancementBuffs(
            for: defenderEnhancement,
            generalUnit: defenderGeneral,
            defenderUnit: defender
        )
        result.append(contentsOf: enhancementBuffs)

        return result
    }

    /// Returns suggested enabled buff IDs including enhancement ward.
    public static func suggestedBuffIds(
        for defender: SpearheadUnit?,
        enhancement: ArmyRuleOption?,
        isGeneral: Bool
    ) -> Set<String> {
        var suggested = suggestedWardBuffIds(for: defender)

        // Auto-enable enhancement ward if unit is general
        if isGeneral, let enhancement {
            let enhBuffs = parseEnhancementEffects(enhancement, generalName: defender?.name ?? "")
            for buff in enhBuffs where buff.wardTarget != nil {
                suggested.insert(buff.id)
            }
        }

        return suggested
    }
}
