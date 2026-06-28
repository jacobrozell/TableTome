import SwiftUI
import TabletomeDomain

/// StarCraft TMG and future alternating-activation engines (Phase 5).
struct AlternatingActivationTrackerView: View {
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

    var body: some View {
        BattlePhaseTrackerView(
            gameSystemId: gameSystemId,
            matchState: matchState,
            catalog: catalog,
            ruleSections: ruleSections,
            onMatchStateChange: onMatchStateChange,
            onVictoryComplete: onVictoryComplete
        )
        .environment(\.battleTrackerPlayEngineId, .alternatingActivation)
    }
}
