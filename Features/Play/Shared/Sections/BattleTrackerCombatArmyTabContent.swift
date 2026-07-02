import SwiftUI
import TabletomeDomain
import TabletomeData

struct BattleTrackerCombatTabContent<
    CombatActivation: View,
    PhoneLandscapeSplit: View
>: View {
    let showsActivationBar: Bool
    let usesPhoneLandscapeCombatSplit: Bool
    let showsDedicatedCombatTab: Bool
    let showsCombatResolver: Bool
    let showsSpearheadBattleChrome: Bool
    let isCombatPhase: Bool
    let showsShootingHelper: Bool
    let shootingUnits: [SpearheadUnit]
    let armyName: String
    let gameSystemId: GameSystemId
    let onSelectShootingUnit: (String) -> Void
    let showsShootInCombatHelper: Bool
    let shootInCombatUnits: [SpearheadUnit]
    let onSelectShootInCombatUnit: (String, String) -> Void
    let damageUndoNotice: DamageUndoNotice?
    let reduceMotion: Bool
    let onUndoDamage: () -> Void
    let onDismissDamageUndo: () -> Void
    @ObservedObject var combatViewModel: UnitMatchupEvaluatorViewModel
    @ObservedObject var multiAttackViewModel: MultiAttackEvaluatorViewModel
    @ObservedObject var batchCombatViewModel: BatchCombatEvaluatorViewModel
    @Binding var showsCombatResolverPanel: Bool
    @Binding var diceInputModeRaw: String
    @Binding var showsAdvancedOptions: Bool
    @Binding var showsMultiAttack: Bool
    @Binding var showsAdvancedSingleAttack: Bool
    let trackerState: BattleTrackerState
    let attackerName: String
    let defenderName: String
    let deploymentIsComplete: Bool
    let defenderWoundsRemaining: Int?
    let unitWoundsRemaining: [String: Int]
    let ruleSections: [RuleSection]
    let onSyncMultiAttack: () -> Void
    let onApplyDamage: (Int, CombatBatchLogContext?) -> Void
    let showsArmyTracker: Bool
    let playerOneName: String
    let playerTwoName: String
    let playerOneArmy: SpearheadArmy?
    let playerTwoArmy: SpearheadArmy?
    let healthPerModelOverrides: [String: Int]
    let activePlayerIsOne: Bool
    let calledReinforcementUnitKeys: Set<String>
    let onUnitWoundsChange: (String, Int) -> Void
    let onSelectArmyUnit: (String, String) -> Void
    @ViewBuilder let combatActivation: () -> CombatActivation
    @ViewBuilder let phoneLandscapeSplit: () -> PhoneLandscapeSplit

    var body: some View {
        Group {
            if showsActivationBar {
                BattleTrackerSCCombatTabContent()
            } else if usesPhoneLandscapeCombatSplit {
                phoneLandscapeSplit()
            } else {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                    if showsDedicatedCombatTab {
                        BattleTrackerShootingPhaseHelperSection(
                            isVisible: showsShootingHelper,
                            units: shootingUnits,
                            armyName: armyName,
                            gameSystemId: gameSystemId,
                            onSelectUnit: onSelectShootingUnit
                        )
                    }
                    combatActivation()
                    BattleTrackerCombatResolverTabSection(
                        combatViewModel: combatViewModel,
                        multiAttackViewModel: multiAttackViewModel,
                        batchCombatViewModel: batchCombatViewModel,
                        showsCombatResolver: $showsCombatResolverPanel,
                        diceInputModeRaw: $diceInputModeRaw,
                        showsAdvancedOptions: $showsAdvancedOptions,
                        showsMultiAttack: $showsMultiAttack,
                        showsAdvancedSingleAttack: $showsAdvancedSingleAttack,
                        isVisible: showsCombatResolver,
                        trackerState: trackerState,
                        attackerName: attackerName,
                        defenderName: defenderName,
                        deploymentIsComplete: deploymentIsComplete,
                        defenderWoundsRemaining: defenderWoundsRemaining,
                        unitWoundsRemaining: unitWoundsRemaining,
                        ruleSections: ruleSections,
                        onSyncMultiAttack: onSyncMultiAttack,
                        onApplyDamage: onApplyDamage
                    )
                    BattleTrackerDamageUndoSection(
                        notice: damageUndoNotice,
                        reduceMotion: reduceMotion,
                        onUndo: onUndoDamage,
                        onDismiss: onDismissDamageUndo
                    )
                    BattleTrackerCombatPhaseHelperSection(
                        isVisible: showsSpearheadBattleChrome && isCombatPhase
                    )
                    BattleTrackerShootInCombatPhaseHelperSection(
                        isVisible: showsShootInCombatHelper,
                        units: shootInCombatUnits,
                        onSelectUnit: onSelectShootInCombatUnit
                    )
                    BattleTrackerArmyTrackerSection(
                        isVisible: showsArmyTracker,
                        playerOneName: playerOneName,
                        playerTwoName: playerTwoName,
                        playerOneArmy: playerOneArmy,
                        playerTwoArmy: playerTwoArmy,
                        unitWoundsRemaining: unitWoundsRemaining,
                        healthPerModelOverrides: healthPerModelOverrides,
                        activePlayerIsOne: activePlayerIsOne,
                        usesWideLayout: false,
                        usesCompactSidebar: false,
                        gameSystemId: gameSystemId,
                        calledReinforcementUnitKeys: calledReinforcementUnitKeys,
                        onChange: onUnitWoundsChange,
                        onSelectUnit: onSelectArmyUnit
                    )
                }
            }
        }
    }
}

