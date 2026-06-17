import SwiftUI
import TabletomeDomain
import TabletomeData

struct BattlePhaseTrackerView: View {
    @StateObject var viewModel: BattlePhaseTrackerViewModel
    @StateObject var combatViewModel: UnitMatchupEvaluatorViewModel
    @StateObject var multiAttackViewModel = MultiAttackEvaluatorViewModel()
    @AppStorage("diceInputMode") private var diceInputModeRaw = DiceInputMode.physical.rawValue
    @State var showsCombatResolver = false
    @State var showsAdvancedOptions = false
    @State private var showsMultiAttack = false
    @State var scrollToCombatResolver = false
    @State private var showsBattleTrackerCoach = false
    @State private var dismissedBattleCompleteGuide = false
    @State var turnHandoffNotice: TurnHandoffNotice?
    @State var damageUndoNotice: DamageUndoNotice?
    @State var roundOpenerNotice: RoundOpenerNotice?
    @State var scoringReminderNotice: ScoringReminderNotice?
    @State var scrollToVictoryPoints = false
    @State private var handoffBaselineEstablished = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.accessibilityReduceMotion) var reduceMotion
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
                        if isPadLandscape {
                            landscapeLayout
                        } else {
                            regularPortraitLayout
                        }
                    } else {
                        compactLayout
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .modifier(BattleTrackerContentWidth(isPadLandscape: isPadLandscape))
                .padding(isPadLandscape ? DesignTokens.Spacing.sm : DesignTokens.Spacing.md)
            }
            .scrollBounceBehavior(.basedOnSize, axes: .vertical)
            .tabBarScrollInset()
            .onChange(of: viewModel.trackerState.currentPhase) { oldPhase, phase in
                if phase.isCombatRelated {
                    requestCombatResolverFocus(using: proxy)
                }
                if phase == .endOfTurn, handoffBaselineEstablished {
                    presentScoringReminderIfNeeded()
                } else if oldPhase == .endOfTurn {
                    scoringReminderNotice = nil
                }
                if handoffBaselineEstablished {
                    presentTurnHandoff(from: oldPhase, to: phase, playerChanged: false)
                }
            }
            .onChange(of: viewModel.trackerState.battleRound) { oldRound, round in
                guard round > oldRound, handoffBaselineEstablished else { return }
                presentRoundOpenerNudge(round: round)
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
            .onChange(of: damageUndoNotice) { _, notice in
                guard notice != nil else { return }
                let current = notice
                Task {
                    try? await Task.sleep(for: .seconds(6))
                    if damageUndoNotice == current {
                        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) {
                            damageUndoNotice = nil
                        }
                    }
                }
            }
            .onChange(of: turnHandoffNotice) { _, notice in
                guard notice != nil else { return }
                let current = notice
                Task {
                    try? await Task.sleep(for: .seconds(5))
                    if turnHandoffNotice == current {
                        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) {
                            turnHandoffNotice = nil
                        }
                    }
                }
            }
            .onChange(of: scoringReminderNotice) { _, notice in
                guard notice != nil else { return }
                let current = notice
                Task {
                    try? await Task.sleep(for: .seconds(8))
                    if scoringReminderNotice == current {
                        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) {
                            scoringReminderNotice = nil
                        }
                    }
                }
            }
            .onChange(of: roundOpenerNotice) { _, notice in
                guard notice != nil else { return }
                let current = notice
                Task {
                    try? await Task.sleep(for: .seconds(8))
                    if roundOpenerNotice == current {
                        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) {
                            roundOpenerNotice = nil
                        }
                    }
                }
            }
            .onChange(of: scrollToCombatResolver) { _, shouldScroll in
                guard shouldScroll else { return }
                showsCombatResolver = true
                withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.35)) {
                    proxy.scrollTo("combatResolver", anchor: .top)
                }
                scrollToCombatResolver = false
            }
            .onChange(of: scrollToVictoryPoints) { _, shouldScroll in
                guard shouldScroll else { return }
                withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.35)) {
                    proxy.scrollTo("victoryPoints", anchor: .top)
                }
                scrollToVictoryPoints = false
                scoringReminderNotice = nil
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if supportsBattleTracker, viewModel.trackerState.currentPhase.isCombatRelated {
                BattleTrackerStickyCombatBar(
                    attackerName: combatAttackerName,
                    defenderName: combatDefenderName,
                    phaseTitle: viewModel.trackerState.currentPhase.title,
                    defenderWoundsLabel: defenderWoundsSummaryLabel,
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

    private var isPadLandscape: Bool {
        TabletomeLayout.isPadLandscape(
            horizontalSizeClass: horizontalSizeClass,
            verticalSizeClass: verticalSizeClass
        )
    }

    private var transientNoticeSections: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            turnHandoffSection
            scoringReminderSection
            roundOpenerSection
            damageUndoSection
        }
    }

    private var compactLayout: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            coachSection
            transientNoticeSections
            guideSection
            roundAndScoreSection
            armyTrackerSection(wideLayout: false)
            BattleTrackerControlPanel(viewModel: viewModel)
            combatResolverSection
            trackerContent
            deploymentSection
            secondarySections
        }
        .animation(.easeInOut(duration: 0.25), value: showsBattleTrackerCoach)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var regularPortraitLayout: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            coachSection
            transientNoticeSections
            guideSection
            deploymentSection
            armyTrackerSection(wideLayout: true, compactSidebar: false)
            HStack(alignment: .top, spacing: DesignTokens.Spacing.lg) {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
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
        }
        .frame(maxWidth: DesignTokens.battleTrackerRegularMaxWidth)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var landscapeLayout: some View {
        BattleTrackerLandscapeLayout(
            coach: coachSection,
            banners: transientNoticeSections,
            guide: guideSection,
            deployment: deploymentSection,
            roundAndScore: roundAndScoreSection,
            control: BattleTrackerControlPanel(viewModel: viewModel),
            combat: combatResolverSection,
            abilities: trackerContent,
            army: armyTrackerSection(wideLayout: false, compactSidebar: true),
            secondary: secondarySections
        )
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
        if !dismissedBattleCompleteGuide, let step = viewModel.currentGuideStep {
            BattleGuideCard(step: step) {
                if step.kind == .battleComplete {
                    dismissedBattleCompleteGuide = true
                } else {
                    viewModel.completeCurrentGuideStep()
                }
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
    private func armyTrackerSection(wideLayout: Bool, compactSidebar: Bool = false) -> some View {
        if supportsBattleTracker {
            ArmyTrackerCard(
                playerOneName: viewModel.playerOneName,
                playerTwoName: viewModel.playerTwoName,
                playerOneArmy: viewModel.playerOneArmy,
                playerTwoArmy: viewModel.playerTwoArmy,
                woundsRemaining: viewModel.trackerState.unitWoundsRemaining,
                activePlayerIsOne: viewModel.trackerState.activePlayerIsOne,
                usesWideLayout: wideLayout,
                usesCompactSidebar: compactSidebar,
                onChange: viewModel.setUnitWounds(key:remaining:),
                onSelectUnit: handleArmyUnitSelection
            )
        }
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

    private var defenderWoundsSummaryLabel: String? {
        guard let defender = combatViewModel.selectedDefenderUnit,
              let remaining = defenderWoundsRemaining else { return nil }
        let capacity = UnitWoundCapacity.capacity(for: defender)
        if remaining == 0 {
            return String(localized: "\(defender.name): destroyed")
        }
        return String(localized: "\(defender.name): \(remaining)/\(capacity) wounds")
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
}

private struct BattleTrackerContentWidth: ViewModifier {
    let isPadLandscape: Bool

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    func body(content: Content) -> some View {
        if horizontalSizeClass == .regular || isPadLandscape {
            content
        } else {
            content.readableContentWidth()
        }
    }
}
