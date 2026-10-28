import SwiftUI
import TabletomeDomain

/// Single-surface battle interface for Spearhead — replaces tab-based tracker.
/// See `ongoing/guided-match-ui-redesign.md` for design rationale.
struct SpearheadBattleView: View {
    @StateObject var viewModel: SpearheadBattleViewModel
    @State var expandedUnitKey: String?
    @State var resolverContext: InlineResolverContext?
    @State private var showsRoundOpener = false
    @State private var showsVictoryScreen = false
    @State var showsVictoryPointsSheet = false
    @State var showsUnitsSheet = false
    @State var showsTurnHandoff = false
    @State var showsRoundPicker = false
    @State var showsResetConfirmation = false
    @State var showsCombatSheet = false
    @State var showsBattleCoach = !NewPlayerTipsStore.hasSeenBattleTrackerCoach
    @State var primaryActionLocked = false
    @State var primaryTapCount = 0
    @State var turnStartPlayerOneVP = 0
    @State var turnStartPlayerTwoVP = 0
    #if DEBUG
    @AppStorage(BattleScreenFeatureFlag.legacyDefaultsKey) var forcesLegacyBattleScreen = false
    #endif
    @State private var damageUndoNotice: DamageUndoNotice?
    @State private var victoryPlayerOneVP = 0
    @State private var victoryPlayerTwoVP = 0
    @State var dismissedBattleCompleteGuide = false
    @State private var showsHeroRoundOneNotice = false
    @State var unitFocusSelection: UnitFocusSelection?
    @State var movementAction: MovementAction = .normal

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let onMatchStateChange: (() -> Void)?
    let onVictoryComplete: ((Bool, Int, Int) async -> Void)?
    let onVictoryPresented: ((Int, Int) async -> Void)?
    var householdProfiles: [PlayerProfile] = []

    init(
        gameSystemId: GameSystemId,
        matchState: GuidedMatchState,
        catalog: SpearheadCatalog,
        ruleSections: [RuleSection] = [],
        householdProfiles: [PlayerProfile] = [],
        onMatchStateChange: (() -> Void)? = nil,
        onVictoryComplete: ((Bool, Int, Int) async -> Void)? = nil,
        onVictoryPresented: ((Int, Int) async -> Void)? = nil
    ) {
        self.onMatchStateChange = onMatchStateChange
        self.onVictoryComplete = onVictoryComplete
        self.onVictoryPresented = onVictoryPresented
        self.householdProfiles = householdProfiles
        _viewModel = StateObject(
            wrappedValue: SpearheadBattleViewModel(
                gameSystemId: gameSystemId,
                matchState: matchState,
                catalog: catalog,
                onMatchStateChange: onMatchStateChange
            )
        )
    }

    var layoutContext: TabletomeLayoutContext {
        TabletomeLayout.context(
            horizontalSizeClass: horizontalSizeClass,
            verticalSizeClass: verticalSizeClass
        )
    }

    var usesTwoColumnLayout: Bool {
        layoutContext.usesPadSplitNavigation && !dynamicTypeSize.needsLayoutAdaptation
    }

    var usesPhoneLandscapeLayout: Bool {
        layoutContext == .phoneLandscape && !dynamicTypeSize.needsLayoutAdaptation
    }

    var usesNewBattleScreen: Bool {
        #if DEBUG
        !forcesLegacyBattleScreen
        #else
        true
        #endif
    }

    var body: some View { battleChrome }

    @ViewBuilder
    private var battleLayout: some View {
        if usesTwoColumnLayout {
            twoColumnLayout
        } else if usesPhoneLandscapeLayout {
            phoneLandscapeLayout
        } else {
            singleColumnLayout
        }
    }

    // MARK: - Single Column (iPhone)

    @ViewBuilder
    private var singleColumnLayout: some View {
        ScrollView {
            VStack(spacing: DesignTokens.Spacing.md) {
                battleScrollSections(includeOpponentUnits: true)
            }
            .padding(.horizontal, DesignTokens.Spacing.md)
            .padding(.bottom, DesignTokens.Spacing.xl)
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            stickyHeader
        }
    }

