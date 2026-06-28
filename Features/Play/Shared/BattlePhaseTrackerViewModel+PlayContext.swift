import Foundation
import TabletomeDomain

extension BattlePhaseTrackerViewModel {
    var capabilities: PlayCapabilities {
        playContext.capabilities
    }

    var usesAlternatingActivation: Bool {
        playContext.usesAlternatingActivation
    }

    var usesPhasedRounds: Bool {
        playContext.usesPhasedRounds
    }

    var usesGuidedBattleTracker: Bool {
        playContext.usesGuidedBattleTracker
    }
}
