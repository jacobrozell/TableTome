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

    init(
        gameSystemId: GameSystemId = .default,
        matchState: GuidedMatchState,
        catalog: SpearheadCatalog,
        ruleSections: [RuleSection] = [],
        onMatchStateChange: (() -> Void)? = nil,
        onVictoryComplete: ((Bool, Int, Int) async -> Void)? = nil
    ) {
        self.gameSystemId = gameSystemId
        self.matchState = matchState
        self.catalog = catalog
        self.ruleSections = ruleSections
        self.onMatchStateChange = onMatchStateChange
        self.onVictoryComplete = onVictoryComplete
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
                onVictoryComplete: onVictoryComplete
            )
        case .phasedRound:
            PhasedRoundTrackerView(
                gameSystemId: gameSystemId,
                matchState: matchState,
                catalog: catalog,
                ruleSections: ruleSections,
                onMatchStateChange: onMatchStateChange,
                onVictoryComplete: onVictoryComplete
            )
        case .gridSportDrive, .commandCardPool, .heroSkirmish, .rulesOnly:
            // Future engines — reuse phased-round tracker until dedicated shells ship.
            PhasedRoundTrackerView(
                gameSystemId: gameSystemId,
                matchState: matchState,
                catalog: catalog,
                ruleSections: ruleSections,
                onMatchStateChange: onMatchStateChange,
                onVictoryComplete: onVictoryComplete
            )
        }
    }
}