    // MARK: - Phone Landscape

    @ViewBuilder
    private var phoneLandscapeLayout: some View {
        VStack(spacing: 0) {
            stickyHeader(compactLandscape: true)
            HStack(alignment: .top, spacing: 0) {
                ScrollView {
                    VStack(spacing: DesignTokens.phoneLandscapeSectionSpacing) {
                        battleScrollSections(includeOpponentUnits: false)
                    }
                    .padding(.horizontal, DesignTokens.phoneLandscapeHorizontalPadding)
                    .padding(.bottom, DesignTokens.Spacing.md)
                }
                .frame(maxWidth: .infinity)
                .accessibilityIdentifier("spearheadBattle.phoneLandscape.yourColumn")

                Divider()

                ScrollView {
                    VStack(spacing: DesignTokens.phoneLandscapeSectionSpacing) {
                        opponentUnitsSection()
                    }
                    .padding(.horizontal, DesignTokens.phoneLandscapeHorizontalPadding)
                    .padding(.vertical, DesignTokens.Spacing.sm)
                }
                .frame(maxWidth: .infinity)
                .accessibilityIdentifier("spearheadBattle.phoneLandscape.opponentColumn")
            }
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("spearheadBattle.phoneLandscape")
        }
    }

    @ViewBuilder
    private func battleScrollSections(includeOpponentUnits: Bool) -> some View {
        damageUndoBanner
        battleGuideCard
        phasePlaybook
        battleTacticCommandGuideSection
        phaseHelpers
        roundTwoPlusOpenerCard
        heroRoundOneNotice
        startOfRoundHelper
        roundOpenerIfNeeded
        reinforcementCallBanner
        reinforcementsSection
        yourUnitsSection()
        if includeOpponentUnits {
            opponentUnitsSection()
        }
    }

    // MARK: - Two Column (iPad)

    @ViewBuilder
    private var twoColumnLayout: some View {
        VStack(spacing: 0) {
            stickyHeader
            damageUndoBanner
                .padding(.horizontal, DesignTokens.Spacing.md)
                .padding(.top, DesignTokens.Spacing.sm)
            HStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: DesignTokens.Spacing.md) {
                        battleGuideCard
                        phasePlaybook
                        battleTacticCommandGuideSection
                        phaseHelpers
                        roundTwoPlusOpenerCard
                        heroRoundOneNotice
                        startOfRoundHelper
                        roundOpenerIfNeeded
                        reinforcementCallBanner
                        reinforcementsSection
                        yourUnitsSection()
                    }
                    .padding(DesignTokens.Spacing.md)
                }
                .frame(maxWidth: .infinity)

                Divider()

