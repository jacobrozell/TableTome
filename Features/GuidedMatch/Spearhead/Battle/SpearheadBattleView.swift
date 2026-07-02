import SwiftUI
import TabletomeDomain

/// Single-surface battle interface for Spearhead — replaces tab-based tracker.
/// See `ongoing/guided-match-ui-redesign.md` for design rationale.
struct SpearheadBattleView: View {
    @StateObject var viewModel: SpearheadBattleViewModel
    @State private var expandedUnitKey: String?
    @State private var resolverContext: InlineResolverContext?
    @State private var showsRoundOpener = false
    @State private var showsVictoryScreen = false
    @State private var showsVictoryPointsSheet = false
    @State private var damageUndoNotice: DamageUndoNotice?
    @State private var victoryPlayerOneVP = 0
    @State private var victoryPlayerTwoVP = 0
    @State private var dismissedBattleCompleteGuide = false

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let onMatchStateChange: (() -> Void)?
    let onVictoryComplete: ((Bool, Int, Int) async -> Void)?
    let onVictoryPresented: ((Int, Int) async -> Void)?

    init(
        gameSystemId: GameSystemId,
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
            wrappedValue: SpearheadBattleViewModel(
                gameSystemId: gameSystemId,
                matchState: matchState,
                catalog: catalog,
                onMatchStateChange: onMatchStateChange
            )
        )
    }

    private var layoutContext: TabletomeLayoutContext {
        TabletomeLayout.context(
            horizontalSizeClass: horizontalSizeClass,
            verticalSizeClass: verticalSizeClass
        )
    }

    private var usesTwoColumnLayout: Bool {
        layoutContext.usesPadSplitNavigation && !dynamicTypeSize.needsLayoutAdaptation
    }

    var body: some View {
        Group {
            if usesTwoColumnLayout {
                twoColumnLayout
            } else {
                singleColumnLayout
            }
        }
        .onAppear {
            checkRoundOpener()
        }
        .onChange(of: viewModel.trackerState.battleRound) { _, _ in
            checkRoundOpener()
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
        .accessibilityIdentifier("spearheadBattle.screen")
    }

    // MARK: - Single Column (iPhone)

    @ViewBuilder
    private var singleColumnLayout: some View {
        ScrollView {
            VStack(spacing: DesignTokens.Spacing.md) {
                damageUndoBanner
                battleGuideCard
                phasePlaybook
                roundOpenerIfNeeded
                reinforcementCallBanner
                reinforcementsSection
                yourUnitsSection
                opponentUnitsSection
            }
            .padding(.horizontal, DesignTokens.Spacing.md)
            .padding(.bottom, DesignTokens.Spacing.xl)
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            stickyHeader
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
                        roundOpenerIfNeeded
                        reinforcementCallBanner
                        reinforcementsSection
                        yourUnitsSection
                    }
                    .padding(DesignTokens.Spacing.md)
                }
                .frame(maxWidth: .infinity)

                Divider()

                ScrollView {
                    VStack(spacing: DesignTokens.Spacing.md) {
                        opponentUnitsSection
                    }
                    .padding(DesignTokens.Spacing.md)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    @ViewBuilder
    private var damageUndoBanner: some View {
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
            case .deployment, .scSetup, .wh40kSetup, .cpSetup:
                return false
            default:
                break
            }
        }
        return true
    }

    // MARK: - Phase Playbook

    @ViewBuilder
    private var phasePlaybook: some View {
        SpearheadPhasePlaybook(
            viewModel: viewModel,
            onAdvance: viewModel.advanceTurnOrPhase
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
    private var reinforcementCallBanner: some View {
        if let prompt = viewModel.pendingReinforcementCall {
            BattleTrackerReinforcementCallBanner(
                prompt: prompt,
                onDismiss: { viewModel.clearReinforcementCallPrompt() }
            )
        }
    }

    @ViewBuilder
    private var reinforcementsSection: some View {
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
    private var yourUnitsSection: some View {
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
            onApplyDamage: handleApplyDamage
        )
    }

    // MARK: - Opponent Units Section

    @ViewBuilder
    private var opponentUnitsSection: some View {
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
            onApplyDamage: handleApplyDamage
        )
    }

    // MARK: - Actions

    private func checkRoundOpener() {
        if viewModel.roundOpenerIsIncomplete {
            showsRoundOpener = true
        }
    }

    private func handleSelectWeapon(armyId: String, unitId: String, weaponId: String) {
        let attackerKey = "\(armyId):\(unitId)"
        expandedUnitKey = attackerKey
        let existingDefender = resolverContext?.attackerKey == attackerKey ? resolverContext?.defenderKey : nil
        resolverContext = InlineResolverContext(
            attackerKey: attackerKey,
            weaponId: weaponId,
            defenderKey: existingDefender
        )
    }

    private func handleApplyDamage(
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
    var hitsEntered: Int?
    var woundsEntered: Int?
    var failedSavesEntered: Int?
    var wardedOff: Int?
}
