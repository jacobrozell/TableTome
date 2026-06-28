import Foundation
import TabletomeDomain

extension BattlePhaseTrackerViewModel {
    var usesAlternatingActivation: Bool {
        playContext.usesAlternatingActivation
    }

    var usesPhasedRounds: Bool {
        playContext.usesPhasedRounds
    }

    var usesGuidedBattleTracker: Bool {
        playContext.usesGuidedBattleTracker
    }

    var activePlayerSelection: PlayerArmySelection {
        trackerState.activePlayerIsOne ? matchState.playerOne : matchState.playerTwo
    }

    var activeArmySelection: SpearheadArmy? {
        army(for: activePlayerSelection)
    }
}
