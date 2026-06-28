import Foundation
import TabletomeDomain

extension BattlePhaseTrackerViewModel {
    func completeAlternatingActivationTurnPhase(_ phase: BattleTurnPhase) {
        guard phase == .scoring else {
            advancePhase()
            return
        }
        if trackerState.battleRound >= playContext.playEngine.battleRoundCount() {
            return
        }
        setBattleRound(trackerState.battleRound + 1)
        setPhase(playContext.playEngine.initialPhase())
    }
}
