import SwiftUI
import TabletomeDomain
import TabletomeData

struct UnitMatchupEvaluatorView: View {
    @StateObject private var viewModel: UnitMatchupEvaluatorViewModel
    @StateObject private var multiAttackViewModel = MultiAttackEvaluatorViewModel()
    @StateObject private var batchCombatViewModel = BatchCombatEvaluatorViewModel()
    @AppStorage("diceInputMode") private var diceInputModeRaw = DiceInputMode.physical.rawValue
    @State private var showsAdvancedOptions = false
    @State private var showsMultiAttack = false
    @State private var showsAdvancedSingleAttack = false
    let ruleSections: [RuleSection]

    init(
        ruleSections: [RuleSection] = [],
        gameSystemId: String = "aos-spearhead",
        catalogRepository: (any SpearheadCatalogRepository)? = nil,
        attackerPrefill: MatchupUnitPrefill? = nil,
        defenderPrefill: MatchupUnitPrefill? = nil
    ) {
        let repository = catalogRepository ?? Self.catalogRepository(for: gameSystemId)
        _viewModel = StateObject(
            wrappedValue: UnitMatchupEvaluatorViewModel(
                catalogRepository: repository,
                gameSystemId: gameSystemId,
                attackerPrefill: attackerPrefill,
                defenderPrefill: defenderPrefill
            )
        )
        self.ruleSections = ruleSections
    }

    private static func catalogRepository(for gameSystemId: String) -> any SpearheadCatalogRepository {
        GameSystemCatalogRepository(
            gameSystemId: gameSystemId,
            repository: BundledPlayCatalogRepository()
        )
    }

    var body: some View {
        Group {
            if let errorMessage = viewModel.errorMessage {
                EmptyStateView(title: String(localized: "Unavailable"), message: errorMessage)
            } else if viewModel.armies.isEmpty {
                ProgressView()
            } else {
                ScrollView {
                    CombatResolverPanel(
                        viewModel: viewModel,
                        multiAttackViewModel: multiAttackViewModel,
                        batchViewModel: batchCombatViewModel,
                        diceInputModeRaw: $diceInputModeRaw,
                        showsAdvancedOptions: $showsAdvancedOptions,
                        showsMultiAttack: $showsMultiAttack,
                        showsAdvancedSingleAttack: $showsAdvancedSingleAttack,
                        ruleSections: ruleSections,
                        presentation: .standalone,
                        onSyncMultiAttack: syncMultiAttack
                    )
                    .readableContentWidth()
                    .padding(DesignTokens.Spacing.md)
                }
                .tabBarScrollInset()
            }
        }
        .navigationTitle(String(localized: "Combat Resolver"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(String(localized: "Reset")) {
                    viewModel.resetAll()
                }
                .accessibilityIdentifier("matchup.reset")
            }
        }
        .accessibilityIdentifier("matchup.screen")
        .task { await viewModel.load() }
        .onChange(of: diceInputModeRaw) { _, _ in
            viewModel.clearSimulatedRolls()
            multiAttackViewModel.clearSimulatedRolls()
        }
        .onChange(of: viewModel.enabledBuffIds) { _, _ in
            syncMultiAttack()
            viewModel.refreshEvaluation()
        }
        .onChange(of: viewModel.hitRoll) { _, _ in viewModel.refreshEvaluation() }
        .onChange(of: viewModel.woundRoll) { _, _ in viewModel.refreshEvaluation() }
        .onChange(of: viewModel.saveRoll) { _, _ in viewModel.refreshEvaluation() }
        .onChange(of: viewModel.wardRoll) { _, _ in viewModel.refreshEvaluation() }
        .onChange(of: viewModel.damage) { _, _ in viewModel.refreshEvaluation() }
        .onChange(of: viewModel.rollOptions) { _, _ in viewModel.refreshEvaluation() }
        .onChange(of: viewModel.attackerWeaponId) { _, _ in syncMultiAttack() }
        .onChange(of: viewModel.defenderUnitId) { _, _ in syncMultiAttack() }
    }

    private func syncMultiAttack() {
        guard let weapon = viewModel.selectedAttackerWeapon,
              let unit = viewModel.selectedAttackerUnit,
              let save = viewModel.selectedDefenderUnit?.save else { return }
        let mods = CombatMatchupBuffCatalog.aggregateModifiers(
            from: viewModel.matchupBuffs,
            enabledIds: viewModel.enabledBuffIds
        )
        multiAttackViewModel.apply(
            weapon: weapon,
            saveTarget: save,
            unitId: unit.id,
            deployedModelCount: viewModel.attackerDeployedModelCount,
            wardTarget: CombatRollEngineRouter.usesWh40kRules(gameSystemId: viewModel.gameSystemId)
                ? nil
                : viewModel.activeWardTarget,
            resolvedAttackCount: viewModel.resolvedVariableAttackCount
        )
        multiAttackViewModel.bind(
            weapon: weapon,
            unitId: unit.id,
            unitModelCount: unit.modelCount
        )
        multiAttackViewModel.hitModifier = mods.hit
        multiAttackViewModel.woundModifier = mods.wound
        multiAttackViewModel.saveModifier = mods.save
        multiAttackViewModel.damage = viewModel.damage
    }
}
