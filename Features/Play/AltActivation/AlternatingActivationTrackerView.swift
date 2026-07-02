import SwiftUI
import TabletomeDomain

/// StarCraft TMG and future alternating-activation engines (Phase 5).
struct AlternatingActivationTrackerView: View {
    let gameSystemId: GameSystemId
    let matchState: GuidedMatchState
    let catalog: SpearheadCatalog
    let ruleSections: [RuleSection]
    var householdProfiles: [PlayerProfile] = []
    let onMatchStateChange: (() -> Void)?
    let onVictoryComplete: ((Bool, Int, Int) async -> Void)?
    let onVictoryPresented: ((Int, Int) async -> Void)?

    init(
        gameSystemId: GameSystemId = .default,
        matchState: GuidedMatchState,
        catalog: SpearheadCatalog,
        ruleSections: [RuleSection] = [],
        householdProfiles: [PlayerProfile] = [],
        onMatchStateChange: (() -> Void)? = nil,
        onVictoryComplete: ((Bool, Int, Int) async -> Void)? = nil,
        onVictoryPresented: ((Int, Int) async -> Void)? = nil
    ) {
        self.gameSystemId = gameSystemId
        self.matchState = matchState
        self.catalog = catalog
        self.ruleSections = ruleSections
        self.householdProfiles = householdProfiles
        self.onMatchStateChange = onMatchStateChange
        self.onVictoryComplete = onVictoryComplete
        self.onVictoryPresented = onVictoryPresented
    }

    var body: some View {
        BattlePhaseTrackerView(
            gameSystemId: gameSystemId,
            matchState: matchState,
            catalog: catalog,
            ruleSections: ruleSections,
            householdProfiles: householdProfiles,
            onMatchStateChange: onMatchStateChange,
            onVictoryComplete: onVictoryComplete,
            onVictoryPresented: onVictoryPresented
        )
        .environment(\.battleTrackerPlayEngineId, .alternatingActivation)
    }
}
