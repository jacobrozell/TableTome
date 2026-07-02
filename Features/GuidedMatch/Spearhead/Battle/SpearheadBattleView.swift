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

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

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
        .fullScreenCover(isPresented: $showsVictoryScreen) {
            victoryScreen
        }
        .accessibilityIdentifier("spearheadBattle.screen")
    }

    // MARK: - Single Column (iPhone)

    @ViewBuilder
    private var singleColumnLayout: some View {
        ScrollView {
            VStack(spacing: DesignTokens.Spacing.md) {
                phasePlaybook
                roundOpenerIfNeeded
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
            HStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: DesignTokens.Spacing.md) {
                        phasePlaybook
                        roundOpenerIfNeeded
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
            onTapVP: { /* TODO: VP detail sheet */ }
        )
    }

    // MARK: - Phase Playbook

    @ViewBuilder
    private var phasePlaybook: some View {
        SpearheadPhasePlaybook(
            phase: viewModel.trackerState.currentPhase,
            round: viewModel.trackerState.battleRound,
            canAdvance: viewModel.canAdvancePhase,
            nextPhaseTitle: viewModel.nextPhaseTitle,
            shootableUnitCount: viewModel.shootingEligibleUnits.count,
            totalUnitCount: viewModel.yourUnits.count,
            onAdvance: viewModel.advancePhase
        )
    }

    // MARK: - Round Opener

    @ViewBuilder
    private var roundOpenerIfNeeded: some View {
        if showsRoundOpener && viewModel.roundOpenerIsIncomplete {
            SpearheadRoundOpener(
                round: viewModel.trackerState.battleRound,
                completedSteps: viewModel.completedRoundOpenerSteps,
                onCompleteStep: viewModel.completeRoundOpenerStep,
                onDismiss: { showsRoundOpener = false }
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
            woundsRemaining: viewModel.trackerState.unitWoundsRemaining,
            currentPhase: viewModel.trackerState.currentPhase,
            expandedUnitKey: $expandedUnitKey,
            resolverContext: $resolverContext,
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
            woundsRemaining: viewModel.trackerState.unitWoundsRemaining,
            currentPhase: viewModel.trackerState.currentPhase,
            expandedUnitKey: $expandedUnitKey,
            resolverContext: $resolverContext,
            isActivePlayer: false,
            onSelectWeapon: handleSelectWeapon,
            onSetWounds: viewModel.setUnitWounds,
            onApplyDamage: handleApplyDamage
        )
    }

    // MARK: - Victory Screen

    @ViewBuilder
    private var victoryScreen: some View {
        Text("Victory Screen Placeholder")
    }

    // MARK: - Actions

    private func checkRoundOpener() {
        if viewModel.roundOpenerIsIncomplete && viewModel.trackerState.battleRound > 1 {
            showsRoundOpener = true
        }
    }

    private func handleSelectWeapon(armyId: String, unitId: String, weaponId: String) {
        let attackerKey = "\(armyId):\(unitId)"
        resolverContext = InlineResolverContext(
            attackerKey: attackerKey,
            weaponId: weaponId,
            defenderKey: nil
        )
    }

    private func handleApplyDamage(defenderKey: String, damage: Int) {
        viewModel.applyDamage(to: defenderKey, amount: damage)
        resolverContext = nil
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
