import SwiftUI
import TabletomeDomain
import TabletomeData

struct BattlePhaseTrackerView: View {
    @StateObject var viewModel: BattlePhaseTrackerViewModel
    @StateObject var combatViewModel: UnitMatchupEvaluatorViewModel
    @StateObject var multiAttackViewModel = MultiAttackEvaluatorViewModel()
    @StateObject var batchCombatViewModel = BatchCombatEvaluatorViewModel()
    @AppStorage("diceInputMode") var diceInputModeRaw = DiceInputMode.physical.rawValue
    @AppStorage(BattleTrackerChromeStorage.topCollapsedKey) private var isTopChromeCollapsed = false
    @AppStorage(BattleTrackerChromeStorage.topChromeExpandedInLandscapeKey) private var topChromeExpandedInLandscape = false
    @State var showsCombatResolver = false
    @State var showsAdvancedOptions = false
    @State var showsMultiAttack = false
    @State var showsAdvancedSingleAttack = false
    @State var movementAction: MovementAction = .normal
    @State var selectedSectionTab: BattleTrackerSectionTab = .turn
    @State var showsDeploymentSetup = true
    @State var scrollToCombatResolver = false
    @State var showsBattleTrackerCoach = false
    @State var dismissedBattleCompleteGuide = false
    @State var showsVictoryScreen = false
    @State var victoryPlayerOneVP = 0
    @State var victoryPlayerTwoVP = 0
    @State var turnHandoffNotice: TurnHandoffNotice?
    @State var damageUndoNotice: DamageUndoNotice?
    @State var roundOpenerNotice: RoundOpenerNotice?
    @State var scoringReminderNotice: ScoringReminderNotice?
    @State var phaseActionNudge: PhaseActionNudgeNotice?
    @State var showsHeroRoundOneNotice = false
    @State var scrollToVictoryPoints = false
    @State var scrollToRoundChecklist = false
    @State var handoffBaselineEstablished = false
    @State var unitFocusSelection: UnitFocusSelection?
    @State var lastFocusedUnitSelection: UnitFocusSelection?
    @State var scrollToPhaseControls = false
    @State private var hasAppliedInitialSectionTab = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Environment(\.battleTrackerIsEmbeddedInGuidedMatch) var isEmbeddedInGuidedMatch
    let ruleSections: [RuleSection]

    let onMatchStateChange: (() -> Void)?
    let onVictoryComplete: ((Bool, Int, Int) async -> Void)?

    init(
        gameSystemId: GameSystemId = .default,
        matchState: GuidedMatchState,
        catalog: SpearheadCatalog,
        ruleSections: [RuleSection] = [],
        onMatchStateChange: (() -> Void)? = nil,
        onVictoryComplete: ((Bool, Int, Int) async -> Void)? = nil
    ) {
        self.onMatchStateChange = onMatchStateChange
        self.onVictoryComplete = onVictoryComplete
        _viewModel = StateObject(
            wrappedValue: BattleTrackerViewModelFactory.make(
                gameSystemId: gameSystemId,
                matchState: matchState,
                catalog: catalog,
                onMatchStateChange: onMatchStateChange
            )
        )
        _combatViewModel = StateObject(
            wrappedValue: UnitMatchupEvaluatorViewModel(
                catalogRepository: Self.catalogRepository(for: gameSystemId),
                gameSystemId: gameSystemId.rawValue,
                attackerPrefill: Self.matchupPrefill(for: matchState.playerOne),
                defenderPrefill: Self.matchupPrefill(for: matchState.playerTwo)
            )
        )
        self.ruleSections = ruleSections
    }

    var body: some View {
        applyCombatEvaluationSync(to: trackerScreen)
    }

