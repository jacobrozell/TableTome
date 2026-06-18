import SwiftUI
import TabletomeDomain
import TabletomeData

struct BattlePhaseTrackerView: View {
    @StateObject var viewModel: BattlePhaseTrackerViewModel
    @StateObject var combatViewModel: UnitMatchupEvaluatorViewModel
    @StateObject var multiAttackViewModel = MultiAttackEvaluatorViewModel()
    @StateObject var batchCombatViewModel = BatchCombatEvaluatorViewModel()
    @AppStorage("diceInputMode") var diceInputModeRaw = DiceInputMode.physical.rawValue
    @State var showsCombatResolver = false
    @State var showsAdvancedOptions = false
    @State var showsMultiAttack = false
    @State var showsAdvancedSingleAttack = false
    @State var movementAction: MovementAction = .normal
    @State var selectedSectionTab: BattleTrackerSectionTab = .turn
    @State var showsDeploymentSetup = true
    @State var scrollToCombatResolver = false
    @State var showsBattleTrackerCoach = false
    @State var showsBattleGuideExpanded = true
    @State var dismissedBattleCompleteGuide = false
    @State var turnHandoffNotice: TurnHandoffNotice?
    @State var damageUndoNotice: DamageUndoNotice?
    @State var roundOpenerNotice: RoundOpenerNotice?
    @State var scoringReminderNotice: ScoringReminderNotice?
    @State var scrollToVictoryPoints = false
    @State var scrollToRoundChecklist = false
    @State var handoffBaselineEstablished = false
    @State var unitFocusSelection: UnitFocusSelection?
    @State var lastFocusedUnitSelection: UnitFocusSelection?
    @State var scrollToPhaseControls = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let ruleSections: [RuleSection]

    let onMatchStateChange: (() -> Void)?

