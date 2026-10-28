import SwiftUI

public enum TTHapticEvent: Equatable {
    case phaseAdvanced, scoreUp, scoreDown, wound, unitDestroyed, handoff, warning, victory

    var feedback: SensoryFeedback {
        switch self {
        case .phaseAdvanced: .selection
        case .scoreUp: .increase
        case .scoreDown: .decrease
        case .wound: .impact(weight: .light)
        case .unitDestroyed: .impact(weight: .heavy)
        case .handoff, .victory: .success
        case .warning: .warning
        }
    }
}

public extension View {
    /// Fires `event` each time `trigger` changes.
    func ttHaptic<T: Equatable>(_ event: TTHapticEvent, trigger: T) -> some View {
        sensoryFeedback(event.feedback, trigger: trigger)
    }
}