                ScrollView {
                    VStack(spacing: DesignTokens.Spacing.md) {
                        opponentUnitsSection()
                    }
                    .padding(DesignTokens.Spacing.md)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    @ViewBuilder
    var damageUndoBanner: some View {
        BattleTrackerDamageUndoSection(
            notice: damageUndoNotice,
            reduceMotion: reduceMotion,
            onUndo: {
                if let notice = damageUndoNotice {
                    viewModel.undoDamage(to: notice.woundKey, previousWounds: notice.previousWounds)
                }
            },
            onDismiss: { damageUndoNotice = nil }
        )
    }

    // MARK: - Sticky Header

    @ViewBuilder
    private var stickyHeader: some View {
        SpearheadStickyHeader(
            round: viewModel.trackerState.battleRound,
            phase: viewModel.trackerState.currentPhase,
            activePlayerName: viewModel.activePlayerName,
            playerOneVP: viewModel.trackerState.playerOneVictoryPoints,
            playerTwoVP: viewModel.trackerState.playerTwoVictoryPoints,
            playerOneName: viewModel.playerOneName,
            playerTwoName: viewModel.playerTwoName,
            activePlayerIsOne: viewModel.trackerState.activePlayerIsOne,
            isRoundOneFirstTurnEditable: viewModel.isRoundOneFirstTurnEditable,
            compactLandscape: usesPhoneLandscapeLayout,
            onSetFirstTurn: viewModel.setFirstTurn,
            onTapVP: { showsVictoryPointsSheet = true }
        )
    }

    @ViewBuilder
    private func stickyHeader(compactLandscape: Bool) -> some View {
        SpearheadStickyHeader(
            round: viewModel.trackerState.battleRound,
            phase: viewModel.trackerState.currentPhase,
            activePlayerName: viewModel.activePlayerName,
            playerOneVP: viewModel.trackerState.playerOneVictoryPoints,
            playerTwoVP: viewModel.trackerState.playerTwoVictoryPoints,
            playerOneName: viewModel.playerOneName,
            playerTwoName: viewModel.playerTwoName,
            activePlayerIsOne: viewModel.trackerState.activePlayerIsOne,
            isRoundOneFirstTurnEditable: viewModel.isRoundOneFirstTurnEditable,
            compactLandscape: compactLandscape,
            onSetFirstTurn: viewModel.setFirstTurn,
            onTapVP: { showsVictoryPointsSheet = true }
        )
    }

    @ViewBuilder
    private var battleGuideCard: some View {
        if showsBattleGuide, let step = viewModel.currentGuideStep {
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
            .accessibilityIdentifier("spearheadBattle.guideCard")
        }
    }

    private var showsBattleGuide: Bool {
        guard !dismissedBattleCompleteGuide, viewModel.currentGuideStep != nil else { return false }
        if let step = viewModel.currentGuideStep {
            switch step.kind {
            case .deployment, .scSetup, .wh40kSetup, .cpSetup, .turnPhase:
                return false
            default:
                break
            }
        }
        return true
    }

    // MARK: - Phase Playbook

    @ViewBuilder
    var phasePlaybook: some View {
        SpearheadPhasePlaybook(
            viewModel: viewModel,
            onAdvance: viewModel.advanceTurnOrPhase
        )
    }

    // MARK: - Round coaching

    @ViewBuilder
    private var roundTwoPlusOpenerCard: some View {
        if viewModel.trackerState.battleRound > 1, viewModel.roundOpenerIsIncomplete {
            SpearheadRoundTwoPlusOpenerCard(
                battleRound: viewModel.trackerState.battleRound,
                underdogPlayerName: viewModel.underdogPlayerName
            )
            .accessibilityIdentifier("spearheadBattle.roundTwoPlusOpener")
        }
    }

    @ViewBuilder
    var heroRoundOneNotice: some View {
        BattleTrackerHeroRoundOneSection(
            isVisible: showsHeroRoundOneNotice,
            onDismiss: {
                NewPlayerTipsStore.dismissHeroRoundOneNudge()
                withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) {
                    showsHeroRoundOneNotice = false
                }
            }
        )
    }

    @ViewBuilder
    var startOfRoundHelper: some View {
        BattleTrackerStartOfRoundHelperSection(
            isVisible: viewModel.needsStartOfRoundAbilitiesPrompt
                && !viewModel.startOfRoundAbilities.isEmpty,
            abilities: viewModel.startOfRoundAbilities
        )
    }

    // MARK: - Round Opener

    @ViewBuilder
    private var roundOpenerIfNeeded: some View {
        if showsRoundOpener && viewModel.roundOpenerIsIncomplete {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                HStack {
                    Spacer()
                    Button {
                        showsRoundOpener = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(String(localized: "Dismiss round opener"))
                }

                RoundChecklistCard(
                    round: viewModel.trackerState.battleRound,
                    completedSteps: viewModel.trackerState.completedRoundChecklistSteps,
                    focusedStep: viewModel.focusedRoundOpenerStep,
                    playerOneName: viewModel.playerOneName,
                    playerTwoName: viewModel.playerTwoName,
                    attackerName: viewModel.attackerName,
                    firstTurnIsPlayerOne: viewModel.firstTurnIsPlayerOne,
                    onSelectFirstTurn: viewModel.setRoundFirstTurn,
                    onToggle: { step, complete in
                        viewModel.setRoundChecklistStep(step, complete: complete)
                        if !viewModel.roundOpenerIsIncomplete {
                            showsRoundOpener = false
                        }
                    }
                )
            }
            .accessibilityIdentifier("spearheadBattle.roundOpener")
        }
    }