    init(
        matchState: GuidedMatchState,
        catalog: SpearheadCatalog,
        ruleSections: [RuleSection] = [],
        onMatchStateChange: (() -> Void)? = nil
    ) {
        self.onMatchStateChange = onMatchStateChange
        _viewModel = StateObject(
            wrappedValue: BattlePhaseTrackerViewModel(
                matchState: matchState,
                catalog: catalog,
                onMatchStateChange: onMatchStateChange
            )
        )
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
        applyCombatEvaluationSync(to:
            ScrollViewReader { proxy in
                trackedScrollView(proxy: proxy)
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                if layoutContext.usesPadSplitNavigation == false, supportsBattleTracker {
                    VStack(spacing: DesignTokens.Spacing.sm) {
                        BattleTrackerSectionTabBar(selection: $selectedSectionTab)
                        StickyPhaseHeader(
                            round: viewModel.trackerState.battleRound,
                            phaseTitle: viewModel.trackerState.currentPhase.title,
                            playerName: viewModel.trackerState.activePlayerIsOne
                                ? viewModel.playerOneName
                                : viewModel.playerTwoName
                        )
                    }
                    .padding(.horizontal, DesignTokens.Spacing.md)
                    .padding(.bottom, DesignTokens.Spacing.xs)
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if supportsBattleTracker, layoutContext.usesPadSplitNavigation == false {
                    phaseDock
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
            .sheet(item: $unitFocusSelection) { _ in
                unitFocusSheet
            }
            .onAppear {
                showsBattleTrackerCoach = supportsBattleTracker && !NewPlayerTipsStore.hasSeenBattleTrackerCoach
                Task {
                    try? await Task.sleep(for: .milliseconds(400))
                    handoffBaselineEstablished = true
                    presentRoundOpenerNudgeIfNeeded()
                }
            }
            .task {
                await combatViewModel.load()
                syncCombatContext()
            }
        )
    }

    var layoutContext: TabletomeLayoutContext {
        TabletomeLayout.context(
            horizontalSizeClass: horizontalSizeClass,
            verticalSizeClass: verticalSizeClass
        )
    }

    var isPadLandscape: Bool {
        layoutContext == .padLandscape
    }

    var trackerContentPadding: CGFloat {
        switch layoutContext {
        case .padLandscape: DesignTokens.Spacing.sm
        case .phoneLandscape: DesignTokens.phoneLandscapeHorizontalPadding
        default: DesignTokens.Spacing.md
        }
    }

    @ViewBuilder
    var coachSection: some View {
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
    var guideSection: some View {
        if !dismissedBattleCompleteGuide, let step = viewModel.currentGuideStep {
            DisclosureGroup(isExpanded: $showsBattleGuideExpanded) {
                BattleGuideCard(step: step) {
                    if step.kind == .battleComplete {
                        dismissedBattleCompleteGuide = true
                    } else {
                        viewModel.completeCurrentGuideStep()
                    }
                }
                .padding(.top, DesignTokens.Spacing.sm)
            } label: {
                Label(String(localized: "Do this now"), systemImage: "hand.point.right.fill")
                    .font(.subheadline.weight(.semibold))
            }
            .padding(DesignTokens.Spacing.md)
            .background(Color.accentColor.opacity(0.08), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                    .strokeBorder(Color.accentColor.opacity(0.25), lineWidth: 1)
            )
            .accessibilityIdentifier("battleGuide.section")
        }
    }

    @ViewBuilder
    var startOfRoundHelper: some View {
        if supportsBattleTracker, viewModel.needsStartOfRoundAbilitiesPrompt {
            StartOfRoundAbilitiesBanner(abilities: viewModel.startOfRoundAbilities)
        }
    }

    @ViewBuilder
    var shootingPhaseHelper: some View {
        if supportsBattleTracker, viewModel.trackerState.currentPhase == .shooting {
            ShootingEligibleUnitsCard(
                units: viewModel.shootingEligibleUnits,
                armyName: viewModel.armyName,
                onSelectUnit: { unitId in
                    guard let armyId = viewModel.activeArmy?.id else { return }
                    let shootingWeaponId = viewModel.activeArmy?
                        .units
                        .first(where: { $0.id == unitId })?
                        .shootingWeapons
                        .first?
                        .id
                    handleArmyUnitSelection(
                        armyId: armyId,
                        unitId: unitId,
                        preferredWeaponId: shootingWeaponId
                    )
                }
            )
        }
    }

    @ViewBuilder
    var shootInCombatPhaseHelper: some View {
        if supportsBattleTracker,
           viewModel.trackerState.currentPhase == .combat
               || viewModel.trackerState.currentPhase == .anyCombat,
           !viewModel.shootInCombatEligibleUnits.isEmpty {
            ShootInCombatEligibleUnitsCard(
                units: viewModel.shootInCombatEligibleUnits,
                onSelectUnit: { unitId, weaponId in
                    guard let armyId = viewModel.activeArmy?.id else { return }
                    handleArmyUnitSelection(
                        armyId: armyId,
                        unitId: unitId,
                        preferredWeaponId: weaponId
                    )
                }
            )
        }
    }

    @ViewBuilder
    func combatResolverSection(usesLandscapeSplit: Bool = false) -> some View {
        if supportsBattleTracker {
            BattleTrackerCombatResolverSection(
                combatViewModel: combatViewModel,
                multiAttackViewModel: multiAttackViewModel,
                batchCombatViewModel: batchCombatViewModel,
                showsCombatResolver: $showsCombatResolver,
                diceInputModeRaw: $diceInputModeRaw,
                showsAdvancedOptions: $showsAdvancedOptions,
                showsMultiAttack: $showsMultiAttack,
                showsAdvancedSingleAttack: $showsAdvancedSingleAttack,
                trackerState: viewModel.trackerState,
                attackerName: combatAttackerName,
                defenderName: combatDefenderName,
                deploymentIsComplete: deploymentIsComplete,
                defenderWoundsRemaining: defenderWoundsRemaining,
                unitWoundsRemaining: viewModel.trackerState.unitWoundsRemaining,
                ruleSections: ruleSections,
                onSyncMultiAttack: syncMultiAttack,
                onApplyDamage: applyCombatDamage,
                usesLandscapeSplitPresentation: usesLandscapeSplit
            )
        }
    }

    @ViewBuilder
    var deploymentSection: some View {
        if viewModel.trackerState.battleRound == 1 {
            DisclosureGroup(isExpanded: $showsDeploymentSetup) {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                    RealmSideCoinFlipCard()
                    DeploymentChecklistCard(
                        completedSteps: viewModel.trackerState.completedDeploymentSteps,
                        focusedStep: viewModel.focusedDeploymentStep,
                        onToggle: viewModel.setDeploymentStep
                    )
                }
                .padding(.top, DesignTokens.Spacing.sm)
            } label: {
                Label(String(localized: "Battlefield setup"), systemImage: "map")
                    .font(.headline)
            }
            .surfaceCard()
            .onAppear {
                showsDeploymentSetup = !deploymentIsComplete
            }
        }
    }

    var roundAndScoreSection: some View {
        BattleTrackerRoundAndScoreSection(viewModel: viewModel)
    }

    @ViewBuilder
    func armyTrackerSection(wideLayout: Bool, compactSidebar: Bool = false) -> some View {
        if supportsBattleTracker {
            ArmyTrackerCard(
                playerOneName: viewModel.playerOneName,
                playerTwoName: viewModel.playerTwoName,
                playerOneArmy: viewModel.playerOneArmy,
                playerTwoArmy: viewModel.playerTwoArmy,
                woundsRemaining: viewModel.trackerState.unitWoundsRemaining,
                healthPerModelOverrides: viewModel.trackerState.unitHealthPerModelOverrides,
                activePlayerIsOne: viewModel.trackerState.activePlayerIsOne,
                usesWideLayout: wideLayout,
                usesCompactSidebar: compactSidebar,
                onChange: viewModel.setUnitWounds(key:remaining:),
                onSelectUnit: { armyId, unitId in
                    handleArmyUnitSelection(armyId: armyId, unitId: unitId)
                }
            )
        }
    }

    @ViewBuilder
    var secondarySections: some View {
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
            DisclosureGroup {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    ForEach(viewModel.activeGotchas) { gotcha in
                        ArmyGotchaCard(gotcha: gotcha)
                    }
                }
                .padding(.top, DesignTokens.Spacing.sm)
            } label: {
                Label(String(localized: "Army Reminders"), systemImage: "bolt.fill")
                    .font(.headline)
            }
            .surfaceCard()
            .accessibilityIdentifier("battleTracker.gotchaSection")
        }
    }

    @ViewBuilder
    var trackerContent: some View {
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

    var supportsBattleTracker: Bool {
        viewModel.contentCoverage >= .battleTracker
    }
}

struct BattleTrackerContentWidth: ViewModifier {
    let layoutContext: TabletomeLayoutContext

    func body(content: Content) -> some View {
        switch layoutContext {
        case .padPortrait, .padLandscape:
            content
        case .phoneLandscape:
            content.readableContentWidth()
        case .phonePortrait:
            content.readableContentWidth()
        }
    }
}
