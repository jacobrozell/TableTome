import SwiftUI
import TabletomeDomain

extension SpearheadBattleView {
    var battleScreen: some View {
        BattleScreenLayout(layoutContext: layoutContext, dynamicTypeSize: dynamicTypeSize) {
            scoreboardHeader
        } phaseRail: {
            BattlePhaseRail(
                phases: railPhases,
                current: viewModel.trackerState.currentPhase,
                tone: TTTone.player(viewModel.trackerState.activePlayerIsOne),
                gameSystemId: viewModel.gameSystemId.rawValue,
                axis: layoutContext == .phoneLandscape ? .vertical : .horizontal,
                showsDeployment: isDeploymentMoment
            ) { phase in
                viewModel.setPhase(phase)
            }
        } content: {
            battleNowContent
        } actionBar: {
            BattlePrimaryActionBar(
                title: actionPresentation.title,
                systemImage: actionPresentation.systemImage,
                usesPlayerStyle: actionPresentation.usesPlayerStyle,
                playerIsOne: actionPresentation.playerIsOne,
                usesCompleteIdentifier: actionPresentation.usesCompleteIdentifier,
                isPrimaryEnabled: primaryIsEnabled && !primaryActionLocked,
                onPrimary: performPrimaryAction,
                onUnits: { showsUnitsSheet = true },
                onDice: { showsUnitsSheet = true }
            )
        } sidePanel: {
            yourUnitsSection
            opponentUnitsSection
        }
        .ttScreenBackground()
        .overlay(alignment: .topTrailing) {
            battleMenu
                .padding(.trailing, DesignTokens.Spacing.sm)
                .padding(.top, DesignTokens.Spacing.xs)
        }
        .ttHaptic(.phaseAdvanced, trigger: primaryTapCount)
        .ttHaptic(.handoff, trigger: viewModel.trackerState.battleRound)
    }

    private var scoreboardHeader: some View {
        let activeIsOne = viewModel.trackerState.activePlayerIsOne
        let underdog = viewModel.trackerState.battleRound >= 2 ? viewModel.underdogIsPlayerOne : nil
        return BattleScoreboardHeader(
            playerOne: .init(
                name: viewModel.playerOneName,
                armyName: viewModel.playerOneArmyLabel,
                victoryPoints: viewModel.trackerState.playerOneVictoryPoints,
                isActive: activeIsOne,
                isUnderdog: underdog == true,
                isPlayerOne: true
            ),
            playerTwo: .init(
                name: viewModel.playerTwoName,
                armyName: viewModel.playerTwoArmyLabel,
                victoryPoints: viewModel.trackerState.playerTwoVictoryPoints,
                isActive: !activeIsOne,
                isUnderdog: underdog == false,
                isPlayerOne: false
            ),
            round: viewModel.trackerState.battleRound,
            roundCount: viewModel.maxBattleRounds,
            compact: layoutContext == .phoneLandscape,
            onTapScore: { _ in showsVictoryPointsSheet = true },
            onTapRound: { showsRoundPicker = true }
        )
    }

