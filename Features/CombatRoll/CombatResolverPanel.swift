import SwiftUI
import TabletomeDomain

struct CombatResolverPanel: View {
    enum Presentation {
        case standalone
        case embeddedInBattleTracker
    }

    @ObservedObject var viewModel: UnitMatchupEvaluatorViewModel
    @ObservedObject var multiAttackViewModel: MultiAttackEvaluatorViewModel
    @ObservedObject var batchViewModel: BatchCombatEvaluatorViewModel
    @Binding var diceInputModeRaw: String
    @Binding var showsAdvancedOptions: Bool
    @Binding var showsMultiAttack: Bool
    @Binding var showsAdvancedSingleAttack: Bool

    let ruleSections: [RuleSection]
    let presentation: Presentation
    var attackerPlayerName: String?
    var defenderPlayerName: String?
    var defenderWoundsRemaining: Int?
    var unitWoundsRemaining: [String: Int] = [:]
    let onSyncMultiAttack: () -> Void
    var onApplyDamage: ((Int, CombatBatchLogContext?) -> Void)?

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var showsCombatSequencePrimer = false

    private var isSimulated: Bool { diceInputMode == .simulated }
    private var locksArmies: Bool { presentation == .embeddedInBattleTracker }
    private var isEmbedded: Bool { presentation == .embeddedInBattleTracker }
    private var panelSpacing: CGFloat { isEmbedded ? DesignTokens.Spacing.md : DesignTokens.Spacing.lg }

    private var diceInputMode: DiceInputMode {
        get { DiceInputMode(rawValue: diceInputModeRaw) ?? .physical }
        nonmutating set { diceInputModeRaw = newValue.rawValue }
    }

