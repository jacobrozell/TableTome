import Foundation

extension CombatPatrolStratagem {
    /// Matches catalog phase labels (e.g. "Command", "Shooting or Fight") to tracker phases.
    public func matches(battlePhase: BattleTurnPhase) -> Bool {
        guard let label = phase?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
              !label.isEmpty else {
            return battlePhase == .command
        }

        if label.contains("command") {
            return battlePhase == .command
        }
        if label.contains("movement") {
            return battlePhase == .movement
        }
        if label.contains("charge") {
            return battlePhase == .charge
        }
        if label.contains("shooting"), label.contains("fight") {
            return battlePhase == .shooting || battlePhase == .combat || battlePhase == .anyCombat
        }
        if label == "fight" || label.hasSuffix(" fight") || label.hasPrefix("fight ") {
            return battlePhase == .combat || battlePhase == .anyCombat
        }
        if label.contains("shooting") {
            return battlePhase == .shooting
        }
        if label.contains("fight") {
            return battlePhase == .combat || battlePhase == .anyCombat
        }
        return false
    }
}
