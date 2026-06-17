import SwiftUI
import TabletomeDomain
import TabletomeData

struct BattlePhaseTrackerView: View {
    @StateObject private var viewModel: BattlePhaseTrackerViewModel
    @StateObject private var combatViewModel: UnitMatchupEvaluatorViewModel
    @StateObject private var multiAttackViewModel = MultiAttackEvaluatorViewModel()
    @AppStorage("diceInputMode") private var diceInputModeRaw = DiceInputMode.physical.rawValue
    @State private var showsCombatResolver = false
    @State private var showsAdvancedOptions = false
    @State private var showsMultiAttack = false
    @State private var scrollToCombatResolver = false
    @State private var showsBattleTrackerCoach = false
    @State private var turnHandoffNotice: TurnHandoffNotice?
    @State private var handoffBaselineEstablished = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    let ruleSections: [RuleSection]

    init(matchState: GuidedMatchState, catalog: SpearheadCatalog, ruleSections: [RuleSection] = []) {
        _viewModel = StateObject(wrappedValue: BattlePhaseTrackerViewModel(matchState: matchState, catalog: catalog))
        _combatViewModel = StateObject(
            wrappedValue: UnitMatchupEvaluatorViewModel(
                catalogRepository: BundledSpearheadCatalogRepository(),
                attackerPrefill: Self.matchupPrefill(for: matchState.playerOne),
                defenderPrefill: Self.matchupPrefill(for: matchState.playerTwo)
            )
        )
        self.ruleSections = ruleSections
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical) {
                Group {
                    if horizontalSizeClass == .regular {
                        regularLayout
                    } else {
                        compactLayout
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .readableContentWidth()
                .padding(DesignTokens.Spacing.md)
            }
            .scrollBounceBehavior(.basedOnSize, axes: .vertical)
            .tabBarScrollInset()
            .onChange(of: viewModel.trackerState.currentPhase) { oldPhase, phase in
                if phase.isCombatRelated {
                    requestCombatResolverFocus(using: proxy)
                }
                if handoffBaselineEstablished {
                    presentTurnHandoff(from: oldPhase, to: phase, playerChanged: false)
                }
            }
            .onChange(of: viewModel.trackerState.activePlayerIsOne) { oldValue, _ in
                syncCombatContext()
                requestCombatResolverFocus(using: proxy)
                if handoffBaselineEstablished {
                    presentTurnHandoff(
                        from: viewModel.trackerState.currentPhase,
                        to: viewModel.trackerState.currentPhase,
                        playerChanged: oldValue != viewModel.trackerState.activePlayerIsOne
                    )
                }
            }
            .onChange(of: turnHandoffNotice) { _, notice in
                guard notice != nil else { return }
                let current = notice
                Task {
                    try? await Task.sleep(for: .seconds(5))
                    if turnHandoffNotice == current {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            turnHandoffNotice = nil
                        }
                    }
                }
            }
            .onChange(of: scrollToCombatResolver) { _, shouldScroll in
                guard shouldScroll else { return }
                showsCombatResolver = true
                withAnimation(.easeInOut(duration: 0.35)) {
                    proxy.scrollTo("combatResolver", anchor: .top)
                }
                scrollToCombatResolver = false
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if supportsBattleTracker, viewModel.trackerState.currentPhase.isCombatRelated {
                BattleTrackerStickyCombatBar(
                    attackerName: combatAttackerName,
                    defenderName: combatDefenderName,
                    phaseTitle: viewModel.trackerState.currentPhase.title,
                    onTap: { scrollToCombatResolver = true }
                )
            }
        }
        .navigationTitle(String(localized: "Battle Tracker"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(String(localized: "Reset")) {
                    viewModel.resetTracker()
                }
                .accessibilityIdentifier("battleTracker.reset")
            }
        }
        .accessibilityIdentifier("battleTracker.screen")
        .onAppear {
            showsBattleTrackerCoach = supportsBattleTracker && !NewPlayerTipsStore.hasSeenBattleTrackerCoach
            Task {
                try? await Task.sleep(for: .milliseconds(400))
                handoffBaselineEstablished = true
            }
        }
        .task {
            await combatViewModel.load()
            syncCombatContext()
        }
        .onChange(of: diceInputModeRaw) { _, _ in
            combatViewModel.clearSimulatedRolls()
            multiAttackViewModel.clearSimulatedRolls()
        }
        .onChange(of: combatViewModel.enabledBuffIds) { _, _ in
            syncMultiAttack()
            combatViewModel.refreshEvaluation()
        }
        .onChange(of: combatViewModel.hitRoll) { _, _ in combatViewModel.refreshEvaluation() }
        .onChange(of: combatViewModel.woundRoll) { _, _ in combatViewModel.refreshEvaluation() }
        .onChange(of: combatViewModel.saveRoll) { _, _ in combatViewModel.refreshEvaluation() }
        .onChange(of: combatViewModel.wardRoll) { _, _ in combatViewModel.refreshEvaluation() }
        .onChange(of: combatViewModel.damage) { _, _ in combatViewModel.refreshEvaluation() }
        .onChange(of: combatViewModel.rollOptions) { _, _ in combatViewModel.refreshEvaluation() }
        .onChange(of: combatViewModel.attackerWeaponId) { _, _ in syncMultiAttack() }
        .onChange(of: combatViewModel.defenderUnitId) { _, _ in syncMultiAttack() }
    }

