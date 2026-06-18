import Foundation

public enum SpearheadArmyMerger {
    public static func merged(base: SpearheadArmy, detail: SpearheadArmyDetail) -> SpearheadArmy {
        guard base.id == detail.armyId else { return base }

        return SpearheadArmy(
            id: base.id,
            name: base.name,
            general: base.general,
            tagline: base.tagline,
            playstyle: base.playstyle,
            unitCount: base.unitCount,
            roster: base.roster,
            battleTraitName: base.battleTraitName,
            officialRulesURL: base.officialRulesURL,
            battleTraits: detail.battleTraits ?? base.battleTraits,
            regimentAbilities: base.regimentAbilities,
            enhancements: base.enhancements,
            secondaryObjectives: base.secondaryObjectives,
            stratagems: base.stratagems,
            units: detail.units ?? base.units
        )
    }
}
