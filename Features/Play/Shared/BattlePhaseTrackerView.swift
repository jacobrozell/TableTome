import SwiftUI
import TabletomeDomain
import TabletomeData

struct BattlePhaseTrackerView: View {
    @StateObject var viewModel: BattlePhaseTrackerViewModel
    @StateObject var combatViewModel: UnitMatchupEvaluatorViewModel
    @StateObject var multiAttackViewModel = MultiAttackEvaluatorViewModel()
    @StateObject var batchCombatViewModel = BatchCombatEvaluatorViewModel()
    @AppStorage("diceInputMode") var diceInputModeRaw = DiceInputMode.physical.rawValue
    @AppStorage(BattleTrackerChromeStorage.topCollapsedKey) var isTopChromeCollapsed = false
    @AppStorage(BattleTrackerChromeStorage.topChromeExpandedInLandscapeKey) var topChromeExpandedInLandscape = false
    @State var showsCombatResolver = false
    @State var showsAdvancedOptions = false
    @State var showsMultiAttack = false
    @State var showsAdvancedSingleAttack = false
    @State var movementAction: MovementAction = .normal
    @State var selectedSectionTab: BattleTrackerSectionTab = .turn
    @State var showsDeploymentSetup = true
    @State var scrollToCombatResolver = false
    @State var pendingCombatResolverScroll = false
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
    let onVictoryPresented: ((Int, Int) async -> Void)?

    init(
        gameSystemId: GameSystemId = .default,
        matchState: GuidedMatchState,
        catalog: SpearheadCatalog,
        ruleSections: [RuleSection] = [],
        onMatchStateChange: (() -> Void)? = nil,
        onVictoryComplete: ((Bool, Int, Int) async -> Void)? = nil,
        onVictoryPresented: ((Int, Int) async -> Void)? = nil
    ) {
        self.onMatchStateChange = onMatchStateChange
        self.onVictoryComplete = onVictoryComplete
        self.onVictoryPresented = onVictoryPresented
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
            .onAppear {
                enforcePhysicalDiceIfNeeded()
            }
    }

    private func enforcePhysicalDiceIfNeeded() {
        guard !ReleaseSurface.allowsSimulatedDice(for: viewModel.gameSystemId) else { return }
        diceInputModeRaw = DiceInputMode.physical.rawValue
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
                .safeAreaPadding(.top, 0)
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
        .modifier(UnitFocusPresentationModifier(selection: $unitFocusSelection, usesFullScreen: usesUnitFocusFullScreenPresentation) {
            unitFocusSheet
        })
        .fullScreenCover(isPresented: $showsVictoryScreen) {
            victoryScreen
        }
        .onAppear {
            MatchLogRecorder.ensureSession(gameSystemId: viewModel.gameSystemId)
            logStandaloneBattleTrackerOpenedIfNeeded()
            let suppressCoaching = MarketingSnapshotBootstrap.suppressesCoachingUI
            showsBattleTrackerCoach = supportsBattleTracker
                && !NewPlayerTipsStore.hasSeenBattleTrackerCoach
                && !suppressCoaching
            if !suppressCoaching {
                FirstSessionStore.recordSetupComplete()
            }
            if !hasAppliedInitialSectionTab {
                hasAppliedInitialSectionTab = true
                if AppLaunchArguments.shouldSnapshotBattleCombat {
                    selectedSectionTab = .combat
                } else {
                    selectedSectionTab = suggestedSectionTab
                }
            }
            applyCompactTopChromeDefault()
            expandEmbeddedPadBattleChromeIfNeeded()
            if AppLaunchArguments.shouldOpenUnitFocus {
                Task {
                    try? await Task.sleep(for: .milliseconds(1_400))
                    presentMarketingUnitFocusIfNeeded()
                }
            }
            if !suppressCoaching {
                Task {
                    try? await Task.sleep(for: .milliseconds(400))
                    handoffBaselineEstablished = true
                    presentRoundOpenerNudgeIfNeeded()
                    presentHeroRoundOneNudgeIfNeeded()
                }
            } else {
                handoffBaselineEstablished = true
            }
        }
        .onChange(of: layoutContext) { _, _ in
            applyCompactTopChromeDefault()
        }
        .onChange(of: isTopChromeCollapsed) { _, collapsed in
            if layoutContext.prefersCollapsedBattleChrome || isEmbeddedInGuidedMatch {
                topChromeExpandedInLandscape = !collapsed
            }
        }
        .task {
            await combatViewModel.load()
            syncCombatContext()
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
    var secondarySections: some View {
        engineSecondarySections
    }

    var supportsBattleTracker: Bool {
        viewModel.playContext.capabilities.showsActivationBar || viewModel.contentCoverage >= .battleTracker
    }

    var showsSpearheadBattleChrome: Bool {
        viewModel.playContext.capabilities.showsBattleTacticDecks
    }

    /// iPad Guided Match split: show section tabs expanded on first open (avoid collapsed header + dead zone).
    func expandEmbeddedPadBattleChromeIfNeeded() {
        guard isEmbeddedInGuidedMatch, layoutContext.usesPadSplitNavigation else { return }
        guard isTopChromeCollapsed else { return }
        isTopChromeCollapsed = false
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
            if !isEmbeddedInGuidedMatch {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(String(localized: "Reset")) {
                        onReset()
                    }
                    .accessibilityIdentifier("battleTracker.reset")
                }
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