    private var compactLayout: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            coachSection
            turnHandoffSection
            guideSection
            roundAndScoreSection
            BattleTrackerControlPanel(viewModel: viewModel)
            combatResolverSection
            trackerContent
            deploymentSection
            secondarySections
        }
        .animation(.easeInOut(duration: 0.25), value: showsBattleTrackerCoach)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var regularLayout: some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.lg) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                coachSection
                turnHandoffSection
                guideSection
                deploymentSection
                roundAndScoreSection
                BattleTrackerControlPanel(viewModel: viewModel)
                secondarySections
            }
            .frame(minWidth: 0, maxWidth: DesignTokens.battleTrackerControlColumnMaxWidth, alignment: .leading)
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                combatResolverSection
                trackerContent
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var turnHandoffSection: some View {
        if let notice = turnHandoffNotice {
            BattleTrackerTurnHandoffBanner(
                title: notice.title,
                detail: notice.detail,
                onDismiss: {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        turnHandoffNotice = nil
                    }
                }
            )
            .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }

    @ViewBuilder
    private var coachSection: some View {
        if supportsBattleTracker, showsBattleTrackerCoach {
            BattleTrackerCoachCard {
                withAnimation(.easeInOut(duration: 0.25)) {
                    NewPlayerTipsStore.markBattleTrackerCoachSeen()
                    showsBattleTrackerCoach = false
                }
            }
            .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }

    @ViewBuilder
    private var guideSection: some View {
        if let step = viewModel.currentGuideStep {
            BattleGuideCard(step: step) {
                viewModel.completeCurrentGuideStep()
            }
        }
    }

    @ViewBuilder
    private var combatResolverSection: some View {
        if supportsBattleTracker {
            BattleTrackerCombatResolverSection(
                combatViewModel: combatViewModel,
                multiAttackViewModel: multiAttackViewModel,
                showsCombatResolver: $showsCombatResolver,
                diceInputModeRaw: $diceInputModeRaw,
                showsAdvancedOptions: $showsAdvancedOptions,
                showsMultiAttack: $showsMultiAttack,
                trackerState: viewModel.trackerState,
                attackerName: combatAttackerName,
                defenderName: combatDefenderName,
                deploymentIsComplete: deploymentIsComplete,
                defenderWoundsRemaining: defenderWoundsRemaining,
                unitWoundsRemaining: viewModel.trackerState.unitWoundsRemaining,
                ruleSections: ruleSections,
                onSyncMultiAttack: syncMultiAttack,
                onApplyDamage: applyCombatDamage
            )
        }
    }

    @ViewBuilder
    private var deploymentSection: some View {
        if viewModel.trackerState.battleRound == 1, !deploymentIsComplete {
            RealmSideCoinFlipCard()
            DeploymentChecklistCard(
                completedSteps: viewModel.trackerState.completedDeploymentSteps,
                focusedStep: viewModel.focusedDeploymentStep,
                onToggle: viewModel.setDeploymentStep
            )
        }
    }

    private var roundAndScoreSection: some View {
        BattleTrackerRoundAndScoreSection(viewModel: viewModel)
    }

    @ViewBuilder
    private var secondarySections: some View {
        BattleTrackerBothLoadoutsSection(
            playerOneName: viewModel.playerOneName,
            playerTwoName: viewModel.playerTwoName,
            playerOneArmy: viewModel.playerOneArmy,
            playerTwoArmy: viewModel.playerTwoArmy,
            playerOneRegimentAbility: viewModel.playerOneRegimentAbility,
            playerTwoRegimentAbility: viewModel.playerTwoRegimentAbility,
            playerOneEnhancement: viewModel.playerOneEnhancement,
            playerTwoEnhancement: viewModel.playerTwoEnhancement,
            playerIsAttacker: viewModel.playerIsAttacker(isOne:),
            ruleSections: ruleSections
        )
        if supportsBattleTracker {
            BattleTrackerWoundTrackerSection(
                playerOneName: viewModel.playerOneName,
                playerTwoName: viewModel.playerTwoName,
                playerOneArmy: viewModel.playerOneArmy,
                playerTwoArmy: viewModel.playerTwoArmy,
                woundsRemaining: viewModel.trackerState.unitWoundsRemaining,
                onChange: viewModel.setUnitWounds(key:remaining:)
            )
        }
        gotchaSection
        BattleTrackerReferenceLinksSection(ruleSections: ruleSections)
    }

    @ViewBuilder
    private var gotchaSection: some View {
        if !viewModel.activeGotchas.isEmpty {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                SectionHeader(title: String(localized: "Army Reminders"), systemImage: "bolt.fill")
                ForEach(viewModel.activeGotchas) { gotcha in
                    ArmyGotchaCard(gotcha: gotcha)
                }
            }
        }
    }

    @ViewBuilder
    private var trackerContent: some View {
        if !supportsBattleTracker {
            emptyState
        } else {
            BattleTrackerAbilitySections(
                viewModel: viewModel,
                ruleSections: ruleSections,
                onResolveAttack: handleResolveAttack
            )
        }
    }

    private var supportsBattleTracker: Bool {
        viewModel.contentCoverage >= .battleTracker
    }

    private var combatAttackerName: String {
        viewModel.trackerState.activePlayerIsOne ? viewModel.playerOneName : viewModel.playerTwoName
    }

    private var combatDefenderName: String {
        viewModel.trackerState.activePlayerIsOne ? viewModel.playerTwoName : viewModel.playerOneName
    }

    private var deploymentIsComplete: Bool {
        DeploymentChecklist.completionCount(completedSteps: viewModel.trackerState.completedDeploymentSteps).done
            == DeploymentChecklistStep.allCases.count
    }

    private var defenderWoundsRemaining: Int? {
        guard let key = combatViewModel.defenderWoundKey else { return nil }
        return viewModel.trackerState.unitWoundsRemaining[key]
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text(String(localized: "Battle tracker isn't available for this army yet."))
                .font(.headline)
            Text(
                "Ability reminders for this army aren't in Tabletome yet. Use the GW Spearhead PDF link on the army picker for full rules."
            )
            .font(.callout)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
        }
        .surfaceCard()
    }

    private static func matchupPrefill(for player: PlayerArmySelection) -> MatchupUnitPrefill? {
        guard !player.armyId.isEmpty else { return nil }
        return MatchupUnitPrefill(armyId: player.armyId, unitId: "")
    }

    private func syncCombatContext() {
        combatViewModel.syncBattleContext(
            activePlayerIsOne: viewModel.trackerState.activePlayerIsOne,
            playerOneArmyId: viewModel.playerOneArmy?.id,
            playerTwoArmyId: viewModel.playerTwoArmy?.id
        )
    }

    private func syncMultiAttack() {
        guard let weapon = combatViewModel.selectedAttackerWeapon,
              let unit = combatViewModel.selectedAttackerUnit,
              let save = combatViewModel.selectedDefenderUnit?.save else { return }
        let mods = CombatMatchupBuffCatalog.aggregateModifiers(
            from: combatViewModel.matchupBuffs,
            enabledIds: combatViewModel.enabledBuffIds
        )
        multiAttackViewModel.apply(
            weapon: weapon,
            saveTarget: save,
            unitId: unit.id,
            wardTarget: combatViewModel.activeWardTarget
        )
        multiAttackViewModel.bind(weapon: weapon, unitId: unit.id)
        multiAttackViewModel.hitModifier = mods.hit
        multiAttackViewModel.woundModifier = mods.wound
        multiAttackViewModel.saveModifier = mods.save
        multiAttackViewModel.damage = combatViewModel.damage
    }

    private func applyCombatDamage(_ damage: Int) {
        guard let armyId = combatViewModel.defenderArmyId.nilIfEmpty,
              let unitId = combatViewModel.defenderUnitId.nilIfEmpty else { return }
        viewModel.applyDamageToUnit(armyId: armyId, unitId: unitId, damage: damage)
    }

    private func handleResolveAttack(_ ability: TriggeredAbility) {
        if let unitId = viewModel.unitId(matchingSource: ability.source, in: viewModel.activeArmy) {
            combatViewModel.prefillAttackerUnit(unitId: unitId)
        }
        showsAdvancedOptions = combatViewModel.hasSuggestedWardBuffs
        scrollToCombatResolver = true
    }

    private func requestCombatResolverFocus(using proxy: ScrollViewProxy) {
        showsCombatResolver = true
        withAnimation(.easeInOut(duration: 0.35)) {
            proxy.scrollTo("combatResolver", anchor: .top)
        }
    }

    private func presentTurnHandoff(
        from previousPhase: BattleTurnPhase,
        to phase: BattleTurnPhase,
        playerChanged: Bool
    ) {
        let activeName = viewModel.trackerState.activePlayerIsOne
            ? viewModel.playerOneName
            : viewModel.playerTwoName
        let notice: TurnHandoffNotice?
        if phase == .endOfTurn {
            notice = TurnHandoffNotice(
                title: String(localized: "End of \(activeName)'s turn"),
                detail: String(
                    localized: "Score any victory points, update battle tactics, then pass the phone."
                )
            )
        } else if phase == .hero, playerChanged || previousPhase == .endOfTurn {
            notice = TurnHandoffNotice(
                title: String(localized: "Pass to \(activeName)"),
                detail: String(localized: "Hero phase — start of their turn.")
            )
        } else if playerChanged {
            notice = TurnHandoffNotice(
                title: String(localized: "Pass to \(activeName)"),
                detail: String(localized: "\(phase.title) phase.")
            )
        } else {
            notice = nil
        }
        guard let notice else { return }
        withAnimation(.easeInOut(duration: 0.25)) {
            turnHandoffNotice = notice
        }
    }
}

private struct TurnHandoffNotice: Equatable {
    let title: String
    let detail: String
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