    // MARK: - Reinforcements

    @ViewBuilder
    var reinforcementCallBanner: some View {
        if let prompt = viewModel.pendingReinforcementCall {
            BattleTrackerReinforcementCallBanner(
                prompt: prompt,
                onDismiss: { viewModel.clearReinforcementCallPrompt() }
            )
        }
    }

    @ViewBuilder
    var reinforcementsSection: some View {
        if viewModel.showsReinforcementsTracking {
            SpearheadReinforcementsSection(
                playerOneName: viewModel.playerOneName,
                playerTwoName: viewModel.playerTwoName,
                playerOneArmy: viewModel.playerOneArmy,
                playerTwoArmy: viewModel.playerTwoArmy,
                calledUnitKeys: viewModel.trackerState.calledReinforcementUnitKeys,
                showsCallReminder: viewModel.pendingReinforcementCall != nil,
                onReinforcementOnTableChanged: viewModel.setReinforcementOnTable
            )
        }
    }

    // MARK: - Your Units Section

    @ViewBuilder
    func yourUnitsSection(embedsResolver: Bool = true) -> some View {
        SpearheadUnitSection(
            title: String(localized: "Your Units"),
            units: viewModel.yourUnits,
            army: viewModel.activeArmy,
            defenderUnits: viewModel.opponentUnits,
            defenderArmy: viewModel.opponentArmy,
            woundsRemaining: viewModel.trackerState.unitWoundsRemaining,
            currentPhase: viewModel.trackerState.currentPhase,
            gameSystemId: viewModel.gameSystemId,
            playerOneArmyId: viewModel.playerOneArmy?.id,
            playerTwoArmyId: viewModel.playerTwoArmy?.id,
            activePlayerIsOne: viewModel.trackerState.activePlayerIsOne,
            attackerPlayerName: viewModel.activePlayerName,
            defenderPlayerName: viewModel.trackerState.activePlayerIsOne
                ? viewModel.playerTwoName
                : viewModel.playerOneName,
            expandedUnitKey: $expandedUnitKey,
            resolverContext: $resolverContext,
            unitHasActed: viewModel.unitHasActed(unitKey:),
            isActivePlayer: true,
            onSelectWeapon: handleSelectWeapon,
            onSetWounds: viewModel.setUnitWounds,
            onApplyDamage: handleApplyDamage,
            onOpenUnitFocus: { armyId, unitId in
                presentUnitFocus(armyId: armyId, unitId: unitId)
            },
            embedsInlineResolver: embedsResolver
        )
    }

    // MARK: - Opponent Units Section

    @ViewBuilder
    func opponentUnitsSection(embedsResolver: Bool = true) -> some View {
        SpearheadUnitSection(
            title: String(localized: "Opponent Units"),
            units: viewModel.opponentUnits,
            army: viewModel.opponentArmy,
            defenderUnits: viewModel.yourUnits,
            defenderArmy: viewModel.activeArmy,
            woundsRemaining: viewModel.trackerState.unitWoundsRemaining,
            currentPhase: viewModel.trackerState.currentPhase,
            gameSystemId: viewModel.gameSystemId,
            playerOneArmyId: viewModel.playerOneArmy?.id,
            playerTwoArmyId: viewModel.playerTwoArmy?.id,
            activePlayerIsOne: viewModel.trackerState.activePlayerIsOne,
            attackerPlayerName: viewModel.activePlayerName,
            defenderPlayerName: viewModel.trackerState.activePlayerIsOne
                ? viewModel.playerTwoName
                : viewModel.playerOneName,
            expandedUnitKey: $expandedUnitKey,
            resolverContext: $resolverContext,
            unitHasActed: viewModel.unitHasActed(unitKey:),
            isActivePlayer: false,
            onSelectWeapon: handleSelectWeapon,
            onSetWounds: viewModel.setUnitWounds,
            onApplyDamage: handleApplyDamage,
            onOpenUnitFocus: { armyId, unitId in
                presentUnitFocus(armyId: armyId, unitId: unitId)
            },
            embedsInlineResolver: embedsResolver
        )
    }

