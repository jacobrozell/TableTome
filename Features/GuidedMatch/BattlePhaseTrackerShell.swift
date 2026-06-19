import SwiftUI
import TabletomeDomain
import TabletomeData

/// Entry point for the battle tracker — routes by `PlayEngineId` while sharing chrome and combat tools.
struct BattlePhaseTrackerShell: View {
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
        BattlePhaseTrackerView(
            gameSystemId: gameSystemId,
            matchState: matchState,
            catalog: catalog,
            ruleSections: ruleSections,
            onMatchStateChange: onMatchStateChange,
            onVictoryComplete: onVictoryComplete
        )
        .environment(\.battleTrackerPlayEngineId, playEngineId)
    }
}

private struct BattleTrackerPlayEngineIdKey: EnvironmentKey {
    static let defaultValue: PlayEngineId = .phasedRound
}

private struct BattleTrackerEmbeddedInGuidedMatchKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var battleTrackerPlayEngineId: PlayEngineId {
        get { self[BattleTrackerPlayEngineIdKey.self] }
        set { self[BattleTrackerPlayEngineIdKey.self] = newValue }
    }

    /// True when the tracker is embedded under Guided Match hub chrome (phone compact layout).
    var battleTrackerIsEmbeddedInGuidedMatch: Bool {
        get { self[BattleTrackerEmbeddedInGuidedMatchKey.self] }
        set { self[BattleTrackerEmbeddedInGuidedMatchKey.self] = newValue }
    }
}
