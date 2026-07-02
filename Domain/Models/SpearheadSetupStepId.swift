import Foundation

public enum SpearheadSetupStepId {
    public static let preBattleLoadout = "pre-battle-loadout"
    private static let legacyRegimentAbilities = "regiment-abilities"
    private static let legacyEnhancements = "enhancements"

    public static func migrateLegacyCompletedStepIds(_ completedStepIds: inout Set<String>) {
        let hadRegiment = completedStepIds.contains(legacyRegimentAbilities)
        let hadEnhancements = completedStepIds.contains(legacyEnhancements)
        guard hadRegiment || hadEnhancements else { return }

        completedStepIds.remove(legacyRegimentAbilities)
        completedStepIds.remove(legacyEnhancements)
        if hadRegiment && hadEnhancements {
            completedStepIds.insert(preBattleLoadout)
        }
    }
}
