import SwiftUI
import TabletomeDomain
import TabletomeData

struct BattleTrackerCombatResolverTabSection: View {
    @ObservedObject var combatViewModel: UnitMatchupEvaluatorViewModel
    @ObservedObject var multiAttackViewModel: MultiAttackEvaluatorViewModel
    @ObservedObject var batchCombatViewModel: BatchCombatEvaluatorViewModel
    @Binding var showsCombatResolver: Bool
    @Binding var diceInputModeRaw: String
    @Binding var showsAdvancedOptions: Bool
    @Binding var showsMultiAttack: Bool
    @Binding var showsAdvancedSingleAttack: Bool
    let isVisible: Bool
    let trackerState: BattleTrackerState
    let attackerName: String
    let defenderName: String
    let deploymentIsComplete: Bool
    let defenderWoundsRemaining: Int?
    let unitWoundsRemaining: [String: Int]
    let ruleSections: [RuleSection]
    let onSyncMultiAttack: () -> Void
    let onApplyDamage: (Int, CombatBatchLogContext?) -> Void
    var usesLandscapeSplitPresentation: Bool = false

    var body: some View {
        if isVisible {
            BattleTrackerCombatResolverSection(
                combatViewModel: combatViewModel,
                multiAttackViewModel: multiAttackViewModel,
                batchCombatViewModel: batchCombatViewModel,
                showsCombatResolver: $showsCombatResolver,
                diceInputModeRaw: $diceInputModeRaw,
                showsAdvancedOptions: $showsAdvancedOptions,
                showsMultiAttack: $showsMultiAttack,
                showsAdvancedSingleAttack: $showsAdvancedSingleAttack,
                trackerState: trackerState,
                attackerName: attackerName,
                defenderName: defenderName,
                deploymentIsComplete: deploymentIsComplete,
                defenderWoundsRemaining: defenderWoundsRemaining,
                unitWoundsRemaining: unitWoundsRemaining,
                ruleSections: ruleSections,
                onSyncMultiAttack: onSyncMultiAttack,
                onApplyDamage: onApplyDamage,
                usesLandscapeSplitPresentation: usesLandscapeSplitPresentation
            )
        }
    }
}
