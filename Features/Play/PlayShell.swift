import SwiftUI
import TabletomeDomain

/// Engine-agnostic entry for in-battle play — routes to the tracker view for the active `PlayEngineId`.
struct PlayShell: View {
    let gameSystemId: GameSystemId
    let matchState: GuidedMatchState
    let catalog: SpearheadCatalog
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
        self.gameSystemId = gameSystemId
        self.matchState = matchState
        self.catalog = catalog
        self.ruleSections = ruleSections
        self.onMatchStateChange = onMatchStateChange
        self.onVictoryComplete = onVictoryComplete
        self.onVictoryPresented = onVictoryPresented
    }

    private var playEngineId: PlayEngineId {
        GameSystemPlayContext.context(for: gameSystemId).playEngine.playEngineId
    }

    var body: some View {
        switch playEngineId {
        case .alternatingActivation:
            AlternatingActivationTrackerView(
                gameSystemId: gameSystemId,
                matchState: matchState,
                catalog: catalog,
                ruleSections: ruleSections,
                onMatchStateChange: onMatchStateChange,
                onVictoryComplete: onVictoryComplete,
                onVictoryPresented: onVictoryPresented
            )
        case .phasedRound:
            if gameSystemId.isSpearhead && ReleaseSurface.usesSpearheadSingleSurfaceBattle {
                SpearheadBattleView(
                    gameSystemId: gameSystemId,
                    matchState: matchState,
                    catalog: catalog,
                    ruleSections: ruleSections,
                    onMatchStateChange: onMatchStateChange,
                    onVictoryComplete: onVictoryComplete,
                    onVictoryPresented: onVictoryPresented
                )
            } else {
                PhasedRoundTrackerView(
                    gameSystemId: gameSystemId,
                    matchState: matchState,
                    catalog: catalog,
                    ruleSections: ruleSections,
                    onMatchStateChange: onMatchStateChange,
                    onVictoryComplete: onVictoryComplete,
                    onVictoryPresented: onVictoryPresented
                )
            }
        case .gridSportDrive, .commandCardPool, .heroSkirmish, .rulesOnly:
            PhasedRoundTrackerView(
                gameSystemId: gameSystemId,
                matchState: matchState,
                catalog: catalog,
                ruleSections: ruleSections,
                onMatchStateChange: onMatchStateChange,
                onVictoryComplete: onVictoryComplete,
                onVictoryPresented: onVictoryPresented
            )
        }
    }
}