    private var usesSideBySideMatchup: Bool {
        TabletomeLayout.usesSideBySideLayout(
            horizontalSizeClass: horizontalSizeClass,
            verticalSizeClass: verticalSizeClass,
            isAccessibilitySize: dynamicTypeSize.needsLayoutAdaptation
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: panelSpacing) {
            if presentation == .standalone {
                introSection
                CombatResolverMatchupPanelsSection(
                    viewModel: viewModel,
                    isEmbedded: isEmbedded,
                    locksArmies: locksArmies,
                    usesSideBySideMatchup: usesSideBySideMatchup,
                    unitWoundsRemaining: unitWoundsRemaining,
                    accessibilityPrefix: accessibilityPrefix
                )
                CombatResolverAttackProfileBarSection(
                    viewModel: viewModel,
                    isEmbedded: isEmbedded,
                    onSyncMultiAttack: onSyncMultiAttack
                )
                CombatResolverDeployedModelSection(
                    viewModel: viewModel,
                    accessibilityPrefix: accessibilityPrefix,
                    onSyncMultiAttack: onSyncMultiAttack
                )
                CombatResolverHitDiceBannerSection(
                    viewModel: viewModel,
                    accessibilityPrefix: accessibilityPrefix,
                    onSyncMultiAttack: onSyncMultiAttack
                )
                if !isSimulated {
                    CombatResolverBatchCombatSection(
                        batchViewModel: batchViewModel,
                        combatViewModel: viewModel,
                        accessibilityPrefix: accessibilityPrefix,
                        defenderWoundsRemaining: defenderWoundsRemaining,
                        onApplyDamage: onApplyDamage
                    )
                }
                CombatResolverPanelResultsSection(
                    viewModel: viewModel,
                    isEmbedded: isEmbedded,
                    accessibilityPrefix: accessibilityPrefix,
                    defenderWoundsRemaining: defenderWoundsRemaining,
                    onApplyDamage: onApplyDamage
                )
                CombatResolverPanelDiceSection(
                    viewModel: viewModel,
                    isEmbedded: isEmbedded,
                    isSimulated: isSimulated,
                    accessibilityPrefix: accessibilityPrefix
                )
                optionsSection
                CombatResolverSimulatedActionsSection(
                    viewModel: viewModel,
                    isSimulated: isSimulated,
                    accessibilityPrefix: accessibilityPrefix
                )
                CombatResolverMultiAttackSection(
                    viewModel: viewModel,
                    multiAttackViewModel: multiAttackViewModel,
                    showsMultiAttack: $showsMultiAttack,
                    ruleSections: ruleSections,
                    isEmbedded: isEmbedded,
                    isSimulated: isSimulated
                )
                CombatResolverReferenceLinksSection(
                    viewModel: viewModel,
                    ruleSections: ruleSections,
                    accessibilityPrefix: accessibilityPrefix
                )
            } else {
                CombatResolverEmbeddedContentSection(
                    viewModel: viewModel,
                    multiAttackViewModel: multiAttackViewModel,
                    batchViewModel: batchViewModel,
                    showsCombatSequencePrimer: $showsCombatSequencePrimer,
                    showsAdvancedSingleAttack: $showsAdvancedSingleAttack,
                    showsMultiAttack: $showsMultiAttack,
                    showsAdvancedOptions: $showsAdvancedOptions,
                    diceInputModeRaw: $diceInputModeRaw,
                    showsDiceInputMode: showsDiceInputMode,
                    ruleSections: ruleSections,
                    panelSpacing: panelSpacing,
                    isEmbedded: isEmbedded,
                    isSimulated: isSimulated,
                    accessibilityPrefix: accessibilityPrefix,
                    attackerPlayerName: attackerPlayerName,
                    defenderPlayerName: defenderPlayerName,
                    unitWoundsRemaining: unitWoundsRemaining,
                    defenderWoundsRemaining: defenderWoundsRemaining,
                    onSyncMultiAttack: onSyncMultiAttack,
                    onApplyDamage: onApplyDamage
                )
            }
        }
        .onChange(of: viewModel.attackerUnitId) { _, _ in
            onSyncMultiAttack()
            syncBatchCombat()
        }
        .onChange(of: viewModel.attackerDeployedModelCount) { _, _ in
            viewModel.clearVariableAttackResolution()
            onSyncMultiAttack()
            syncBatchCombat()
        }
        .onChange(of: viewModel.resolvedVariableAttackCount) { _, _ in
            onSyncMultiAttack()
            syncBatchCombat()
        }
        .onChange(of: viewModel.defenderUnitId) { _, _ in
            guard isEmbedded else { return }
            viewModel.applySuggestedDefenderWards()
            onSyncMultiAttack()
            syncBatchCombat()
        }
        .onChange(of: viewModel.attackerWeaponId) { _, _ in
            syncBatchCombat()
        }
        .onChange(of: viewModel.enabledBuffIds) { _, _ in
            syncBatchCombat()
        }
        .onChange(of: viewModel.damage) { _, _ in
            syncBatchCombat()
        }
        .onChange(of: viewModel.rollOptions) { _, _ in
            syncBatchCombat()
        }
        .onAppear {
            guard isEmbedded else { return }
            showsCombatSequencePrimer = !NewPlayerTipsStore.hasDismissedCombatSequencePrimer
            syncBatchCombat()
        }
    }

    private func syncBatchCombat() {
        batchViewModel.sync(from: viewModel)
    }

    private var introSection: some View {
        IntroCallout(
            text: isSimulated
                ? (CombatRollEngineRouter.usesWh40kRules(gameSystemId: viewModel.gameSystemId)
                    ? "Pick attacker and defender, enter your dice or tap Roll Attack, and see hit, save, and damage instantly."
                    : "Pick attacker and defender, enter your dice or tap Roll Attack, and see hit, save, ward, and damage instantly.")
                : "Pick attacker and defender, enter the dice you rolled at the table, and the result updates automatically.",
            systemImage: "arrow.left.arrow.right"
        )
    }

    private var optionsSection: some View {
        CombatResolverOptionsSection(
            viewModel: viewModel,
            showsAdvancedOptions: $showsAdvancedOptions,
            diceInputModeRaw: $diceInputModeRaw,
            showsDiceInputMode: showsDiceInputMode,
            isEmbedded: isEmbedded,
            accessibilityPrefix: accessibilityPrefix
        )
    }

    private var showsDiceInputMode: Bool {
        ReleaseSurface.allowsSimulatedDice(
            for: GameSystemId(resolving: viewModel.gameSystemId)
        )
    }

    private var accessibilityPrefix: String {
        presentation == .embeddedInBattleTracker ? "battleTracker.combatResolver" : "matchup"
    }
}
