import Foundation

public enum PlayerLoadoutPreferencesApplicator: Sendable {
    public static func apply(
        to player: inout PlayerArmySelection,
        profile: PlayerProfile?,
        army: SpearheadArmy
    ) {
        let prefs = profile?.guidedMatchPreferences

        if let regimentId = prefs?.defaultRegimentAbilityByArmyId[army.id],
           army.regimentAbilities.contains(where: { $0.id == regimentId }) {
            player.regimentAbilityId = regimentId
        } else if let regiment = ArmyRuleOption.recommendedDefault(in: army.regimentAbilities) {
            player.regimentAbilityId = regiment.id
        }

        if let enhancementId = prefs?.defaultEnhancementByArmyId[army.id],
           army.enhancements.contains(where: { $0.id == enhancementId }) {
            player.enhancementId = enhancementId
        } else if let enhancement = ArmyRuleOption.recommendedDefault(in: army.enhancements) {
            player.enhancementId = enhancement.id
        }

        if let secondary = ArmyRuleOption.recommendedDefault(in: army.secondaryObjectives) {
            player.secondaryObjectiveId = secondary.id
        }
    }
}
