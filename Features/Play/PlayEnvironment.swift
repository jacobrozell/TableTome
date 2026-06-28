import SwiftUI
import TabletomeDomain

private struct BattleTrackerPlayEngineIdKey: EnvironmentKey {
    static let defaultValue: PlayEngineId = .phasedRound
}

private struct BattleTrackerEmbeddedInGuidedMatchKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    /// Active battle-tracker engine archetype for layout arms that still share one view tree.
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