    @ViewBuilder
    private var battleNowContent: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            damageUndoBanner
            if isDeploymentMoment {
                BattleDeploymentPanel(viewModel: viewModel)
            } else if viewModel.roundOpenerIsIncomplete {
                BattleRoundStartPanel(viewModel: viewModel)
            } else {
                phaseMoment
            }
        }
    }

    private var phaseMoment: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Text(String(localized: "\(viewModel.activePlayerName.uppercased())'S TURN · \(phaseTitle)"))
                .ttEyebrow(TTTone.player(viewModel.trackerState.activePlayerIsOne).foreground)
            Text(viewModel.trackerState.currentPhase.battleHeadline)
                .font(TTFont.title)
                .foregroundStyle(TTColor.inkPrimary)
            if viewModel.trackerState.currentPhase == .endOfTurn {
                endOfTurnScoring
            }
            SpearheadPhasePlaybook(viewModel: viewModel, showsOwnChrome: false, onAdvance: {})
            phaseHelpers
            battleTacticCommandGuideSection
            heroRoundOneNotice
            startOfRoundHelper
            reinforcementCallBanner
            reinforcementsSection
        }
    }

    private var endOfTurnScoring: some View {
        let scoring = viewModel.playContext.victoryPointsScoring
        let isOne = viewModel.trackerState.activePlayerIsOne
        return VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Button(scoring.primaryQuickAddLabel) {
                viewModel.adjustVictoryPoints(
                    playerIsOne: isOne,
                    delta: scoring.primaryQuickAddAmount,
                    reason: .objective
                )
            }
            .buttonStyle(.ttSecondary)
            Button(scoring.secondaryQuickAddLabel) {
                viewModel.adjustVictoryPoints(
                    playerIsOne: isOne,
                    delta: scoring.secondaryQuickAddAmount,
                    reason: .tactic
                )
            }
            .buttonStyle(.ttSecondary)
        }
    }

    private var battleMenu: some View {
        Menu {
            Button(String(localized: "Change Round…")) { showsRoundPicker = true }
                .accessibilityIdentifier("battleTracker.round")
            Button(String(localized: "Reset Battle…"), role: .destructive) {
                showsResetConfirmation = true
            }
            .accessibilityIdentifier("battleTracker.reset")
        } label: {
            Image(systemName: "ellipsis.circle")
                .font(TTFont.headline)
                .foregroundStyle(TTColor.inkSecondary)
                .frame(width: 44, height: 44)
        }
        .accessibilityIdentifier("battleTracker.menu")
        .confirmationDialog(
            String(localized: "Reset this battle?"),
            isPresented: $showsResetConfirmation,
            titleVisibility: .visible
        ) {
            Button(String(localized: "Reset Battle"), role: .destructive) {
                viewModel.resetTracker()
            }
            Button(String(localized: "Cancel"), role: .cancel) {}
        }
    }

    @ViewBuilder
    private func roundButton(_ round: Int) -> some View {
        let title = viewModel.playContext.playEngine.roundLabel(round: round)
        if round == viewModel.trackerState.battleRound {
            Button(title) {
                viewModel.setBattleRound(round)
                showsRoundPicker = false
            }
            .buttonStyle(.ttPrimary)
        } else {
            Button(title) {
                viewModel.setBattleRound(round)
                showsRoundPicker = false
            }
            .buttonStyle(.ttSecondary)
        }
    }

    var roundPickerSheet: some View {
        NavigationStack {
            VStack(spacing: DesignTokens.Spacing.md) {
                ForEach(1...viewModel.maxBattleRounds, id: \.self) { round in
                    roundButton(round)
                }
            }
            .padding(DesignTokens.Spacing.lg)
            .navigationTitle(String(localized: "Change Round"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Close")) { showsRoundPicker = false }
                }
            }
        }
        .presentationDetents([.medium])
        .presentationBackground(TTColor.canvas)
    }

    var turnHandoffCover: some View {
        let activeIsOne = viewModel.trackerState.activePlayerIsOne
        let previous = activeIsOne ? turnStartPlayerOneVP : turnStartPlayerTwoVP
        let current = activeIsOne
            ? viewModel.trackerState.playerOneVictoryPoints
            : viewModel.trackerState.playerTwoVictoryPoints
        return BattleTurnHandoffView(
            nextIsPlayerOne: !activeIsOne,
            nextName: activeIsOne ? viewModel.playerTwoName : viewModel.playerOneName,
            previousName: viewModel.activePlayerName,
            round: viewModel.trackerState.battleRound,
            scoredThisTurn: max(0, current - previous),
            playerOneScore: viewModel.trackerState.playerOneVictoryPoints,
            playerTwoScore: viewModel.trackerState.playerTwoVictoryPoints,
            playerOneName: viewModel.playerOneName,
            playerTwoName: viewModel.playerTwoName,
            onStart: {
                viewModel.completeCurrentGuideStep()
                showsTurnHandoff = false
            },
            onBack: { showsTurnHandoff = false }
        )
    }

    func captureTurnStartVP() {
        turnStartPlayerOneVP = viewModel.trackerState.playerOneVictoryPoints
        turnStartPlayerTwoVP = viewModel.trackerState.playerTwoVictoryPoints
    }

    private var railPhases: [BattleTurnPhase] {
        viewModel.playContext.playEngine.mainPhases().filter { $0 != .deployment }
    }

    private var isDeploymentMoment: Bool {
        if case .deployment = viewModel.currentGuideStep?.kind { return true }
        return false
    }

    private var phaseTitle: String {
        viewModel.trackerState.currentPhase.title.uppercased()
    }

    private var actionPresentation: BattleActionPresentation {
        let activeIsOne = viewModel.trackerState.activePlayerIsOne
        return BattleActionCopy.presentation(
            step: viewModel.currentGuideStep,
            activePlayerIsOne: activeIsOne,
            activePlayerName: viewModel.activePlayerName,
            otherPlayerName: activeIsOne ? viewModel.playerTwoName : viewModel.playerOneName,
            nextPhase: viewModel.playContext.playEngine.nextMainPhase(after: viewModel.trackerState.currentPhase)
        )
    }

    private var primaryIsEnabled: Bool {
        guard let step = viewModel.currentGuideStep else { return true }
        if case .roundOpener(.firstTurnOrPriority) = step.kind {
            return viewModel.matchState.firstTurnIsPlayerOne != nil
        }
        return true
    }

    private func performPrimaryAction() {
        guard !primaryActionLocked else { return }
        primaryActionLocked = true
        primaryTapCount += 1
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(400))
            primaryActionLocked = false
        }
        guard let step = viewModel.currentGuideStep else {
            viewModel.advancePhase()
            return
        }
        switch step.kind {
        case .battleComplete:
            if ReleaseSurface.showsMatchHistory { presentVictoryScreen() }
            dismissedBattleCompleteGuide = true
        case .turnPhase(.endOfTurn):
            if viewModel.canAdvanceBattleRound || viewModel.isBattleComplete {
                viewModel.completeCurrentGuideStep()
            } else {
                showsTurnHandoff = true
            }
        default:
            viewModel.completeCurrentGuideStep()
        }
    }
}
