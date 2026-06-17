import Foundation

public enum NewPlayerTipsStore: Sendable {
    private static let prefix = "new_player_tips"
    private static let battleTrackerCoachKey = "\(prefix)_battle_tracker_coach"
    private static let combatSequencePrimerKey = "\(prefix)_combat_sequence_primer"

    public static var hasSeenBattleTrackerCoach: Bool {
        UserDefaults.standard.bool(forKey: battleTrackerCoachKey)
    }

    public static func markBattleTrackerCoachSeen() {
        UserDefaults.standard.set(true, forKey: battleTrackerCoachKey)
    }

    public static var hasDismissedCombatSequencePrimer: Bool {
        UserDefaults.standard.bool(forKey: combatSequencePrimerKey)
    }

    public static func dismissCombatSequencePrimer() {
        UserDefaults.standard.set(true, forKey: combatSequencePrimerKey)
    }

    public static func resetAll() {
        UserDefaults.standard.removeObject(forKey: battleTrackerCoachKey)
        UserDefaults.standard.removeObject(forKey: combatSequencePrimerKey)
    }
}