struct BattleTrackerArmyTabContent<
    SecondarySections: View,
    PassiveAbilities: View
>: View {
    @ObservedObject var viewModel: BattlePhaseTrackerViewModel
    let showsArmyTracker: Bool
    let playerOneName: String
    let playerTwoName: String
    let playerOneArmy: SpearheadArmy?
    let playerTwoArmy: SpearheadArmy?
    let unitWoundsRemaining: [String: Int]
    let healthPerModelOverrides: [String: Int]
    let activePlayerIsOne: Bool
    let gameSystemId: GameSystemId
    let calledReinforcementUnitKeys: Set<String>
    let onUnitWoundsChange: (String, Int) -> Void
    let onSelectArmyUnit: (String, String) -> Void
    let ruleSections: [RuleSection]
    let supportsBattleTracker: Bool
    let showsActivationBar: Bool
    let usesGuidedBattleTracker: Bool
    let showsEmbeddedCombatTools: Bool
    let onResolveAttack: (TriggeredAbility) -> Void
    @ViewBuilder let secondarySections: () -> SecondarySections
    @ViewBuilder let passiveAbilities: () -> PassiveAbilities

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            BattleTrackerArmyTrackerSection(
                isVisible: showsArmyTracker,
                playerOneName: playerOneName,
                playerTwoName: playerTwoName,
                playerOneArmy: playerOneArmy,
                playerTwoArmy: playerTwoArmy,
                unitWoundsRemaining: unitWoundsRemaining,
                healthPerModelOverrides: healthPerModelOverrides,
                activePlayerIsOne: activePlayerIsOne,
                usesWideLayout: false,
                usesCompactSidebar: false,
                gameSystemId: gameSystemId,
                calledReinforcementUnitKeys: calledReinforcementUnitKeys,
                onChange: onUnitWoundsChange,
                onSelectUnit: onSelectArmyUnit
            )
            if viewModel.trackerState.showAllAbilities {
                BattleTrackerContentSection(
                    viewModel: viewModel,
                    ruleSections: ruleSections,
                    supportsBattleTracker: supportsBattleTracker,
                    showsActivationBar: showsActivationBar,
                    usesGuidedBattleTracker: usesGuidedBattleTracker,
                    showsEmbeddedCombatTools: showsEmbeddedCombatTools,
                    onResolveAttack: onResolveAttack
                )
            } else {
                passiveAbilities()
            }
            secondarySections()
        }
    }
}