    // MARK: - Actions

    private func checkRoundOpener() {
        if viewModel.roundOpenerIsIncomplete {
            showsRoundOpener = true
        }
    }

    private func presentHeroRoundOneNudgeIfNeeded() {
        guard !MarketingSnapshotBootstrap.suppressesCoachingUI else { return }
        guard viewModel.trackerState.battleRound == 1 else { return }
        guard viewModel.trackerState.currentPhase == .hero else { return }
        guard PlayerCoachingPolicy.shouldShowTip(
            tipKey: .heroRoundOneNudge,
            profile: activePlayerProfile,
            globallyDismissed: NewPlayerTipsStore.hasDismissedHeroRoundOneNudge
        ) else { return }
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) {
            showsHeroRoundOneNotice = true
        }
    }

    func handleSelectWeapon(armyId: String, unitId: String, weaponId: String) {
        let attackerKey = "\(armyId):\(unitId)"
        expandedUnitKey = attackerKey
        let existingDefender = resolverContext?.attackerKey == attackerKey ? resolverContext?.defenderKey : nil
        resolverContext = InlineResolverContext(
            attackerKey: attackerKey,
            weaponId: weaponId,
            defenderKey: existingDefender
        )
        if usesNewBattleScreen {
            showsCombatSheet = true
        }
    }

    func handleApplyDamage(
        defenderKey: String,
        attackerKey: String,
        damage: Int,
        batchLog: CombatBatchLogContext?
    ) {
        _ = batchLog
        let defenderName = viewModel.defenderDisplayName(for: defenderKey)

        if damage > 0, let previous = viewModel.applyDamage(to: defenderKey, amount: damage) {
            withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) {
                damageUndoNotice = DamageUndoNotice(
                    message: String(localized: "Applied \(damage) damage to \(defenderName)."),
                    woundKey: defenderKey,
                    previousWounds: previous
                )
            }
        }

        viewModel.markAttackerActed(attackerKey: attackerKey)
        resolverContext = nil
        showsCombatSheet = false

        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) {
            if let nextKey = viewModel.nextUnactedCombatUnitKey() {
                expandedUnitKey = nextKey
            } else {
                expandedUnitKey = nil
            }
        }
    }
}

// MARK: - Victory

extension SpearheadBattleView {
    var battleChrome: some View {
        Group {
            if usesNewBattleScreen {
                battleScreen
            } else {
                battleLayout
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear {
            checkRoundOpener()
            presentHeroRoundOneNudgeIfNeeded()
            captureTurnStartVP()
        }
        .onChange(of: viewModel.trackerState.activePlayerIsOne) { _, _ in
            captureTurnStartVP()
        }
        .sheet(isPresented: $showsCombatSheet) {
            combatSheet
        }
        .sheet(isPresented: $showsUnitsSheet) {
            NavigationStack {
                ScrollView {
                    VStack(spacing: DesignTokens.Spacing.md) {
                        yourUnitsSection(embedsResolver: false)
                        opponentUnitsSection(embedsResolver: false)
                    }
                    .padding(DesignTokens.Spacing.md)
                }
                .navigationTitle(String(localized: "Units"))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button(String(localized: "Done")) { showsUnitsSheet = false }
                    }
                }
            }
            .presentationDetents([.medium, .large])
            .presentationBackground(TTColor.canvas)
            .accessibilityIdentifier("battleTracker.unitsSheet")
        }
        .sheet(isPresented: $showsRoundPicker) {
            roundPickerSheet
        }
        .fullScreenCover(isPresented: $showsTurnHandoff) {
            turnHandoffCover
        }
        .onChange(of: viewModel.trackerState.battleRound) { _, _ in
            checkRoundOpener()
        }
        .onChange(of: viewModel.trackerState.currentPhase) { _, phase in
            if phase == .hero {
                presentHeroRoundOneNudgeIfNeeded()
            } else {
                showsHeroRoundOneNotice = false
            }
        }
        .onChange(of: viewModel.roundOpenerIsIncomplete) { _, incomplete in
            if incomplete {
                showsRoundOpener = true
            }
        }
        .fullScreenCover(isPresented: $showsVictoryScreen) {
            victoryScreen
        }
        .sheet(isPresented: $showsVictoryPointsSheet) {
            SpearheadVictoryPointsSheet(viewModel: viewModel)
        }
        .modifier(
            UnitFocusPresentationModifier(
                selection: $unitFocusSelection,
                usesFullScreen: usesUnitFocusFullScreenPresentation
            ) {
                unitFocusSheet
            }
        )
        .accessibilityIdentifier("spearheadBattle.screen")
    }

