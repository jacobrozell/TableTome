import SwiftUI
import TabletomeDomain
import TabletomeData

struct BattleTrackerPadCombatColumns<
    CombatActivation: View
>: View {
    let showsActivationBar: Bool
    let isEmbeddedInGuidedMatch: Bool
    let sidebarColumnMaxWidth: CGFloat
    let embeddedSidebarMaxWidth: CGFloat
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

    var body: some View {
        if showsActivationBar {
            BattleTrackerSCCombatTabContent()
        } else if isEmbeddedInGuidedMatch {
            BattleTrackerEmbeddedPadCombatLayout(
                embeddedSidebarMaxWidth: embeddedSidebarMaxWidth,
                showsDedicatedCombatTab: showsDedicatedCombatTab,
                showsShootingHelper: showsShootingHelper,
                shootingUnits: shootingUnits,
                armyName: armyName,
                gameSystemId: gameSystemId,
                onSelectShootingUnit: onSelectShootingUnit,
                showsSpearheadBattleChrome: showsSpearheadBattleChrome,
                isCombatPhase: isCombatPhase,
                showsShootInCombatHelper: showsShootInCombatHelper,
                shootInCombatUnits: shootInCombatUnits,
                onSelectShootInCombatUnit: onSelectShootInCombatUnit,
                damageUndoNotice: damageUndoNotice,
                reduceMotion: reduceMotion,
                onUndoDamage: onUndoDamage,
                onDismissDamageUndo: onDismissDamageUndo,
                combatViewModel: combatViewModel,
                multiAttackViewModel: multiAttackViewModel,
                batchCombatViewModel: batchCombatViewModel,
                showsCombatResolverPanel: $showsCombatResolverPanel,
                diceInputModeRaw: $diceInputModeRaw,
                showsAdvancedOptions: $showsAdvancedOptions,
                showsMultiAttack: $showsMultiAttack,
                showsAdvancedSingleAttack: $showsAdvancedSingleAttack,
                showsCombatResolver: showsCombatResolver,
                trackerState: trackerState,
                attackerName: attackerName,
                defenderName: defenderName,
                deploymentIsComplete: deploymentIsComplete,
                defenderWoundsRemaining: defenderWoundsRemaining,
                unitWoundsRemaining: unitWoundsRemaining,
                ruleSections: ruleSections,
                onSyncMultiAttack: onSyncMultiAttack,
                onApplyDamage: onApplyDamage,
                showsArmyTracker: showsArmyTracker,
                playerOneName: playerOneName,
                playerTwoName: playerTwoName,
                playerOneArmy: playerOneArmy,
                playerTwoArmy: playerTwoArmy,
                healthPerModelOverrides: healthPerModelOverrides,
                activePlayerIsOne: activePlayerIsOne,
                calledReinforcementUnitKeys: calledReinforcementUnitKeys,
                onUnitWoundsChange: onUnitWoundsChange,
                onSelectArmyUnit: onSelectArmyUnit,
                combatActivation: combatActivation
            )
        } else {
            BattleTrackerPadTwoColumnRow(
                controlColumnMaxWidth: sidebarColumnMaxWidth,
                balance: .contentPrimary
            ) {
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
                    onApplyDamage: onApplyDamage,
                    usesLandscapeSplitPresentation: true
                )
                BattleTrackerDamageUndoSection(
                    notice: damageUndoNotice,
                    reduceMotion: reduceMotion,
                    onUndo: onUndoDamage,
                    onDismiss: onDismissDamageUndo
                )
            } secondary: {
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
                    usesWideLayout: true,
                    usesCompactSidebar: true,
                    gameSystemId: gameSystemId,
                    calledReinforcementUnitKeys: calledReinforcementUnitKeys,
                    onChange: onUnitWoundsChange,
                    onSelectUnit: onSelectArmyUnit
                )
            }
        }
    }
}

struct BattleTrackerEmbeddedPadCombatLayout<
    CombatActivation: View
>: View {
    let embeddedSidebarMaxWidth: CGFloat
    let showsDedicatedCombatTab: Bool
    let showsShootingHelper: Bool
    let shootingUnits: [SpearheadUnit]
    let armyName: String
    let gameSystemId: GameSystemId
    let onSelectShootingUnit: (String) -> Void
    let showsSpearheadBattleChrome: Bool
    let isCombatPhase: Bool
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
    let showsCombatResolver: Bool
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

    var body: some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.md) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
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
                    onApplyDamage: onApplyDamage,
                    usesLandscapeSplitPresentation: true
                )
                BattleTrackerDamageUndoSection(
                    notice: damageUndoNotice,
                    reduceMotion: reduceMotion,
                    onUndo: onUndoDamage,
                    onDismiss: onDismissDamageUndo
                )
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .layoutPriority(1)

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
                    usesWideLayout: true,
                    usesCompactSidebar: true,
                    gameSystemId: gameSystemId,
                    calledReinforcementUnitKeys: calledReinforcementUnitKeys,
                    onChange: onUnitWoundsChange,
                    onSelectUnit: onSelectArmyUnit
                )
            }
            .frame(minWidth: 0, maxWidth: embeddedSidebarMaxWidth, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityIdentifier("battleTracker.embeddedPadCombatLayout")
    }
}

struct BattleTrackerPadArmyColumns<
    SecondarySections: View,
    PassiveAbilities: View
>: View {
    let controlColumnMaxWidth: CGFloat
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
        BattleTrackerPadTwoColumnRow(
            controlColumnMaxWidth: controlColumnMaxWidth,
            balance: .contentPrimary
        ) {
            BattleTrackerArmyTrackerSection(
                isVisible: showsArmyTracker,
                playerOneName: playerOneName,
                playerTwoName: playerTwoName,
                playerOneArmy: playerOneArmy,
                playerTwoArmy: playerTwoArmy,
                unitWoundsRemaining: unitWoundsRemaining,
                healthPerModelOverrides: healthPerModelOverrides,
                activePlayerIsOne: activePlayerIsOne,
                usesWideLayout: true,
                usesCompactSidebar: true,
                gameSystemId: gameSystemId,
                calledReinforcementUnitKeys: calledReinforcementUnitKeys,
                onChange: onUnitWoundsChange,
                onSelectUnit: onSelectArmyUnit
            )
        } secondary: {
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