    @ViewBuilder
    private var trackerScreen: some View {
        let scroll = ScrollViewReader { proxy in
            trackedScrollView(proxy: proxy)
        }

        Group {
            if isEmbeddedInGuidedMatch {
                VStack(spacing: 0) {
                    compactTopChrome
                    scroll
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .layoutPriority(1)
                        .safeAreaInset(edge: .bottom, spacing: 0) {
                            compactBottomChrome
                        }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            } else {
                scroll
                    .safeAreaInset(edge: .top, spacing: 0) {
                        compactTopChrome
                    }
                    .safeAreaInset(edge: .bottom, spacing: 0) {
                        compactBottomChrome
                    }
            }
        }
        .modifier(
            BattleTrackerScreenChrome(
                isEmbeddedInGuidedMatch: isEmbeddedInGuidedMatch,
                showsTopChromeCollapseToggle: supportsBattleTracker && usesCompactBattleTrackerChrome,
                isTopChromeCollapsed: $isTopChromeCollapsed,
                onReset: { viewModel.resetTracker() }
            )
        )
        .accessibilityIdentifier("battleTracker.screen")
        .sheet(item: $unitFocusSelection) { _ in
            unitFocusSheet
        }
        .fullScreenCover(isPresented: $showsVictoryScreen) {
            victoryScreen
        }
        .onAppear {
            MatchLogRecorder.ensureSession(gameSystemId: viewModel.gameSystemId)
            showsBattleTrackerCoach = supportsBattleTracker && !NewPlayerTipsStore.hasSeenBattleTrackerCoach
            FirstSessionStore.recordSetupComplete()
            if !hasAppliedInitialSectionTab {
                hasAppliedInitialSectionTab = true
                if AppLaunchArguments.shouldSnapshotBattleCombat {
                    selectedSectionTab = .combat
                } else {
                    selectedSectionTab = suggestedSectionTab
                }
            }
            applyPhoneLandscapeTopChromeDefault()
            if AppLaunchArguments.shouldOpenUnitFocus {
                Task {
                    try? await Task.sleep(for: .milliseconds(900))
                    presentMarketingUnitFocusIfNeeded()
                }
            }
            Task {
                try? await Task.sleep(for: .milliseconds(400))
                handoffBaselineEstablished = true
                presentRoundOpenerNudgeIfNeeded()
                presentHeroRoundOneNudgeIfNeeded()
            }
        }
        .onChange(of: layoutContext) { _, _ in
            applyPhoneLandscapeTopChromeDefault()
        }
        .onChange(of: isTopChromeCollapsed) { _, collapsed in
            if layoutContext.prefersCollapsedBattleChrome {
                topChromeExpandedInLandscape = !collapsed
            }
        }
        .task {
            await combatViewModel.load()
            syncCombatContext()
        }
    }

    @ViewBuilder
    private var compactTopChrome: some View {
        if supportsBattleTracker {
            if usesCompactBattleTrackerChrome {
                phoneCompactTopChrome
            } else if usesPadTabbedTwoColumnLayout {
                padTopChrome
            }
        }
    }

    @ViewBuilder
    private var phoneCompactTopChrome: some View {
        if isTopChromeCollapsed {
            BattleTrackerCollapsedTopChrome(
                gameSystemId: viewModel.gameSystemId,
                tabs: BattleTrackerSectionTab.visibleTabs(gameSystemId: viewModel.gameSystemId),
                selection: $selectedSectionTab,
                round: viewModel.trackerState.battleRound,
                phaseTitle: viewModel.trackerState.currentPhase.title,
                playerName: viewModel.trackerState.activePlayerIsOne
                    ? viewModel.playerOneName
                    : viewModel.playerTwoName,
                onExpand: { expandTopChrome() }
            )
        } else {
            HStack(alignment: .center, spacing: DesignTokens.Spacing.xs) {
                VStack(spacing: layoutContext.prefersCollapsedBattleChrome ? DesignTokens.Spacing.xs : DesignTokens.Spacing.sm) {
                    BattleTrackerSectionTabBar(
                        gameSystemId: viewModel.gameSystemId,
                        selection: $selectedSectionTab
                    )
                    if !isEmbeddedInGuidedMatch {
                        StickyPhaseHeader(
                            round: viewModel.trackerState.battleRound,
                            phaseTitle: viewModel.trackerState.currentPhase.title,
                            playerName: viewModel.trackerState.activePlayerIsOne
                                ? viewModel.playerOneName
                                : viewModel.playerTwoName,
                            gameSystemId: viewModel.gameSystemId
                        )
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                ChromeCollapseInlineButton(
                    accessibilityLabel: String(localized: "Hide battle header"),
                    accessibilityIdentifier: "battleTracker.chromeCollapseInline",
                    onCollapse: collapseTopChrome
                )
            }
            .barChromeBackground(
                horizontalPadding: DesignTokens.Spacing.md,
                verticalPadding: layoutContext.prefersCollapsedBattleChrome ? 2 : DesignTokens.Spacing.xs
            )
        }
    }

    private var padTopChrome: some View {
        VStack(spacing: DesignTokens.Spacing.sm) {
            BattleTrackerSectionTabBar(
                gameSystemId: viewModel.gameSystemId,
                selection: $selectedSectionTab
            )
            StickyPhaseHeader(
                round: viewModel.trackerState.battleRound,
                phaseTitle: viewModel.trackerState.currentPhase.title,
                playerName: viewModel.trackerState.activePlayerIsOne
                    ? viewModel.playerOneName
                    : viewModel.playerTwoName,
                gameSystemId: viewModel.gameSystemId
            )
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.vertical, DesignTokens.Spacing.xs)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.bar)
        .accessibilityIdentifier("battleTracker.padTopChrome")
    }

    private func applyPhoneLandscapeTopChromeDefault() {
        guard layoutContext.prefersCollapsedBattleChrome, !topChromeExpandedInLandscape else { return }
        guard !isTopChromeCollapsed else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            isTopChromeCollapsed = true
        }
    }

    private func expandTopChrome() {
        withAnimation(.easeInOut(duration: 0.2)) {
            isTopChromeCollapsed = false
        }
    }

    private func collapseTopChrome() {
        withAnimation(.easeInOut(duration: 0.2)) {
            isTopChromeCollapsed = true
        }
    }

    @ViewBuilder
    private var compactBottomChrome: some View {
        if supportsBattleTracker, usesCompactBattleTrackerChrome {
            phaseDock
        }
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

    var usesCompactBattleTrackerChrome: Bool {
        !layoutContext.usesPadSplitNavigation || dynamicTypeSize.needsLayoutAdaptation
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
        if supportsBattleTracker, showsBattleTrackerCoach, !showsPhasePlaybook {
            BattleTrackerCoachCard(gameSystemId: viewModel.gameSystemId) {
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
        if showsGuideOnTurnTab, let step = viewModel.currentGuideStep {
            BattleGuideCard(step: step) {
                if step.kind == .battleComplete {
                    if ReleaseSurface.showsMatchHistory {
                        presentVictoryScreen()
                    }
                    dismissedBattleCompleteGuide = true
                } else {
                    viewModel.completeCurrentGuideStep()
                }
            }
            .accessibilityIdentifier("battleGuide.section")
        }
    }

    @ViewBuilder
    var startOfRoundHelper: some View {
        if supportsBattleTracker, showsSpearheadBattleChrome, viewModel.needsStartOfRoundAbilitiesPrompt {
            StartOfRoundAbilitiesBanner(abilities: viewModel.startOfRoundAbilities)
        }
    }

    @ViewBuilder
    var shootingPhaseHelper: some View {
        if supportsBattleTracker,
           ReleaseSurface.showsCombatResolver(for: viewModel.gameSystemId),
           viewModel.trackerState.currentPhase == .shooting {
            ShootingEligibleUnitsCard(
                units: viewModel.shootingEligibleUnits,
                armyName: viewModel.armyName,
                gameSystemId: viewModel.gameSystemId,
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
           ReleaseSurface.showsCombatResolver(for: viewModel.gameSystemId),
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
        if supportsBattleTracker, ReleaseSurface.showsCombatResolver(for: viewModel.gameSystemId) {
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
                engineDeploymentSection
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

    var roundOpenerChecklistSection: some View {
        BattleTrackerRoundOpenerSection(viewModel: viewModel)
    }

    @ViewBuilder
    var victoryPointsSection: some View {
        if showsVictoryPointsOnTurnTab {
            BattleTrackerVictoryPointsSection(viewModel: viewModel)
        }
    }

    @ViewBuilder
    func armyTrackerSection(wideLayout: Bool, compactSidebar: Bool = false) -> some View {
        if supportsBattleTracker, !viewModel.playContext.capabilities.showsActivationBar {
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
                gameSystemId: viewModel.gameSystemId,
                onChange: viewModel.setUnitWounds(key:remaining:),
                onSelectUnit: { armyId, unitId in
                    handleArmyUnitSelection(armyId: armyId, unitId: unitId)
                }
            )
        }
    }

    @ViewBuilder
    var secondarySections: some View {
        engineSecondarySections
    }

    @ViewBuilder
    var gotchaSection: some View {
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
        } else if viewModel.playContext.capabilities.showsActivationBar {
            scTrackerPlaceholder
        } else {
            BattleTrackerAbilitySections(
                viewModel: viewModel,
                ruleSections: ruleSections,
                showsEmbeddedCombatTools: ReleaseSurface.showsCombatResolver(for: viewModel.gameSystemId),
                onResolveAttack: handleResolveAttack
            )
        }
    }

    @ViewBuilder
    var scTrackerPlaceholder: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text(String(localized: "Resolve attacks on the table"))
                .font(.headline)
            Text(
                String(
                    localized: """
                    Use your physical unit cards and Command Center for combat. On the Turn tab, tap Done after each \
                    activation and Pass when you want the First Player Marker for the next phase. Victory points and \
                    turn activations are tracked in the tabs below.
                    """
                )
            )
            .font(.callout)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
        }
        .surfaceCard()
        .accessibilityIdentifier("battleTracker.scPlaceholder")
    }

    var supportsBattleTracker: Bool {
        viewModel.playContext.capabilities.showsActivationBar || viewModel.contentCoverage >= .battleTracker
    }

    var showsSpearheadBattleChrome: Bool {
        viewModel.playContext.capabilities.showsBattleTacticDecks
    }
}

private struct BattleTrackerScreenChrome: ViewModifier {
    let isEmbeddedInGuidedMatch: Bool
    let showsTopChromeCollapseToggle: Bool
    @Binding var isTopChromeCollapsed: Bool
    let onReset: () -> Void

    func body(content: Content) -> some View {
        Group {
            if isEmbeddedInGuidedMatch {
                content
            } else {
                content
                    .navigationTitle(String(localized: "Battle Tracker"))
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
        .toolbar {
            if showsTopChromeCollapseToggle {
                ToolbarItem(placement: .topBarLeading) {
                    ChromeCollapseToolbarButton(
                        isCollapsed: $isTopChromeCollapsed,
                        expandedAccessibilityLabel: String(localized: "Hide battle header"),
                        collapsedAccessibilityLabel: String(localized: "Show battle header"),
                        accessibilityIdentifier: "battleTracker.chromeCollapse"
                    )
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(String(localized: "Reset")) {
                    onReset()
                }
                .accessibilityIdentifier("battleTracker.reset")
            }
        }
    }
}

struct BattleTrackerContentWidth: ViewModifier {
    let layoutContext: TabletomeLayoutContext

    func body(content: Content) -> some View {
        switch layoutContext {
        case .padPortrait, .padLandscape:
            content
        case .phoneLandscape, .phonePortrait:
            content
        }
    }
}