    var victoryScreen: some View {
        MatchVictoryScreen(
            presentation: MatchVictoryPresentation(
                gameSystemId: viewModel.gameSystemId.rawValue,
                gameSystemName: GameSystemRulesLabels.displayName(gameSystemId: viewModel.gameSystemId),
                playerOneName: viewModel.playerOneName,
                playerTwoName: viewModel.playerTwoName,
                playerOneArmyLabel: viewModel.playerOneArmyLabel,
                playerTwoArmyLabel: viewModel.playerTwoArmyLabel,
                playerOneVictoryPoints: victoryPlayerOneVP,
                playerTwoVictoryPoints: victoryPlayerTwoVP,
                startedAt: MatchSessionStore.startedAt(gameSystemId: viewModel.gameSystemId),
                status: .completed
            ),
            mode: .interactive,
            onDone: {
                Task { await completeVictory(rematch: false) }
            },
            onRematch: {
                Task { await completeVictory(rematch: true) }
            },
            onVictoryPointsChange: { playerOne, playerTwo in
                victoryPlayerOneVP = playerOne
                victoryPlayerTwoVP = playerTwo
                viewModel.setFinalVictoryPoints(playerOne: playerOne, playerTwo: playerTwo)
            }
        )
    }

    func presentVictoryScreen() {
        unitFocusSelection = nil
        victoryPlayerOneVP = viewModel.trackerState.playerOneVictoryPoints
        victoryPlayerTwoVP = viewModel.trackerState.playerTwoVictoryPoints
        dismissedBattleCompleteGuide = true
        showsVictoryScreen = true
        Task {
            await onVictoryPresented?(victoryPlayerOneVP, victoryPlayerTwoVP)
        }
        TabletomeAnalytics.logger?.info(
            .guidedMatch,
            eventName: "battle_tracker_victory_presented",
            message: "Victory screen presented.",
            metadata: [
                "gameSystemId": viewModel.gameSystemId.rawValue,
                "playerOneVP": String(victoryPlayerOneVP),
                "playerTwoVP": String(victoryPlayerTwoVP),
                "battleRound": String(viewModel.trackerState.battleRound),
                "durationSeconds": TabletomeAnalytics.durationSeconds(
                    since: MatchSessionStore.startedAt(gameSystemId: viewModel.gameSystemId)
                ) ?? "0"
            ]
        )
    }

    func completeVictory(rematch: Bool) async {
        await onVictoryComplete?(rematch, victoryPlayerOneVP, victoryPlayerTwoVP)
        showsVictoryScreen = false
        viewModel.reloadFromPersistedStores()
        onMatchStateChange?()
        if rematch {
            dismissedBattleCompleteGuide = false
            showsRoundOpener = viewModel.roundOpenerIsIncomplete
        }
    }
}

// MARK: - Resolver Context

struct InlineResolverContext: Equatable {
    let attackerKey: String
    let weaponId: String
    var defenderKey: String?
}
