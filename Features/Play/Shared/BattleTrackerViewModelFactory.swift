import Foundation
import TabletomeDomain

/// Constructs battle tracker view models keyed by `PlayEngineId`.
enum BattleTrackerViewModelFactory {
    @MainActor
    static func make(
        gameSystemId: GameSystemId,
        matchState: GuidedMatchState,
        catalog: SpearheadCatalog,
        initialState: BattleTrackerState? = nil,
        onMatchStateChange: (() -> Void)? = nil
    ) -> BattlePhaseTrackerViewModel {
        let context = GameSystemPlayContext(gameSystemId: gameSystemId)
        switch context.playEngine.playEngineId {
        case .alternatingActivation:
            return AlternatingActivationBattleTrackerViewModel(
                gameSystemId: gameSystemId,
                matchState: matchState,
                catalog: catalog,
                initialState: initialState,
                playContext: context,
                onMatchStateChange: onMatchStateChange
            )
        case .phasedRound, .gridSportDrive, .commandCardPool, .heroSkirmish, .rulesOnly:
            return PhasedRoundBattleTrackerViewModel(
                gameSystemId: gameSystemId,
                matchState: matchState,
                catalog: catalog,
                initialState: initialState,
                playContext: context,
                onMatchStateChange: onMatchStateChange
            )
        }
    }
}
