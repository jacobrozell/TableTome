import Foundation

extension ArmyRuleOption {
    public func matches(phase: BattleTurnPhase) -> Bool {
        guard let phases, !phases.isEmpty else { return false }
        if phases.contains(phase) { return true }
        if phase == .combat, phases.contains(.anyCombat) { return true }
        return false
    }

    public func isAvailableIn(phase: BattleTurnPhase) -> Bool {
        matches(phase: phase)
    }
}
