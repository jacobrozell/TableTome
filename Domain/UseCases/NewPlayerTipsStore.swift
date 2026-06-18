import Foundation

public enum NewPlayerTipsStore: Sendable {
    private static let prefix = "new_player_tips"
    private static let battleTrackerCoachKey = "\(prefix)_battle_tracker_coach"
    private static let combatSequencePrimerKey = "\(prefix)_combat_sequence_primer"
    private static let pileInGuideKey = "\(prefix)_pile_in_guide"
    private static let guidedMatchSetupExpandedKey = "\(prefix)_guided_match_setup_expanded"

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

    public static var hasDismissedPileInGuide: Bool {
        UserDefaults.standard.bool(forKey: pileInGuideKey)
    }

    public static func dismissPileInGuide() {
        UserDefaults.standard.set(true, forKey: pileInGuideKey)
    }

    public static var hasExpandedGuidedMatchSetup: Bool {
        UserDefaults.standard.bool(forKey: guidedMatchSetupExpandedKey)
    }

    public static func markGuidedMatchSetupExpanded() {
        UserDefaults.standard.set(true, forKey: guidedMatchSetupExpandedKey)
    }

    public static func resetAll() {
        UserDefaults.standard.removeObject(forKey: battleTrackerCoachKey)
        UserDefaults.standard.removeObject(forKey: combatSequencePrimerKey)
        UserDefaults.standard.removeObject(forKey: pileInGuideKey)
        UserDefaults.standard.removeObject(forKey: guidedMatchSetupExpandedKey)
    }
}
